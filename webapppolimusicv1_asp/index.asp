<%@ Language=VBScript %>
<!--#include file="includes/db.asp"-->
<!--#include file="includes/auth.asp"-->
<%
'============================================================
' index.asp - Main page
' Shows welcome message, song list table, audio player
' Admin sees CRUD action buttons
'============================================================

' Ensure user is logged in
Call RequireLogin()

Dim userIsAdmin
userIsAdmin = IsAdmin()

Dim successMsg
successMsg = Request.QueryString("msg")
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PoliMusic - Song List</title>
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
            <li><a href="index.asp" class="active"><span class="nav-icon">&#9835;</span><span>Songs</span></a></li>
            <% If userIsAdmin Then %>
                <li><a href="addSong.asp"><span class="nav-icon">&#43;</span><span>Add Song</span></a></li>
            <% End If %>
        </ul>

        <div class="sidebar-user">
            <% Dim userPhoto %>
            <% If Not IsNull(Session("userPhoto")) And Session("userPhoto") <> "" Then %>
                <% userPhoto = ResolveAppPath(Session("userPhoto")) %>
                <img src="<%= userPhoto %>" alt="User Photo"
                     onerror="this.src='userImages/default.jpg'">
            <% Else %>
                <img src="userImages/default.jpg" alt="User Photo">
            <% End If %>
            <div class="user-info">
                <div class="user-name"><%= Server.HTMLEncode(Session("username")) %></div>
                <div class="user-role"><% If userIsAdmin Then %>Admin<% Else %>User<% End If %></div>
            </div>
        </div>

        <a href="logout.asp" class="logout-link">
            <span>&#8656;</span><span>Logout</span>
        </a>
    </aside>

    <!-- ===== MAIN CONTENT ===== -->
    <div class="main-content">

        <!-- Top bar with welcome message -->
        <div class="topbar">
            <div class="welcome-message">
                Welcome, <strong><%= Server.HTMLEncode(Session("username")) %></strong>
                <% If userIsAdmin Then %>
                    <span style="color: var(--blue-primary); font-size: 13px;">(Admin)</span>
                <% End If %>
            </div>
            <div class="topbar-actions">
                <% If userIsAdmin Then %>
                    <a href="addSong.asp" class="btn-add-song">
                        <span>+</span> Add Song
                    </a>
                <% End If %>
                <a href="logout.asp" class="btn-secondary" style="padding: 10px 20px;">Logout</a>
            </div>
        </div>

        <!-- Song List Section -->
        <div class="song-list-section">

            <% If successMsg = "added" Then %>
                <div class="success-message">Song added successfully!</div>
            <% ElseIf successMsg = "updated" Then %>
                <div class="success-message">Song updated successfully!</div>
            <% ElseIf successMsg = "deleted" Then %>
                <div class="success-message">Song deleted successfully!</div>
            <% End If %>

            <h2 class="section-title">
                <span class="blue-bar"></span>Song List
            </h2>

            <div class="song-table-container">
                <table class="song-table">
                    <thead>
                        <tr>
                            <th class="col-index">#</th>
                            <th class="col-name">Song Name</th>
                            <th class="col-plays">Plays</th>
                            <th class="col-play">Play</th>
                            <% If userIsAdmin Then %>
                                <th class="col-actions">Actions</th>
                            <% End If %>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        Dim rsSongs, sqlSongs
                        Set rsSongs = Server.CreateObject("ADODB.Recordset")
                        sqlSongs = "SELECT ID_SONG, SONG_NAME, SONG_PATH, PLAYS " & _
                                   "FROM TBL_SONG ORDER BY ID_SONG ASC"
                        rsSongs.Open sqlSongs, conn, 0, 1

                        Dim counter
                        counter = 0

                        Dim colSpan
                        If userIsAdmin Then
                            colSpan = 5
                        Else
                            colSpan = 4
                        End If

                        If rsSongs.EOF Then
                            ' No songs in database
                            Response.Write "<tr><td colspan='" & colSpan & "' class='empty-state'>" & _
                                           "<div class='empty-icon'>&#9835;</div>" & _
                                           "<p>No songs available.</p></td></tr>"
                        Else
                            Do While Not rsSongs.EOF
                                counter = counter + 1
                                Dim songId, songName, songPath, plays, songUrl
                                songId   = rsSongs("ID_SONG")
                                songName = rsSongs("SONG_NAME")
                                songPath = rsSongs("SONG_PATH")
                                plays    = rsSongs("PLAYS")

                                ' Convert ~/path to relative app path
                                songUrl = ResolveAppPath(songPath)
                        %>
                        <tr>
                            <td class="col-index"><%= counter %></td>
                            <td class="col-name"><%= Server.HTMLEncode(songName) %></td>
                            <td class="col-plays"><%= plays %></td>
                            <td class="col-play">
                                <button class="play-btn" onclick="playSong('<%= songUrl %>', '<%= Server.HTMLEncode(songName) %>')">
                                    &#9654;
                                </button>
                            </td>
                            <% If userIsAdmin Then %>
                                <td class="col-actions">
                                    <a href="editSong.asp?id=<%= songId %>" class="action-btn">Edit</a>
                                    <a href="deleteSong.asp?id=<%= songId %>" class="action-btn danger"
                                       onclick="return confirm('Are you sure you want to delete this song?');">Delete</a>
                                </td>
                            <% End If %>
                        </tr>
                        <%
                                rsSongs.MoveNext
                            Loop
                        End If

                        rsSongs.Close
                        Set rsSongs = Nothing
                        conn.Close
                        Set conn = Nothing
                        %>
                    </tbody>
                </table>
            </div>

        </div>

        <!-- Fixed audio player bar (hidden until a song is played) -->
        <div class="audio-player-bar" id="playerBar">
            <div class="player-song-info">
                <div>
                    <div class="player-song-label">Now Playing</div>
                    <div class="player-song-name" id="playerSongName">-</div>
                </div>
            </div>
            <div class="player-audio">
                <audio id="audioPlayer" controls autoplay>
                    Your browser does not support the audio element.
                </audio>
            </div>
        </div>

    </div>
</div>

<script>
    function playSong(songUrl, songName) {
        var audio = document.getElementById('audioPlayer');
        var playerBar = document.getElementById('playerBar');
        var nameDisplay = document.getElementById('playerSongName');

        audio.src = songUrl;
        nameDisplay.textContent = songName;
        playerBar.classList.add('visible');
        audio.play().catch(function() {
            // Autoplay might be blocked; user can click play
        });

        // Highlight the playing button
        document.querySelectorAll('.play-btn').forEach(function(btn) {
            btn.classList.remove('playing');
        });
        event.currentTarget.classList.add('playing');
    }
</script>
</body>
</html>
