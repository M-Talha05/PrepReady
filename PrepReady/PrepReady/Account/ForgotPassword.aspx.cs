using System;
using PrepReady.Helpers;

namespace PrepReady.Account
{
    public partial class ForgotPassword : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string email = txtEmail.Text.Trim();
            string token = AuthService.CreatePasswordResetToken(email);

            // Always show the same generic message (no account enumeration).
            pnlForm.Visible = false;
            pnlDone.Visible = true;

            if (token != null)
            {
                string url = new Uri(Request.Url,
                    ResolveUrl("~/Account/ResetPassword.aspx?token=" + Server.UrlEncode(token))).ToString();

                EmailHelper.Send(email, "Reset your PrepReady password",
                    "<p>We received a request to reset your PrepReady password.</p>" +
                    "<p><a href=\"" + url + "\">Click here to reset your password</a>.</p>" +
                    "<p>This link expires in 1 hour. If you did not request this, you can safely ignore this email.</p>");

                // Dev convenience: show the link on-screen when running locally.
                if (Request.IsLocal)
                {
                    pnlDevLink.Visible = true;
                    lnkDevReset.NavigateUrl = url;
                    lnkDevReset.Text = url;
                }
            }
        }
    }
}