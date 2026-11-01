using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.IO;
using System.Text;
using System.Web;
using SongEntity = WebAppPoliMusicV2.Entities.Song;
using SongRepository = WebAppPoliMusicV2.DAL.Song;

namespace WebAppPoliMusicV2.BLL
{
    /// <summary>
    /// Resultado de una operacion de negocio: si salio bien y que mensaje mostrar.
    /// </summary>
    public class SongResult
    {
        private bool _success;
        private string _message;

        public bool Success
        {
            get { return _success; }
            set { _success = value; }
        }

        public string Message
        {
            get { return _message; }
            set { _message = value; }
        }

        public static SongResult Ok(string message)
        {
            SongResult result = new SongResult();
            result.Success = true;
            result.Message = message;
            return result;
        }

        public static SongResult Fail(string message)
        {
            SongResult result = new SongResult();
            result.Success = false;
            result.Message = message;
            return result;
        }
    }

    /// <summary>
    /// Reglas de negocio de las canciones: validaciones, manejo del archivo
    /// de audio y comunicacion con el repositorio (DAL).
    /// </summary>
    public class Song
    {
        /// <summary>
        /// Longitud maxima del nombre, igual que SONG_NAME varchar(50).
        /// </summary>
        public const int MaxNameLength = 50;

        private const int DefaultMaxFileSizeMb = 25;
        private const string DefaultUploadFolder = "~/SongFiles";
        private const string SettingUploadFolder = "SongUploadFolder";
        private const string SettingMaxFileSize = "MaxSongFileSizeMB";

        private static readonly string[] AllowedExtensions = new string[] { ".mp3", ".wav", ".ogg", ".m4a" };

        private readonly SongRepository _repository;
        private readonly string _uploadFolder;

        public Song()
        {
            _repository = new SongRepository();
            _uploadFolder = ReadSetting(SettingUploadFolder, DefaultUploadFolder);
        }

        #region Consultas

        /// <summary>
        /// Devuelve el catalogo completo de canciones.
        /// </summary>
        public List<SongEntity> GetAll()
        {
            return _repository.GetAll();
        }

        /// <summary>
        /// Busca canciones por nombre, artista o album. Si el termino esta vacio
        /// devuelve todo el catalogo.
        /// </summary>
        public List<SongEntity> Search(string term)
        {
            string value = (term ?? string.Empty).Trim();

            if (value.Length == 0)
            {
                return _repository.GetAll();
            }

            return _repository.Search(value);
        }

        /// <summary>
        /// Devuelve una cancion por su ID o null si no existe.
        /// </summary>
        public SongEntity GetById(int idSong)
        {
            if (idSong <= 0)
            {
                return null;
            }

            return _repository.GetById(idSong);
        }

        /// <summary>
        /// Suma el total de reproducciones de una lista (para el resumen de la pagina).
        /// </summary>
        public static int TotalPlays(List<SongEntity> songs)
        {
            if (songs == null)
            {
                return 0;
            }

            int total = 0;
            for (int i = 0; i < songs.Count; i++)
            {
                total += songs[i].Plays;
            }

            return total;
        }

        #endregion

        #region Guardar (insertar / actualizar)

        /// <summary>
        /// Valida y guarda una cancion. Si viene un archivo de audio se copia a
        /// la carpeta de subidas y se arma la ruta virtual automaticamente.
        /// </summary>
        public SongResult Save(SongEntity song, HttpPostedFile file)
        {
            if (song == null)
            {
                return SongResult.Fail("No se recibieron los datos de la canción.");
            }

            // 1) Validaciones de negocio
            string name = (song.SongName ?? string.Empty).Trim();

            if (name.Length == 0)
            {
                return SongResult.Fail("El nombre de la canción es obligatorio.");
            }

            if (name.Length > MaxNameLength)
            {
                return SongResult.Fail("El nombre no puede superar los " + MaxNameLength + " caracteres.");
            }

            if (song.Plays < 0)
            {
                return SongResult.Fail("El número de reproducciones no puede ser negativo.");
            }

            if (_repository.ExistsName(name, song.IdSong))
            {
                return SongResult.Fail("Ya existe una canción registrada con el nombre \"" + name + "\".");
            }

            // 2) Archivo de audio: subida o ruta virtual manual
            string path = (song.SongPath ?? string.Empty).Trim();
            bool hasFile = file != null && file.ContentLength > 0;

            if (hasFile)
            {
                string error;
                path = SaveUploadedFile(file, out error);

                if (path == null)
                {
                    return SongResult.Fail(error);
                }
            }
            else
            {
                path = NormalizeVirtualPath(path);

                if (path.Length == 0)
                {
                    return SongResult.Fail("Debes subir un archivo de audio o indicar la ruta virtual del archivo.");
                }
            }

            song.SongName = name;
            song.SongPath = path;

            // 3) Persistencia
            if (song.IdSong > 0)
            {
                if (_repository.Update(song) == 0)
                {
                    return SongResult.Fail("No se encontró la canción que intentas actualizar.");
                }

                return SongResult.Ok("Canción actualizada correctamente.");
            }

            song.IdSong = _repository.Insert(song);
            return SongResult.Ok("Canción agregada a la biblioteca.");
        }

        #endregion

