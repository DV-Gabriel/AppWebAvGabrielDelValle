using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SongEntity = WebAppPoliMusicV2.Entities.Song;
using SongBLL = WebAppPoliMusicV2.BLL.Song;
using SongResult = WebAppPoliMusicV2.BLL.SongResult;

namespace WebAppPoliMusicV2
{
    /// <summary>
    /// Apartado de canciones: lista la biblioteca, permite buscar, agregar,
    /// editar y eliminar canciones de TBL_SONG.
    /// </summary>
    public partial class Songs : System.Web.UI.Page
    {
        private readonly SongBLL _songBll = new SongBLL();

        #region Propiedades de estado

        /// <summary>
        /// Indica si el modal del formulario debe mostrarse.
        /// </summary>
        private bool FormOpen
        {
            get { return ViewState["FormOpen"] != null && (bool)ViewState["FormOpen"]; }
            set { ViewState["FormOpen"] = value; }
        }

        /// <summary>
        /// ID de la cancion en edicion (0 cuando es una cancion nueva).
        /// </summary>
        private int EditingSongId
        {
            get
            {
                object value = ViewState["EditingSongId"];
                return value == null ? 0 : (int)value;
            }
            set { ViewState["EditingSongId"] = value; }
        }

        /// <summary>
        /// Termino de busqueda activo.
        /// </summary>
        private string SearchTerm
        {
            get
            {
                object value = ViewState["SearchTerm"];
                return value == null ? string.Empty : (string)value;
            }
            set { ViewState["SearchTerm"] = value; }
        }

        /// <summary>
        /// Mensaje del aviso flotante. Se limpia despues de mostrarse una vez.
        /// </summary>
        private string ToastMessage
        {
            get
            {
                object value = ViewState["ToastMessage"];
                return value == null ? string.Empty : (string)value;
            }
            set { ViewState["ToastMessage"] = value; }
        }

        #endregion

        #region Ciclo de vida

        protected void Page_Load(object sender, EventArgs e)
        {
            BindCurrentUser();

            if (!IsPostBack)
            {
                BindSongs();
            }
        }

        /// <summary>
        /// Muestra en la barra superior el nombre del usuario que inicio sesion.
        /// Si no hay usuario en sesion se deja el texto por defecto "Mi cuenta".
        /// </summary>
        private void BindCurrentUser()
        {
            Entities.User user = Session[Util.Constants.USER] as Entities.User;

            if (user == null || string.IsNullOrEmpty(user.UserName))
            {
                lblUserName.Text = "Mi cuenta";
                return;
            }

            lblUserName.Text = HttpUtility.HtmlEncode(user.UserName);
            lblUserName.ToolTip = user.Email;
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            // El modal y el aviso siempre se renderizan; se muestran con CSS
            // para que los controles conserven sus valores en el postback.
            pnlForm.CssClass = FormOpen ? "modal-backdrop is-open" : "modal-backdrop";

            if (ToastMessage.Length > 0)
            {
                lblToast.Text = HttpUtility.HtmlEncode(ToastMessage);
                pnlToast.CssClass = "toast is-visible";
                ToastMessage = string.Empty;
            }
            else
            {
                lblToast.Text = string.Empty;
                pnlToast.CssClass = "toast";
            }
        }

        #endregion

        #region Carga de datos

        /// <summary>
        /// Vuelve a consultar la BLL y pinta el repetidor con las canciones.
        /// </summary>
        private void BindSongs()
        {
            List<SongEntity> songs = _songBll.Search(SearchTerm);

            rptSongs.DataSource = songs;
            rptSongs.DataBind();

            pnlEmpty.Visible = songs.Count == 0;

            int totalPlays = SongBLL.TotalPlays(songs);

            lblSummary.Text = songs.Count == 1 ? "1 canción" : songs.Count + " canciones";
            lblTotalPlays.Text = totalPlays == 1 ? "1 reproducción" : totalPlays + " reproducciones";
        }

        #endregion

        #region Eventos de la pagina

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            SearchTerm = txtSearch.Text;
            BindSongs();
        }

