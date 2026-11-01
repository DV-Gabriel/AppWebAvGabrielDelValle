using System;
using System.Collections.Generic;
using System.Web;

namespace WebAppPoliMusicV2.Entities
{
    /// <summary>
    /// Modelo que representa una cancion de la tabla TBL_SONG.
    /// Contiene las mismas columnas de la tabla mas dos propiedades de
    /// apoyo (ArtistName y AlbumTitle) que se llenan con los JOIN de la DAL
    /// para poder mostrar la informacion como en Spotify.
    /// </summary>
    public class Song
    {
        // ===== Campos privados (atributos) =====
        private int _idSong;
        private string _songName;
        private string _songPath;
        private int _plays;

        // Propiedades de solo lectura para la vista (no se guardan en TBL_SONG)
        private string _artistName;
        private string _albumTitle;

        /// <summary>
        /// Constructor por defecto. Inicializa los textos para evitar NullReferenceException.
        /// </summary>
        public Song()
        {
            _idSong = 0;
            _songName = string.Empty;
            _songPath = string.Empty;
            _plays = 0;
            _artistName = string.Empty;
            _albumTitle = string.Empty;
        }

        /// <summary>
        /// Constructor con los datos propios de la tabla.
        /// </summary>
        public Song(int idSong, string songName, string songPath, int plays)
        {
            _idSong = idSong;
            _songName = songName;
            _songPath = songPath;
            _plays = plays;
            _artistName = string.Empty;
            _albumTitle = string.Empty;
        }

        /// <summary>
        /// ID_SONG - Llave primaria (IDENTITY).
        /// </summary>
        public int IdSong
        {
            get { return _idSong; }
            set { _idSong = value; }
        }

        /// <summary>
        /// SONG_NAME - Nombre de la cancion (varchar 50, obligatorio).
        /// </summary>
        public string SongName
        {
            get { return _songName; }
            set { _songName = value; }
        }

        /// <summary>
        /// SONG_PATH - Ruta virtual del archivo de audio (varchar 255, obligatorio).
        /// Ejemplo: ~/SongFiles/mi-cancion.mp3
        /// </summary>
        public string SongPath
        {
            get { return _songPath; }
            set { _songPath = value; }
        }

        /// <summary>
        /// PLAYS - Numero de reproducciones acumuladas (int, admite nulos en la BD).
        /// </summary>
        public int Plays
        {
            get { return _plays; }
            set { _plays = value; }
        }

        /// <summary>
        /// Nombre del artista obtenido de TBL_ARTIST mediante TBL_PLAYER.
        /// No se persiste en TBL_SONG, solo se usa para mostrar en pantalla.
        /// </summary>
        public string ArtistName
        {
            get { return _artistName; }
            set { _artistName = value; }
        }

        /// <summary>
        /// Titulo del album obtenido de TBL_ALBUM mediante TBL_TRACKLIST.
        /// No se persiste en TBL_SONG, solo se usa para mostrar en pantalla.
        /// </summary>
        public string AlbumTitle
        {
            get { return _albumTitle; }
            set { _albumTitle = value; }
        }

        /// <summary>
        /// Nombre del archivo fisico que se extrae de SONG_PATH.
        /// </summary>
        public string FileName
        {
            get
            {
                if (string.IsNullOrEmpty(_songPath))
                {
                    return string.Empty;
                }

                int index = _songPath.LastIndexOf('/');
                return index >= 0 ? _songPath.Substring(index + 1) : _songPath;
            }
        }

        /// <summary>
        /// Indica si la cancion ya existe en la base de datos.
        /// </summary>
        public bool IsNew
        {
            get { return _idSong <= 0; }
        }

        /// <summary>
        /// Devuelve una representacion corta de la entidad (util para depurar).
        /// </summary>
        public override string ToString()
        {
            return _idSong + " - " + _songName + " (" + _plays + " reproducciones)";
        }
    }
}
