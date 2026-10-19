<%@ Language=VBScript %>
<!--#include file="includes/db.asp"-->
<%
'============================================================
' login.asp - Login page for PoliMusic
' Authenticates user against TBL_USER table
' Sets session variables: username, userType, userId, userPhoto
'============================================================

Dim errorMsg
errorMsg = ""

If Request.Form("action") = "login" Then
    Dim username, password
    username = Trim(Request.Form("username"))
    password = Trim(Request.Form("password"))

    If username <> "" And password <> "" Then
        Dim rs, sql
        Set rs = Server.CreateObject("ADODB.Recordset")
        sql = "SELECT ID_USER, USERNAME, PASSWORD, USER_PHOTO, USER_TYPE " & _
              "FROM TBL_USER WHERE USERNAME = '" & Replace(username, "'", "''") & "' " & _
              "AND PASSWORD = '" & Replace(password, "'", "''") & "'"
        rs.Open sql, conn, 0, 1

        If Not rs.EOF Then
            ' Login successful - set session variables
            Session("userId")     = rs("ID_USER")
            Session("username")   = rs("USERNAME")
            Session("userPhoto")  = rs("USER_PHOTO")
            Session("userType")   = rs("USER_TYPE")

            rs.Close
            Set rs = Nothing
            conn.Close
            Set conn = Nothing

            Response.Redirect "index.asp"
            Response.End
        Else
            errorMsg = "Invalid username or password. Please try again."
        End If

        rs.Close
        Set rs = Nothing
    Else
        errorMsg = "Please enter both username and password."
    End If
End If

If Not (conn Is Nothing) Then
    If conn.State <> 0 Then conn.Close
    Set conn = Nothing
End If
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PoliMusic - Login</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body class="login-body">
    <div class="login-container">
        <div class="login-logo">
            <span class="logo-icon">&#9835;</span>PoliMusic
        </div>
        <p class="login-subtitle">Sign in to your music world</p>

        <% If errorMsg <> "" Then %>
            <div class="login-error"><%= errorMsg %></div>
        <% End If %>

        <form class="login-form" method="post" action="login.asp">
            <input type="hidden" name="action" value="login">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username"
                       placeholder="Enter your username"
                       value="<%= Server.HTMLEncode(Request.Form("username")) %>">
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password"
                       placeholder="Enter your password">
            </div>
            <button type="submit" class="btn-blue">LOG IN</button>
        </form>

        <div class="login-hint">
            <strong>Demo credentials:</strong><br>
            Normal user: <strong>userNormal</strong> / <strong>12345678</strong><br>
            Admin user: <strong>userAdmin</strong> / <strong>12345678</strong>
        </div>
    </div>
</body>
</html>
