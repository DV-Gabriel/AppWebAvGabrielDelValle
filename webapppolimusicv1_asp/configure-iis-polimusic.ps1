# ============================================================
# configure-iis-polimusic.ps1  (v2 - corrected)
# Configures IIS for the PoliMusic classic ASP project.
# MUST be run as Administrator.
#
# This version fixes:
#  - enable32BitAppOnWin64 (correct property name)
#  - Unlocks <asp> and <defaultDocument> sections at appHost level
#  - Correct FileSystemAccessRule overload
#  - Uses Get-WebAppPoolState / Start-WebAppPool / Start-Website
#  - Idempotent: safe to re-run after a partial run
# ============================================================

param(
    [string]$SiteName    = "PoliMusic",
    [string]$AppPoolName = "PoliMusicAppPool",
    [string]$PhysicalPath = "C:\Users\Gabriel Del Valle\Desktop\AppWebAvGabrielDelValle\webapppolimusicv1_asp",
    [int]$Port           = 8080
)

# --- Ensure admin ---
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator." -ForegroundColor Red
    Write-Host "Right-click PowerShell -> Run as Administrator, then run this script again." -ForegroundColor Yellow
    exit 1
}

Import-Module WebAdministration
Write-Host "Configuring IIS for PoliMusic (classic ASP)..." -ForegroundColor Cyan

# ---------------------------------------------------------------
# 1. Make sure the ASP classic Windows feature is installed
# ---------------------------------------------------------------
$aspFeature = Get-WindowsOptionalFeature -Online -FeatureName IIS-ASP -ErrorAction SilentlyContinue
if ($null -eq $aspFeature -or $aspFeature.State -ne "Enabled") {
    Write-Host "Installing IIS-ASP feature (may take a minute)..." -ForegroundColor Yellow
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASP            -NoRestart -ErrorAction SilentlyContinue | Out-Null
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIExtensions -NoRestart -ErrorAction SilentlyContinue | Out-Null
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-DefaultDocument -NoRestart -ErrorAction SilentlyContinue | Out-Null
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-StaticContent   -NoRestart -ErrorAction SilentlyContinue | Out-Null
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpErrors       -NoRestart -ErrorAction SilentlyContinue | Out-Null
} else {
    Write-Host "  [OK] IIS-ASP feature is enabled." -ForegroundColor Green
}

# ---------------------------------------------------------------
# 2. Unlock the <asp> and <defaultDocument> config sections at server level
#    so they can be set/overridden in the site's web.config.
# ---------------------------------------------------------------
$appcmd = "$env:WINDIR\System32\inetsrv\appcmd.exe"
if (Test-Path $appcmd) {
    Write-Host "Unlocking <asp> and <defaultDocument> sections at server level..." -ForegroundColor Yellow
    & $appcmd unlock config -section:system.webServer/asp            /commit:apphost 2>$null | Out-Null
    & $appcmd unlock config -section:system.webServer/defaultDocument /commit:apphost 2>$null | Out-Null
    Write-Host "  [OK] Sections unlocked." -ForegroundColor Green
} else {
    Write-Host "  [WARN] appcmd.exe not found - skipping section unlock." -ForegroundColor Yellow
}

# ---------------------------------------------------------------
# 3. Create or configure the application pool
#    Classic ASP requires: managedRuntimeVersion="" and managedPipelineMode="Classic"
# ---------------------------------------------------------------
$poolPath = "IIS:\AppPools\$AppPoolName"
if (-not (Test-Path $poolPath)) {
    Write-Host "Creating application pool '$AppPoolName'..." -ForegroundColor Yellow
    New-Item -Path $poolPath | Out-Null
}
Set-ItemProperty -Path $poolPath -Name managedRuntimeVersion  ""        # No .NET CLR
Set-ItemProperty -Path $poolPath -Name managedPipelineMode    "Classic"
Set-ItemProperty -Path $poolPath -Name enable32BitAppOnWin64  $false    -ErrorAction SilentlyContinue
Set-ItemProperty -Path $poolPath -Name processModel.identityType "ApplicationPoolIdentity" -ErrorAction SilentlyContinue
Write-Host "  [OK] Application pool configured (no managed code, Classic pipeline)." -ForegroundColor Green

# ---------------------------------------------------------------
# 4. Create or configure the website on port $Port
# ---------------------------------------------------------------
$sitePath = "IIS:\Sites\$SiteName"
$binding  = "*:${Port}:"
if (-not (Test-Path $sitePath)) {
    Write-Host "Creating site '$SiteName' on port $Port..." -ForegroundColor Yellow
    New-Item -Path $sitePath -PhysicalPath $PhysicalPath -Bindings @{protocol="http";bindingInformation=$binding} | Out-Null
} else {
    Set-ItemProperty -Path $sitePath -Name physicalPath $PhysicalPath -ErrorAction SilentlyContinue
}
Set-ItemProperty -Path $sitePath -Name applicationPool $AppPoolName -ErrorAction SilentlyContinue
Write-Host "  [OK] Site '$SiteName' -> http://localhost:$Port/ -> $PhysicalPath" -ForegroundColor Green

