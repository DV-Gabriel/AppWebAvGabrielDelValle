using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using SongEntity = WebAppPoliMusicV2.Entities.Song;

namespace WebAppPoliMusicV2.DAL
{
    /// <summary>
    /// Repositorio de acceso a datos de la tabla TBL_SONG.
    /// Aqui solo vive el SQL: no se valida nada del negocio (eso es de la BLL).
    /// </summary>
    public class Song
    {
        /// <summary>
        /// Nombre de la cadena de conexion del modulo de canciones. Si no existe
        /// en el Web.config se usa la cadena general del proyecto.
        /// </summary>
        private const string ConnectionStringName = "PoliMusicDB";

        private const string FallbackConnectionStringName = "BDD_PoliMusicConnectionString";

        private readonly string _connectionString;

        /// <summary>
        /// Columnas que se devuelven siempre. El artista y el album se obtienen
        /// con subconsultas para poder pintar la lista estilo Spotify sin
        /// romper el modelo de la tabla TBL_SONG.
        /// </summary>
        private const string SelectBase =
            "SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, ISNULL(s.PLAYS, 0) AS PLAYS, " +
            "       ISNULL((SELECT TOP 1 a.ARTIST_NAME + ISNULL(' ' + a.ARTIST_LASTNAME, '') " +
            "               FROM TBL_PLAYER p INNER JOIN TBL_ARTIST a ON a.ID_ARTIST = p.ID_ARTIST " +
            "               WHERE p.ID_SONG = s.ID_SONG), '') AS ARTIST_NAME, " +
            "       ISNULL((SELECT TOP 1 al.TITLE_ALBUM " +
            "               FROM TBL_TRACKLIST t INNER JOIN TBL_ALBUM al ON al.ID_ALBUM = t.ID_ALBUM " +
            "               WHERE t.ID_SONG = s.ID_SONG), '') AS ALBUM_TITLE " +
            "FROM TBL_SONG s ";

        /// <summary>
        /// Filtro de busqueda: por nombre de cancion, artista o album.
        /// </summary>
        private const string SearchWhere =
            " WHERE s.SONG_NAME LIKE @TERM " +
            "    OR EXISTS (SELECT 1 FROM TBL_PLAYER p2 " +
            "               INNER JOIN TBL_ARTIST a2 ON a2.ID_ARTIST = p2.ID_ARTIST " +
            "               WHERE p2.ID_SONG = s.ID_SONG " +
            "                 AND (a2.ARTIST_NAME LIKE @TERM OR a2.ARTIST_LASTNAME LIKE @TERM)) " +
            "    OR EXISTS (SELECT 1 FROM TBL_TRACKLIST t2 " +
            "               INNER JOIN TBL_ALBUM al2 ON al2.ID_ALBUM = t2.ID_ALBUM " +
            "               WHERE t2.ID_SONG = s.ID_SONG AND al2.TITLE_ALBUM LIKE @TERM) ";

        public Song()
        {
            ConnectionStringSettings settings = ConfigurationManager.ConnectionStrings[ConnectionStringName];

            if (settings == null || string.IsNullOrEmpty(settings.ConnectionString))
            {
                settings = ConfigurationManager.ConnectionStrings[FallbackConnectionStringName];
            }

            if (settings == null || string.IsNullOrEmpty(settings.ConnectionString))
            {
                throw new ConfigurationErrorsException(
                    "No se encontró la cadena de conexión '" + ConnectionStringName +
                    "' (ni la cadena general '" + FallbackConnectionStringName + "') en el Web.config.");
            }

            _connectionString = settings.ConnectionString;
        }

        #region Consultas

        /// <summary>
        /// Devuelve todas las canciones ordenadas alfabeticamente.
        /// </summary>
        public List<SongEntity> GetAll()
        {
            List<SongEntity> songs = new List<SongEntity>();

            using (SqlConnection connection = new SqlConnection(_connectionString))
            using (SqlCommand command = new SqlCommand(SelectBase + "ORDER BY s.SONG_NAME ASC", connection))
            {
                connection.Open();
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        songs.Add(Map(reader));
                    }
                }
            }

