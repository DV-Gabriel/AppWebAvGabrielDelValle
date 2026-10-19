<%
'============================================================
' auth.asp - Authentication and authorization include
' Checks session variables and redirects to login if needed
'============================================================

' Check if user is logged in; if not, redirect to login.asp
Sub RequireLogin()
    If Session("username") = "" Or IsNull(Session("username")) Then
        Response.Redirect "login.asp"
        Response.End
    End If
End Sub

' Check if the logged-in user is admin (USER_TYPE = 1)
Function IsAdmin()
    If CStr(Session("userType")) = "1" Then
        IsAdmin = True
    Else
        IsAdmin = False
    End If
End Function

' Require admin role; if not admin, show access denied
Sub RequireAdmin()
    If Not IsAdmin() Then
        Response.Status = "403 Forbidden"
        Response.Write "<!DOCTYPE html><html><head><meta charset=""utf-8"">"
        Response.Write "<link rel=""stylesheet"" href=""css/style.css"">"
        Response.Write "</head><body><div class=""access-denied"">"
        Response.Write "<h1>403 - Access Denied</h1>"
        Response.Write "<p>You do not have permission to perform this action.</p>"
        Response.Write "<p>Only <strong>admin</strong> users can manage songs.</p>"
        Response.Write "<a href=""index.asp"" class=""btn-blue"">Back to Song List</a>"
        Response.Write "</div></body></html>"
        Response.End
    End If
End Sub
%>
