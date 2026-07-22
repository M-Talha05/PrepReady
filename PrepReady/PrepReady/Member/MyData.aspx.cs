using System;
using PrepReady.Helpers;

namespace PrepReady.Member
{
    public partial class MyData : BasePage
    {
        protected override string[] AllowedRoles { get { return new[] { "Member" }; } }

        protected void Page_Load(object sender, EventArgs e) { }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            if (!chkConfirm.Checked)
            {
                ShowError("Please tick the confirmation box to proceed.");
                return;
            }

            if (!AuthService.VerifyUserPassword(CurrentUserId, txtPassword.Text))
            {
                ShowError("That password is incorrect. Your account was not deleted.");
                return;
            }

            int uid = CurrentUserId;      // capture before we abandon the session
            AdminService.DeleteUser(uid); // same proven cascade admins use

            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Account/Login.aspx?deleted=1");
        }

        private void ShowError(string msg)
        {
            lblDelError.Text = msg;
            lblDelError.Visible = true;
        }
    }
}