        protected void btnNew_Click(object sender, EventArgs e)
        {
            EditingSongId = 0;
            lblFormTitle.Text = "Nueva canción";
            txtSongName.Text = string.Empty;
            txtSongPath.Text = string.Empty;
            txtPlays.Text = "0";
            lblFormMessage.Text = string.Empty;
            FormOpen = true;
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            FormOpen = false;
            EditingSongId = 0;
            lblFormMessage.Text = string.Empty;
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            int plays = 0;

            if (txtPlays.Text.Trim().Length > 0 && !int.TryParse(txtPlays.Text.Trim(), out plays))
            {
                lblFormMessage.Text = "Las reproducciones deben ser un número entero.";
                FormOpen = true;
                return;
            }

            SongEntity song = new SongEntity();
            song.IdSong = EditingSongId;
            song.SongName = txtSongName.Text;
            song.SongPath = txtSongPath.Text;
            song.Plays = plays;

            HttpPostedFile file = fupSongFile.HasFile ? fupSongFile.PostedFile : null;
            SongResult result = _songBll.Save(song, file);

            if (result.Success)
            {
                FormOpen = false;
                EditingSongId = 0;
                lblFormMessage.Text = string.Empty;
                ToastMessage = result.Message;
                BindSongs();
            }
            else
            {
                FormOpen = true;
                lblFormMessage.Text = result.Message;
            }
        }

        /// <summary>
        /// Maneja los botones Editar y Eliminar de cada fila de la lista.
        /// </summary>
        protected void rptSongs_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int idSong;

            if (!int.TryParse(Convert.ToString(e.CommandArgument), out idSong))
            {
                return;
            }

            if (string.Equals(e.CommandName, "Edit", StringComparison.OrdinalIgnoreCase))
            {
                LoadSongIntoForm(idSong);
            }
            else if (string.Equals(e.CommandName, "Delete", StringComparison.OrdinalIgnoreCase))
            {
                SongResult result = _songBll.Delete(idSong);
                ToastMessage = result.Message;
                BindSongs();
            }
        }

        #endregion

        #region Apoyo para la vista

        /// <summary>
        /// Carga una cancion en el modal para editarla.
        /// </summary>
        private void LoadSongIntoForm(int idSong)
        {
            SongEntity song = _songBll.GetById(idSong);

            if (song == null)
            {
                ToastMessage = "La canción ya no existe en la biblioteca.";
                BindSongs();
                return;
            }

            EditingSongId = song.IdSong;
            lblFormTitle.Text = "Editar canción";
            txtSongName.Text = song.SongName;
            txtSongPath.Text = song.SongPath;
            txtPlays.Text = song.Plays.ToString();
            lblFormMessage.Text = string.Empty;
            FormOpen = true;
        }

        /// <summary>
        /// Convierte la ruta virtual guardada en la BD (~/SongFiles/...) en una URL usable.
        /// </summary>
        protected string SongUrl(object path)
        {
            string value = Convert.ToString(path);

            if (string.IsNullOrEmpty(value))
            {
                return string.Empty;
            }

            return ResolveUrl(value);
        }

        /// <summary>
        /// Codifica un valor para usarlo dentro de un atributo HTML.
        /// </summary>
        protected string Attr(object value)
        {
            return HttpUtility.HtmlAttributeEncode(Convert.ToString(value));
        }

        /// <summary>
        /// Codifica un valor para mostrarlo como texto.
        /// </summary>
        protected string Txt(object value)
        {
            return HttpUtility.HtmlEncode(Convert.ToString(value));
        }

        /// <summary>
        /// Texto del artista con un valor por defecto cuando no hay relacion.
        /// </summary>
        protected string ArtistLabel(object artist)
        {
            string value = Convert.ToString(artist).Trim();
            return value.Length == 0 ? "Artista desconocido" : value;
        }

        /// <summary>
        /// Texto del album con un valor por defecto cuando no hay relacion.
        /// </summary>
        protected string AlbumLabel(object album)
        {
            string value = Convert.ToString(album).Trim();
            return value.Length == 0 ? "Álbum desconocido" : value;
        }

        #endregion
    }
}
