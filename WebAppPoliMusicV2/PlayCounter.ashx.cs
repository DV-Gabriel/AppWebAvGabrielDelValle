using System;
using System.Web;

namespace WebAppPoliMusicV2
{
    /// <summary>
    /// Contador de reproducciones. El reproductor lo llama por AJAX cada vez
    /// que empieza una cancion, asi se suma en TBL_SONG sin recargar la pagina
    /// (si se recargara, el audio se cortaria).
    /// </summary>
    public class PlayCounter : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            context.Response.Cache.SetNoStore();

            int idSong;

            if (!int.TryParse(context.Request.QueryString["id"], out idSong) || idSong <= 0)
            {
                context.Response.StatusCode = 400;
                context.Response.Write("0");
                return;
            }

            try
            {
                BLL.SongResult result = new BLL.Song().RegisterPlay(idSong);
                context.Response.Write(result.Success ? "1" : "0");
            }
            catch (Exception)
            {
                context.Response.StatusCode = 500;
                context.Response.Write("0");
            }
        }

        public bool IsReusable
        {
            get { return false; }
        }
    }
}
