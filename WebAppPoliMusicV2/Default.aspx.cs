using System;
using System.IO;
using System.Web;
using System.Web.UI;

namespace WebAppPoliMusicV2
{
    /// <summary>
    /// Pagina de entrada del sitio. No tiene contenido propio: solo decide a
    /// donde mandar al usuario (login, panel de administracion o canciones).
    /// Existe para que http://localhost:16854/ tenga un documento por defecto
    /// y no devuelva el error 403.14 (directory listing).
    /// </summary>
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Context.User == null || !Context.User.Identity.IsAuthenticated)
            {
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            Entities.User user = Session[Util.Constants.USER] as Entities.User;

            // El panel de administracion puede no existir todavia: si no esta,
            // el administrador tambien entra al modulo de canciones.
            if (user != null
                && user.UserType == Util.Constants.ID_USER_ADMIN
                && File.Exists(Server.MapPath("~/DesktopAdmin.aspx")))
            {
                Response.Redirect("~/DesktopAdmin.aspx?uid=" + user.ID, true);
                return;
            }

            Response.Redirect("~/Songs.aspx", true);
        }
    }
}
