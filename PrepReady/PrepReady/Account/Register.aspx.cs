using System;
using PrepReady.Helpers;

namespace PrepReady.Account
{
    public partial class Register : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) litCaptchaReg.Text = CaptchaHelper.NewQuestion();
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            // Server-side validation gate (client validators already ran in the browser).
            if (!Page.IsValid) return;

            // CAPTCHA check.
            if (!CaptchaHelper.IsValid(txtCaptchaReg.Text))
            {
                lblError.Text = "Incorrect answer to the verification question.";
                lblError.Visible = true;
                litCaptchaReg.Text = CaptchaHelper.NewQuestion();
                return;
            }

            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text;

            // Server-side business rule: email must be unique across Users + Officers.
            if (AuthService.EmailExists(email))
            {
                lblError.Text = "That email is already registered. Try logging in instead.";
                lblError.Visible = true;
                return;
            }

            // Create the member with a hashed password and an email-verify token.
            string token = AuthService.GenerateToken();
            AuthService.RegisterMember(fullName, email, password, token);

            // Build an absolute verification link and "send" it (logged in demo mode).
            string relative = ResolveUrl("~/Account/VerifyEmail.aspx?token=" + token);
            string fullUrl = new Uri(Request.Url, relative).AbsoluteUri;

            string body =
                "<p>Welcome to PrepReady, " + Server.HtmlEncode(fullName) + "!</p>" +
                "<p>Please verify your email by clicking the link below:</p>" +
                "<p><a href=\"" + fullUrl + "\">" + fullUrl + "</a></p>";
            EmailHelper.Send(email, "Verify your PrepReady account", body);

            // Show success + a clickable verify link (handy because email is only logged).
            pnlForm.Visible = false;
            lblError.Visible = false;
            pnlSuccess.Visible = true;
            lnkVerify.NavigateUrl = fullUrl;
            lnkVerify.Text = "Verify my email now";
        }
    }
}