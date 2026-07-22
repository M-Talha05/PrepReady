using System;
using PrepReady.Helpers;

namespace PrepReady.Account
{
    public partial class VerifyEmail : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string token = Request.QueryString["token"];

            if (!string.IsNullOrEmpty(token) && AuthService.VerifyEmailToken(token))
            {
                lblResult.Text = "Your email has been verified. You can now log in.";
                lblResult.CssClass = "alert alert-success d-block mt-3";
            }
            else
            {
                lblResult.Text = "This verification link is invalid or has already been used.";
                lblResult.CssClass = "alert alert-danger d-block mt-3";
            }
        }
    }
}