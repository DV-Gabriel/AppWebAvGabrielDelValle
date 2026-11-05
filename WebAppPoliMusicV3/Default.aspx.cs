using System;
using System.Web;
using System.Web.UI;
using UserEntity = EntityLayer.PoliMusicV3.User;
using Const = EntityLayer.PoliMusicV3.Util.Constants;

namespace WebAppPoliMusicV3
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            UserEntity user = Session[Const.USER] as UserEntity;

            if (user == null)
            {
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            lblUserName.Text = HttpUtility.HtmlEncode(user.UserName);
        }
    }
}
