<%@ Language=VBScript %>
<!--#include file="includes/db.asp"-->
<!--#include file="includes/auth.asp"-->
<%
'============================================================
' deleteSong.asp - Admin only: Delete a song by ID
' Shows confirmation page; deletes on confirm
'============================================================

Call RequireLogin()
Call RequireAdmin()

Dim songId, confirmed
songId    = Request.QueryString("id")
If songId = "" Then songId = Request.Form("songId")
confirmed = Request.Form("confirmed")

' If confirmed, delete the song
If confirmed = "yes" And songId <> "" Then
    Dim sqlDelete
    sqlDelete = "DELETE FROM TBL_SONG WHERE ID_SONG = " & Replace(songId, "'", "''")
    conn.Execute sqlDelete

    conn.Close
    Set conn = Nothing

    Response.Redirect "index.asp?msg=deleted"
    Response.End
End If

' Show confirmation page
If songId = "" Then
    Response.Redirect "index.asp"
    Response.End
End If

' Load song info for confirmation
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

Dim delName, delPlays
delName  = rsSong("SONG_NAME")
delPlays = rsSong("PLAYS")

rsSong.Close
Set rsSong = Nothing
conn.Close
Set conn = Nothing
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PoliMusic - Delete Song</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="app-layout">

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
                <h2><span class="blue-bar"></span>Confirm Deletion</h2>

                <div class="login-error" style="margin-bottom: 24px;">
                    Are you sure you want to delete this song? This action cannot be undone.
                </div>

                <table class="song-table" style="margin-bottom: 24px;">
                    <thead>
                        <tr>
                            <th>Song Name</th>
                            <th>Plays</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td class="col-name"><%= Server.HTMLEncode(delName) %></td>
                            <td class="col-plays"><%= delPlays %></td>
                        </tr>
                    </tbody>
                </table>

                <form method="post" action="deleteSong.asp">
                    <input type="hidden" name="songId" value="<%= songId %>">
                    <input type="hidden" name="confirmed" value="yes">
                    <div class="form-actions">
                        <button type="submit" class="btn-blue" style="background-color: var(--danger);">Yes, Delete</button>
                        <a href="index.asp" class="btn-secondary">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
</body>
</html>
