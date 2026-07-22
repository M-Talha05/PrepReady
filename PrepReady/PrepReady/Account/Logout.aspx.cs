using System;
using PrepReady.Helpers;

namespace PrepReady.Account
{
    public partial class Logout : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            bool idleTimeout = Request.QueryString["timeout"] == "1";

            // EX-16: drop the trusted-device token + cookie so a logout really signs out.
            RememberService.ClearToken(Request, Response);

            Session.Clear();
            Session.Abandon();

            if (idleTimeout)
            {
                Response.Redirect("~/Account/Login.aspx?timeout=1");
                return;
            }

            Response.Redirect("~/Default.aspx");
        }
    }
}