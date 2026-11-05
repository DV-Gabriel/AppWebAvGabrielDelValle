# PoliMusic V3 - Project Memory

## Architecture
- N-layer project: EntityLayer.PoliMusicV3 → DAL.PoliMusicV → BLL.PoliMusicV3 → WebAppPoliMusicV3
- Framework: ASP.NET Web Forms 4.8
- DB: SQL Server (BDD_PoliMusic), tables: TBL_USER, TBL_SONG, TBL_ARTIST, TBL_ALBUM, TBL_PLAYER, TBL_TRACKLIST, TBL_PLAYLIST_SONG
- Solution: SlnAppPoliMusic.slnx

## Conventions
- DAL reads connection string from Web.config: "PoliMusicDB" (fallback: "BDD_PoliMusicConnectionString")
- BLL uses SongResult pattern (Success + Message) for operation results
- Session key for logged user: Constants.USER ("USER")
- Password hashing: SHA1 (GeneratePasswordHash)
- UI theme: blue-purple (Spotify-like dark theme)

## User flow
- Login → Songs.aspx (redirects to Login if no session)
- Default.aspx shows "Hola, [username]"
- Songs.aspx shows user name in topbar user-chip
