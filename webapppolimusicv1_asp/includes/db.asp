<%
'============================================================
' db.asp - Database connection include file
' Database: SQL Server (BDD_PoliMusic)
'============================================================

Dim connString

' SQL Authentication using the usr_polimusic login created by the DB script
' Server: localhost, port 14333 (SSMS-style connection details adapted to ADO)
' connString uses SQLOLEDB with the port appended to Data Source
connString = "Provider=SQLOLEDB;Data Source=localhost,14333;Initial Catalog=BDD_PoliMusic;User ID=usr_polimusic;Password=Politecnica1;"

' --- Alternative: Windows Authentication ---
' connString = "Provider=SQLOLEDB;Data Source=localhost,14333;Initial Catalog=BDD_PoliMusic;Integrated Security=SSPI;"

' Global connection object
Dim conn
Set conn = Server.CreateObject("ADODB.Connection")
conn.ConnectionTimeout = 30
conn.CommandTimeout = 0

' Open with error handling so we see the real error message
On Error Resume Next
conn.Open connString

If Err.Number <> 0 Then
    Response.Status = "500 Internal Server Error"
    Response.ContentType = "text/html"
    Response.Write "<!DOCTYPE html><html><head><meta charset=""utf-8""></head><body>"
    Response.Write "<div style=""font-family:monospace;padding:20px;background:#1a1a2e;color:#eee;min-height:100vh;"">"
    Response.Write "<h2 style=""color:#1aa7ec;"">Database Connection Error</h2>"
    Response.Write "<p><strong>Error:</strong> " & Server.HTMLEncode(Err.Description) & "</p>"
    Response.Write "<p><strong>Source:</strong> " & Server.HTMLEncode(Err.Source) & "</p>"
    Response.Write "<p><strong>Number:</strong> " & Err.Number & " (0x" & Hex(Err.Number) & ")</p>"
    Response.Write "<hr>"
    Response.Write "<p>Connection string used:</p>"
    Response.Write "<pre>" & Server.HTMLEncode(connString) & "</pre>"
    Response.Write "<p>Possible fixes:</p>"
    Response.Write "<ul>"
    Response.Write "<li>Make sure SQL Server is running</li>"
    Response.Write "<li>Run the BDD_PoliMusic SQL script to create the database and the usr_polimusic login</li>"
    Response.Write "<li>Verify SQL Server is configured for SQL Authentication (mixed mode)</li>"
    Response.Write "</ul>"
    Response.Write "</div></body></html>"
    Response.End
End If
On Error GoTo 0

'============================================================
' Helper: Convert DB song path (~/folder/file) to app-relative URL
'============================================================
Function ResolveAppPath(ByVal dbPath)
    If IsNull(dbPath) Then
        ResolveAppPath = ""
    Else
        ' Replace ~/ prefix with empty string (relative to app root)
        ResolveAppPath = Replace(dbPath, "~/", "")
    End If
End Function
%>