        #region Eliminar y reproducciones

        /// <summary>
        /// Elimina una cancion y la quita de las playlists y albumes donde aparecia.
        /// </summary>
        public SongResult Delete(int idSong)
        {
            if (idSong <= 0)
            {
                return SongResult.Fail("Identificador de canción inválido.");
            }

            SongEntity song = _repository.GetById(idSong);

            if (song == null)
            {
                return SongResult.Fail("La canción ya no existe en la biblioteca.");
            }

            int playlistsAffected;
            int rows = _repository.DeleteCascade(idSong, out playlistsAffected);

            if (rows == 0)
            {
                return SongResult.Fail("No se pudo eliminar la canción.");
            }

            string message = "Se eliminó \"" + song.SongName + "\" de la biblioteca.";

            if (playlistsAffected > 0)
            {
                message += " También se quitó de " + playlistsAffected + " playlist(s).";
            }

            return SongResult.Ok(message);
        }

        /// <summary>
        /// Registra una reproduccion (lo llama el contador que usa el reproductor).
        /// </summary>
        public SongResult RegisterPlay(int idSong)
        {
            if (idSong <= 0)
            {
                return SongResult.Fail("Identificador de canción inválido.");
            }

            if (_repository.IncrementPlays(idSong) == 0)
            {
                return SongResult.Fail("No se pudo registrar la reproducción.");
            }

            return SongResult.Ok("Reproducción registrada.");
        }

        #endregion

        #region Archivos y utilidades

        /// <summary>
        /// Copia el archivo subido a la carpeta de audios y devuelve su ruta virtual.
        /// Devuelve null y un mensaje de error si el archivo no es valido.
        /// </summary>
        private string SaveUploadedFile(HttpPostedFile file, out string error)
        {
            error = null;

            string extension = Path.GetExtension(file.FileName);
            extension = extension == null ? string.Empty : extension.ToLower(CultureInfo.InvariantCulture);

            if (Array.IndexOf(AllowedExtensions, extension) < 0)
            {
                error = "Formato no permitido. Usa archivos " + string.Join(", ", AllowedExtensions) + ".";
                return null;
            }

            int maxFileSizeMb = GetMaxFileSizeMb();

            if (file.ContentLength > maxFileSizeMb * 1024 * 1024)
            {
                error = "El archivo supera el tamaño máximo permitido (" + maxFileSizeMb + " MB).";
                return null;
            }

            HttpContext context = HttpContext.Current;

            if (context == null)
            {
                error = "No hay contexto HTTP disponible para guardar el archivo.";
                return null;
            }

            string folder = context.Server.MapPath(_uploadFolder);

            if (!Directory.Exists(folder))
            {
                Directory.CreateDirectory(folder);
            }

            // Nombre unico: nombre-limpio + marca de tiempo + extension
            string baseName = SanitizeFileName(Path.GetFileNameWithoutExtension(file.FileName));
            string fileName = baseName + "-" + DateTime.Now.ToString("yyyyMMddHHmmssfff", CultureInfo.InvariantCulture) + extension;

            file.SaveAs(Path.Combine(folder, fileName));

            return _uploadFolder.TrimEnd('/') + "/" + fileName;
        }

        /// <summary>
        /// Normaliza la ruta que escribe el usuario para que quede como ruta virtual (~/).
        /// </summary>
        private static string NormalizeVirtualPath(string path)
        {
            string value = (path ?? string.Empty).Trim().Replace("\\", "/");

            if (value.Length == 0)
            {
                return string.Empty;
            }

            if (value.StartsWith("~/"))
            {
                return value;
            }

            if (value.StartsWith("~"))
            {
                return "~/" + value.TrimStart('~', '/');
            }

            if (value.StartsWith("/"))
            {
                return "~" + value;
            }

            if (value.IndexOf('/') < 0)
            {
                return "~/SongFiles/" + value;
            }

            return "~/" + value;
        }

        /// <summary>
        /// Deja solo letras y numeros en el nombre del archivo, cambiando el resto por guiones.
        /// </summary>
        private static string SanitizeFileName(string name)
        {
            if (string.IsNullOrEmpty(name))
            {
                return "cancion";
            }

            StringBuilder builder = new StringBuilder();
            bool previousWasDash = false;

            for (int i = 0; i < name.Length && builder.Length < 40; i++)
            {
                char character = name[i];

                if (char.IsLetterOrDigit(character))
                {
                    builder.Append(character);
                    previousWasDash = false;
                }
                else if (!previousWasDash)
                {
                    builder.Append('-');
                    previousWasDash = true;
                }
            }

            string result = builder.ToString().Trim('-');
            return result.Length == 0 ? "cancion" : result;
        }

        private static int GetMaxFileSizeMb()
        {
            int value;
            string setting = ConfigurationManager.AppSettings[SettingMaxFileSize];

            if (!string.IsNullOrEmpty(setting) && int.TryParse(setting, out value) && value > 0)
            {
                return value;
            }

            return DefaultMaxFileSizeMb;
        }

        private static string ReadSetting(string key, string defaultValue)
        {
            string value = ConfigurationManager.AppSettings[key];
            return string.IsNullOrEmpty(value) ? defaultValue : value;
        }

        #endregion
    }
}
