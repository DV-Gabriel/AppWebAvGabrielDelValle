# Project Memory - PoliMusic ASP

## Project Overview
- **Type**: Classic ASP web application (Spotify clone, blue theme)
- **Database**: SQL Server (BDD_PoliMusic)
- **Path**: C:/Users/WebAvanzadas/source/AppWebAvGabrielDelValle/webapppolimusicv1_asp/

## Database Connection
- Provider: SQLOLEDB (ADO, adapted from .NET connection string)
- Data Source: localhost,14333 (SQL Server on port 14333, not default 1433)
- Auth: SQL login usr_polimusic / Politecnica1 (active in db.asp)
- Alternative: Windows Authentication (Integrated Security=SSPI, commented)
- File: includes/db.asp

## Key Conventions
- Session vars: userId, username, userPhoto, userType
- USER_TYPE: 0 = normal, 1 = admin
- Song paths in DB use ~/ prefix; ResolveAppPath() converts to relative URL
- Blue accent color: #1aa7ec (CSS variable --blue-primary)
