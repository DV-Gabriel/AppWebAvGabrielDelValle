<%@ Language=VBScript %>
<!--#include file="includes/db.asp"-->
<!--#include file="includes/auth.asp"-->
<%
'============================================================
' editSong.asp - Admin only: Edit an existing song
' Loads song by ID and updates on submit
'============================================================

Call RequireLogin()
Call RequireAdmin()

Dim songId, errorMsg
errorMsg = ""
songId = Request.QueryString("id")

If songId = "" Then songId = Request.Form("songId")

If songId = "" Then
    Response.Redirect "index.asp"
    Response.End
End If

' Handle form submission (update)
If Request.Form("action") = "update" Then
    Dim songName, songPath, plays
    songName = Trim(Request.Form("songName"))
    songPath = Trim(Request.Form("songPath"))
    plays    = Trim(Request.Form("plays"))

    If plays = "" Then plays = "0"

    If songName <> "" And songPath <> "" Then
        Dim sqlUpdate
        sqlUpdate = "UPDATE TBL_SONG SET " & _
                    "SONG_NAME = '" & Replace(songName, "'", "''") & "', " & _
                    "SONG_PATH = '" & Replace(songPath, "'", "''") & "', " & _
                    "PLAYS = " & Replace(plays, "'", "''") & " " & _
                    "WHERE ID_SONG = " & Replace(songId, "'", "''")

        conn.Execute sqlUpdate

        conn.Close
        Set conn = Nothing

        Response.Redirect "index.asp?msg=updated"
        Response.End
    Else
        errorMsg = "Song Name and Song Path are required."
    End If
End If

' Load existing song data
Dim rsSong, sqlSelect
Set rsSong = Server.CreateObject("ADODB.Recordset")
sqlSelect = "SELECT ID_SONG, SONG_NAME, SONG_PATH, PLAYS " & _
            "FROM TBL_SONG WHERE ID_SONG = " & Replace(songId, "'", "''")
rsSong.Open sqlSelect, conn, 0, 1

If rsSong.EOF Then
    rsSong.Close
    Set rsSong = Nothing
    conn.Close
    Set conn = Nothing
    Response.Redirect "index.asp"
    Response.End
End If

Dim editName, editPath, editPlays
editName  = rsSong("SONG_NAME")
editPath  = rsSong("SONG_PATH")
editPlays = rsSong("PLAYS")

rsSong.Close
Set rsSong = Nothing
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PoliMusic - Edit Song</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="app-layout">

    <!-- ===== SIDEBAR ===== -->
    <aside class="sidebar">
        <div class="sidebar-logo">
            <span class="logo-icon">&#9835;</span><span>PoliMusic</span>
        </div>
        <ul class="sidebar-nav">
            <li><a href="index.asp"><span class="nav-icon">&#9835;</span><span>Songs</span></a></li>
            <li><a href="addSong.asp"><span class="nav-icon">&#43;</span><span>Add Song</span></a></li>
        </ul>
        <div class="sidebar-user">
            <% If Not IsNull(Session("userPhoto")) And Session("userPhoto") <> "" Then %>
                <img src="<%= ResolveAppPath(Session("userPhoto")) %>" alt="User"
                     onerror="this.src='userImages/default.jpg'">
            <% Else %>
                <img src="userImages/default.jpg" alt="User">
            <% End If %>
            <div class="user-info">
                <div class="user-name"><%= Server.HTMLEncode(Session("username")) %></div>
                <div class="user-role">Admin</div>
            </div>
        </div>
        <a href="logout.asp" class="logout-link">
            <span>&#8656;</span><span>Logout</span>
        </a>
    </aside>

    <!-- ===== MAIN CONTENT ===== -->
    <div class="main-content">
        <div class="topbar">
            <div class="welcome-message">
                Welcome, <strong><%= Server.HTMLEncode(Session("username")) %></strong>
                <span style="color: var(--blue-primary); font-size: 13px;">(Admin)</span>
            </div>
            <div class="topbar-actions">
                <a href="index.asp" class="btn-secondary" style="padding: 10px 20px;">Back to List</a>
            </div>
        </div>

        <div class="form-page">
            <div class="form-card">
                <h2><span class="blue-bar"></span>Edit Song</h2>

                <% If errorMsg <> "" Then %>
                    <div class="login-error"><%= errorMsg %></div>
                <% End If %>

                <form method="post" action="editSong.asp">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="songId" value="<%= songId %>">

                    <div class="form-group">
                        <label for="songName">Song Name</label>
                        <input type="text" id="songName" name="songName"
                               maxlength="50"
                               value="<%= Server.HTMLEncode(editName) %>">
                    </div>

                    <div class="form-group">
                        <label for="songPath">Song Path</label>
                        <input type="text" id="songPath" name="songPath"
                               maxlength="255"
                               value="<%= Server.HTMLEncode(editPath) %>">
                        <div class="field-hint">
                            Use the format: ~/songFiles/filename.mp3
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="plays">Plays</label>
                        <input type="text" id="plays" name="plays"
                               maxlength="10"
                               value="<%= Server.HTMLEncode(editPlays) %>">
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn-blue">Update Song</button>
                        <a href="index.asp" class="btn-secondary">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
</body>
</html>
