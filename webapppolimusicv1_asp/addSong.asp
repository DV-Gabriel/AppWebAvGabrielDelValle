<%@ Language=VBScript %>
<!--#include file="includes/db.asp"-->
<!--#include file="includes/auth.asp"-->
<%
'============================================================
' addSong.asp - Admin only: Add a new song
' Inserts a new record into TBL_SONG
'============================================================

Call RequireLogin()
Call RequireAdmin()

Dim errorMsg
errorMsg = ""

If Request.Form("action") = "save" Then
    Dim songName, songPath, plays
    songName = Trim(Request.Form("songName"))
    songPath = Trim(Request.Form("songPath"))
    plays    = Trim(Request.Form("plays"))

    ' Default plays to 0 if empty
    If plays = "" Then plays = "0"

    If songName <> "" And songPath <> "" Then
        Dim sql
        sql = "INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS) " & _
              "VALUES ('" & Replace(songName, "'", "''") & "', " & _
              "'" & Replace(songPath, "'", "''") & "', " & _
              "" & Replace(plays, "'", "''") & ")"

        conn.Execute sql

        conn.Close
        Set conn = Nothing

        Response.Redirect "index.asp?msg=added"
        Response.End
    Else
        errorMsg = "Song Name and Song Path are required."
    End If
End If
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PoliMusic - Add Song</title>
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
            <li><a href="addSong.asp" class="active"><span class="nav-icon">&#43;</span><span>Add Song</span></a></li>
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
                <h2><span class="blue-bar"></span>Add New Song</h2>

                <% If errorMsg <> "" Then %>
                    <div class="login-error"><%= errorMsg %></div>
                <% End If %>

                <form method="post" action="addSong.asp">
                    <input type="hidden" name="action" value="save">

                    <div class="form-group">
                        <label for="songName">Song Name</label>
                        <input type="text" id="songName" name="songName"
                               placeholder="Enter song name" maxlength="50"
                               value="<%= Server.HTMLEncode(Request.Form("songName")) %>">
                    </div>

                    <div class="form-group">
                        <label for="songPath">Song Path</label>
                        <input type="text" id="songPath" name="songPath"
                               placeholder="~/songFiles/your-song.mp3" maxlength="255"
                               value="<%= Server.HTMLEncode(Request.Form("songPath")) %>">
                        <div class="field-hint">
                            Use the format: ~/songFiles/filename.mp3
                            (place the actual file in the <strong>songFiles/</strong> folder)
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="plays">Plays (initial play count)</label>
                        <input type="text" id="plays" name="plays"
                               placeholder="0" maxlength="10"
                               value="<%= Server.HTMLEncode(Request.Form("plays")) %>">
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn-blue">Save Song</button>
                        <a href="index.asp" class="btn-secondary">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
</body>
</html>