            return songs;
        }

        /// <summary>
        /// Busca canciones por nombre, artista o album.
        /// </summary>
        public List<SongEntity> Search(string term)
        {
            List<SongEntity> songs = new List<SongEntity>();

            using (SqlConnection connection = new SqlConnection(_connectionString))
            using (SqlCommand command = new SqlCommand(SelectBase + SearchWhere + "ORDER BY s.SONG_NAME ASC", connection))
            {
                command.Parameters.Add("@TERM", SqlDbType.VarChar, 120).Value = "%" + term + "%";

                connection.Open();
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        songs.Add(Map(reader));
                    }
                }
            }

            return songs;
        }

        /// <summary>
        /// Devuelve una cancion por su llave primaria o null si no existe.
        /// </summary>
        public SongEntity GetById(int idSong)
        {
            using (SqlConnection connection = new SqlConnection(_connectionString))
            using (SqlCommand command = new SqlCommand(SelectBase + "WHERE s.ID_SONG = @ID_SONG", connection))
            {
                command.Parameters.Add("@ID_SONG", SqlDbType.Int).Value = idSong;

                connection.Open();
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        return Map(reader);
                    }
                }
            }

            return null;
        }

        /// <summary>
        /// Comprueba si ya existe una cancion con ese nombre (ignorando la que se edita).
        /// </summary>
        public bool ExistsName(string songName, int excludeIdSong)
        {
            const string sql = "SELECT COUNT(*) FROM TBL_SONG WHERE SONG_NAME = @SONG_NAME AND ID_SONG <> @ID_SONG;";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.Add("@SONG_NAME", SqlDbType.VarChar, 50).Value = songName;
                command.Parameters.Add("@ID_SONG", SqlDbType.Int).Value = excludeIdSong;

                connection.Open();
                return Convert.ToInt32(command.ExecuteScalar()) > 0;
            }
        }

        #endregion

        #region Insercion / actualizacion / borrado

        /// <summary>
        /// Inserta una cancion y devuelve el ID generado por el IDENTITY.
        /// </summary>
        public int Insert(SongEntity song)
        {
            const string sql =
                "INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS) VALUES (@SONG_NAME, @SONG_PATH, @PLAYS); " +
                "SELECT CAST(SCOPE_IDENTITY() AS int);";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                AddSongParameters(command, song);

                connection.Open();
                object result = command.ExecuteScalar();
                return result == null || result == DBNull.Value ? 0 : Convert.ToInt32(result);
            }
        }

        /// <summary>
        /// Actualiza una cancion existente. Devuelve las filas afectadas.
        /// </summary>
        public int Update(SongEntity song)
        {
            const string sql =
                "UPDATE TBL_SONG SET SONG_NAME = @SONG_NAME, SONG_PATH = @SONG_PATH, PLAYS = @PLAYS " +
                "WHERE ID_SONG = @ID_SONG;";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                AddSongParameters(command, song);
                command.Parameters.Add("@ID_SONG", SqlDbType.Int).Value = song.IdSong;

                connection.Open();
                return command.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Suma una reproduccion a la cancion indicada.
        /// </summary>
        public int IncrementPlays(int idSong)
        {
            const string sql = "UPDATE TBL_SONG SET PLAYS = ISNULL(PLAYS, 0) + 1 WHERE ID_SONG = @ID_SONG;";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.Add("@ID_SONG", SqlDbType.Int).Value = idSong;

                connection.Open();
                return command.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Elimina la cancion y sus relaciones (TBL_PLAYLIST_SONG, TBL_TRACKLIST y TBL_PLAYER)
        /// dentro de una transaccion para no chocar con las llaves foraneas.
        /// </summary>
        /// <param name="idSong">Cancion a eliminar.</param>
        /// <param name="playlistsAffected">Cantidad de playlists de las que se quito.</param>
        public int DeleteCascade(int idSong, out int playlistsAffected)
        {
            const string countPlaylistsSql = "SELECT COUNT(*) FROM TBL_PLAYLIST_SONG WHERE ID_SONG = @ID_SONG;";
            const string deletePlaylistSongsSql = "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_SONG = @ID_SONG;";
            const string deleteTracklistSql = "DELETE FROM TBL_TRACKLIST WHERE ID_SONG = @ID_SONG;";
            const string deletePlayerSql = "DELETE FROM TBL_PLAYER WHERE ID_SONG = @ID_SONG;";
            const string deleteSongSql = "DELETE FROM TBL_SONG WHERE ID_SONG = @ID_SONG;";

            playlistsAffected = 0;

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                connection.Open();

                using (SqlTransaction transaction = connection.BeginTransaction())
                {
                    try
                    {
                        playlistsAffected = ExecuteInt(connection, transaction, countPlaylistsSql, idSong);
                        ExecuteNonQuery(connection, transaction, deletePlaylistSongsSql, idSong);
                        ExecuteNonQuery(connection, transaction, deleteTracklistSql, idSong);
                        ExecuteNonQuery(connection, transaction, deletePlayerSql, idSong);
                        int rows = ExecuteNonQuery(connection, transaction, deleteSongSql, idSong);

                        transaction.Commit();
                        return rows;
                    }
                    catch
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
            }
        }

        /// <summary>
        /// Indica cuantas playlists contienen la cancion (se usa como advertencia).
        /// </summary>
        public int CountPlaylists(int idSong)
        {
            const string sql = "SELECT COUNT(*) FROM TBL_PLAYLIST_SONG WHERE ID_SONG = @ID_SONG;";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.Add("@ID_SONG", SqlDbType.Int).Value = idSong;

                connection.Open();
                return Convert.ToInt32(command.ExecuteScalar());
            }
        }

        #endregion

        #region Apoyo

        /// <summary>
        /// Convierte la fila actual del reader en una entidad Song.
        /// </summary>
        private static SongEntity Map(SqlDataReader reader)
        {
            SongEntity song = new SongEntity();

            song.IdSong = reader.GetInt32(reader.GetOrdinal("ID_SONG"));
            song.SongName = reader.GetString(reader.GetOrdinal("SONG_NAME"));
            song.SongPath = reader.GetString(reader.GetOrdinal("SONG_PATH"));
            song.Plays = reader.GetInt32(reader.GetOrdinal("PLAYS"));
            song.ArtistName = reader.GetString(reader.GetOrdinal("ARTIST_NAME"));
            song.AlbumTitle = reader.GetString(reader.GetOrdinal("ALBUM_TITLE"));

            return song;
        }

        private static void AddSongParameters(SqlCommand command, SongEntity song)
        {
            command.Parameters.Add("@SONG_NAME", SqlDbType.VarChar, 50).Value = song.SongName;
            command.Parameters.Add("@SONG_PATH", SqlDbType.VarChar, 255).Value = song.SongPath;
            command.Parameters.Add("@PLAYS", SqlDbType.Int).Value = song.Plays;
        }

        private static int ExecuteNonQuery(SqlConnection connection, SqlTransaction transaction, string sql, int idSong)
        {
            using (SqlCommand command = new SqlCommand(sql, connection, transaction))
            {
                command.Parameters.Add("@ID_SONG", SqlDbType.Int).Value = idSong;
                return command.ExecuteNonQuery();
            }
        }

        private static int ExecuteInt(SqlConnection connection, SqlTransaction transaction, string sql, int idSong)
        {
            using (SqlCommand command = new SqlCommand(sql, connection, transaction))
            {
                command.Parameters.Add("@ID_SONG", SqlDbType.Int).Value = idSong;
                return Convert.ToInt32(command.ExecuteScalar());
            }
        }

        #endregion
    }
}