# ---------------------------------------------------------------
# 5. Enable ASP at the site level (now that the section is unlocked)
# ---------------------------------------------------------------
try {
    Set-WebConfigurationProperty -Filter "system.webServer/asp" -Name "enable" -Value "true" -Location $SiteName -ErrorAction Stop
    Set-WebConfigurationProperty -Filter "system.webServer/asp" -Name "scriptErrorSentToBrowser" -Value "true" -Location $SiteName -ErrorAction SilentlyContinue
    Set-WebConfigurationProperty -Filter "system.webServer/asp" -Name "bufferingOn" -Value "true" -Location $SiteName -ErrorAction SilentlyContinue
    Write-Host "  [OK] ASP enabled at site level." -ForegroundColor Green
} catch {
    Write-Host "  [WARN] Could not write ASP config via Set-WebConfigurationProperty: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "         You can enable it manually in IIS Manager -> $SiteName -> ASP -> enable = true." -ForegroundColor Yellow
}

# ---------------------------------------------------------------
# 6. Grant the app pool identity read+execute on the physical folder
# ---------------------------------------------------------------
try {
    $acl = Get-Acl -Path $PhysicalPath
    $identity      = "IIS AppPool\$AppPoolName"
    $fileSystemRights = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute
    $inheritanceFlags = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
    $propagationFlags = [System.Security.AccessControl.PropagationFlags]::None
    $accessType       = [System.Security.AccessControl.AccessControlType]::Allow
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $identity, $fileSystemRights, $inheritanceFlags, $propagationFlags, $accessType
    )
    # Avoid duplicate entries
    $acl.SetAccessRule($accessRule)
    Set-Acl -Path $PhysicalPath -AclObject $acl
    Write-Host "  [OK] Granted Read+Execute to '$identity' on $PhysicalPath" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] Could not set ACL: $($_.Exception.Message)" -ForegroundColor Yellow
}

# ---------------------------------------------------------------
# 7. Start the app pool and the site
# ---------------------------------------------------------------
try {
    $poolState = (Get-WebAppPoolState -Name $AppPoolName -ErrorAction SilentlyContinue).Value
    if ($poolState -ne "Started") { Start-WebAppPool -Name $AppPoolName -ErrorAction SilentlyContinue }
    Write-Host "  [OK] App pool '$AppPoolName' state: $((Get-WebAppPoolState -Name $AppPoolName -ErrorAction SilentlyContinue).Value)" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] App pool start: $($_.Exception.Message)" -ForegroundColor Yellow
}
try {
    $siteState = (Get-WebsiteState -Name $SiteName -ErrorAction SilentlyContinue).Value
    if ($siteState -ne "Started") { Start-Website -Name $SiteName -ErrorAction SilentlyContinue }
    Write-Host "  [OK] Site '$SiteName' state: $((Get-WebsiteState -Name $SiteName -ErrorAction SilentlyContinue).Value)" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] Site start: $($_.Exception.Message)" -ForegroundColor Yellow
}

# ---------------------------------------------------------------
# 8. Show handler mappings for ASP (sanity check)
# ---------------------------------------------------------------
Write-Host ""
Write-Host "ASP / ISAPI handler mappings at site level:" -ForegroundColor Cyan
try {
    Get-WebHandler -Location $SiteName -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match "ASP|ASPClassic|ISAPI" } |
        Select-Object Name, Path, Verb, Modules, ScriptProcessor |
        Format-Table -AutoSize
} catch {
    Write-Host "  (could not list handlers - check IIS Manager manually)" -ForegroundColor Yellow
}

# ---------------------------------------------------------------
# 9. Summary
# ---------------------------------------------------------------
Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  DONE. Open http://localhost:$Port/ in your browser."   -ForegroundColor White
Write-Host "  web.config sets login.asp as the default document,"     -ForegroundColor White
Write-Host "  so the root URL will load the login page."               -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "If you still see problems, run in an admin console:"
Write-Host "  iisreset"
Write-Host "And in IIS Manager verify:"
Write-Host "  - $SiteName -> ASP -> enable = true"
Write-Host "  - $SiteName -> Handler Mappings -> 'ASPClassic' exists"
Write-Host "  - $SiteName -> Basic Settings -> Connect as... test the path"
