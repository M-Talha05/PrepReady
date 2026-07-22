using System;
using PrepReady.Helpers;

namespace PrepReady.Account
{
    public partial class VerifyOtp : System.Web.UI.Page
    {
        private bool HasPending { get { return Session["2fa_UserId"] != null; } }
        private int PendingUserId { get { return Convert.ToInt32(Session["2fa_UserId"]); } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!HasPending)
            {
                Response.Redirect("~/Account/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                litEmail.Text = Server.HtmlEncode(Convert.ToString(Session["2fa_Email"]));
                ShowDevCode();
            }
        }

        private void ShowDevCode()
        {
            string dev = Session["2fa_DevCode"] as string;
            if (!string.IsNullOrEmpty(dev))
            {
                litDevCode.Text = dev;
                pnlDev.Visible = true;
            }
            else
            {
                pnlDev.Visible = false;
            }
        }

        protected void btnVerify_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid || !HasPending) return;

            int userId = PendingUserId;

            if (!TwoFactorService.VerifyOtp(userId, txtCode.Text))
            {
                lblError.Visible = true;
                lblError.Text = "That code is incorrect or has expired. Request a new one.";
                string ip = Convert.ToString(Session["2fa_Ip"]);
                AuditService.Log(Convert.ToString(Session["2fa_Email"]), userId, false, ip, "OTP failed");
                return;
            }

            // Code good — grant the real session from the pending values.
            string email = Convert.ToString(Session["2fa_Email"]);
            string role = Convert.ToString(Session["2fa_Role"]);

            Session["UserId"] = userId;
            Session["FullName"] = Convert.ToString(Session["2fa_FullName"]);
            Session["Role"] = role;
            Session["Email"] = email;
            Session["AvatarPath"] = null;

            // EX-16: honour the "remember me" choice carried from the login page (members only).
            if (role == "Member" && Convert.ToBoolean(Session["2fa_Remember"]))
                RememberService.IssueToken(userId, Response);

            AuditService.Log(email, userId, true, Convert.ToString(Session["2fa_Ip"]), "OTP verified - login OK");

            string returnUrl = Convert.ToString(Session["2fa_ReturnUrl"]);
            ClearPending();
            RedirectAfterLogin(role, returnUrl);
        }

        protected void btnResend_Click(object sender, EventArgs e)
        {
            if (!HasPending) return;

            int userId = PendingUserId;
            string code = TwoFactorService.GenerateOtp(userId);
            string email = Convert.ToString(Session["2fa_Email"]);

            EmailHelper.Send(email, "Your PrepReady sign-in code",
                "<p>Your new one-time sign-in code is " +
                "<strong style='font-size:1.3em; letter-spacing:2px;'>" + code + "</strong>.</p>" +
                "<p>It expires in 5 minutes.</p>");

            Session["2fa_DevCode"] = Request.IsLocal ? code : null;
            AuditService.Log(email, userId, true, Convert.ToString(Session["2fa_Ip"]), "OTP resent");

            lblError.Visible = false;
            lblInfo.Visible = true;
            lblInfo.Text = "A new code has been sent.";
            txtCode.Text = "";
            ShowDevCode();
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            int userId = HasPending ? PendingUserId : 0;
            if (userId > 0) TwoFactorService.ClearOtp(userId);
            ClearPending();
            Response.Redirect("~/Account/Login.aspx");
        }

        private void ClearPending()
        {
            Session.Remove("2fa_UserId");
            Session.Remove("2fa_FullName");
            Session.Remove("2fa_Role");
            Session.Remove("2fa_Email");
            Session.Remove("2fa_ReturnUrl");
            Session.Remove("2fa_Ip");
            Session.Remove("2fa_DevCode");
            Session.Remove("2fa_Remember");   // EX-16
        }

        private void RedirectAfterLogin(string role, string returnUrl)
        {
            if (!string.IsNullOrEmpty(returnUrl) && returnUrl.StartsWith("/") && !returnUrl.StartsWith("//"))
            {
                Response.Redirect(returnUrl);
                return;
            }

            if (role == "Admin") Response.Redirect("~/Admin/Default.aspx");
            else if (role == "Officer") Response.Redirect("~/Officer/Portal.aspx");
            else Response.Redirect("~/Member/Dashboard.aspx");
        }
    }
}