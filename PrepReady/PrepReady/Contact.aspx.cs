using System;
using PrepReady.Helpers;

namespace PrepReady
{
    public partial class Contact : System.Web.UI.Page
    {
        private bool LoggedIn { get { return Session["UserId"] != null; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            if (LoggedIn)
            {
                // Signed-in members: prefill, lock identity, skip CAPTCHA (already authenticated).
                txtName.Text = Convert.ToString(Session["FullName"]);
                txtEmail.Text = Convert.ToString(Session["Email"]);
                // Use the HTML readonly attribute (not the server ReadOnly property) so the
                // values still post back on submit.
                txtName.Attributes["readonly"] = "readonly";
                txtEmail.Attributes["readonly"] = "readonly";
                pnlCaptcha.Visible = false;
                pnlLoggedInfo.Visible = true;
            }
            else
            {
                litCaptcha.Text = CaptchaHelper.NewQuestion();
            }
        }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            if (!LoggedIn && !CaptchaHelper.IsValid(txtCaptcha.Text))
            {
                lblMsg.Visible = true;
                lblMsg.CssClass = "alert alert-danger d-block";
                lblMsg.Text = "Incorrect answer to the verification question. Please try again.";
                litCaptcha.Text = CaptchaHelper.NewQuestion();
                txtCaptcha.Text = "";
                return;
            }

            int? userId = LoggedIn ? (int?)Convert.ToInt32(Session["UserId"]) : null;

            int messageId = ContactService.Submit(
                txtName.Text.Trim(), txtEmail.Text.Trim(),
                txtSubject.Text.Trim(), txtBody.Text.Trim(), userId);

            if (LoggedIn)
            {
                // Continue the conversation in My Messages.
                Response.Redirect("~/Member/MyMessages.aspx?id=" + messageId);
                return;
            }

            // Guests: acknowledge + log the email locally.
            EmailHelper.Send(txtEmail.Text.Trim(), "We received your message — PrepReady",
                "<p>Hi " + Server.HtmlEncode(txtName.Text.Trim()) + ",</p>" +
                "<p>Thanks for contacting PrepReady. We've received your message and will reply to this email address soon.</p>" +
                "<p><em>Subject:</em> " + Server.HtmlEncode(txtSubject.Text.Trim()) + "</p>");

            pnlForm.Visible = false;
            pnlDone.Visible = true;
        }
    }
}