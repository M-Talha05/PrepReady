using System;
using PrepReady.Helpers;

namespace PrepReady.Account
{
    public partial class ResetPassword : System.Web.UI.Page
    {
        private string Token
        {
            get { return Request.QueryString["token"]; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Show the invalid panel up front if the token is bad/expired.
                if (AuthService.GetUserIdByResetToken(Token) == 0)
                {
                    pnlForm.Visible = false;
                    pnlInvalid.Visible = true;
                }
            }
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            if (AuthService.ResetPassword(Token, txtNewPassword.Text))
            {
                pnlForm.Visible = false;
                pnlInvalid.Visible = false;
                pnlSuccess.Visible = true;
            }
            else
            {
                pnlForm.Visible = false;
                pnlInvalid.Visible = true;
            }
        }
    }
}