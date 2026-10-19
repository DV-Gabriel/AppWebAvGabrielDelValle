<%@ Language=VBScript %>
<%
'============================================================
' logout.asp - Clears session and redirects to login
'============================================================

' Abandon the session (clears all session variables)
Session.Abandon()

' Redirect to login page
Response.Redirect "login.asp"
Response.End
%>
