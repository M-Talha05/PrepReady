using System;
using PrepReady.Helpers;

namespace PrepReady.Account
{
    public partial class ChangePassword : BasePage
    {
        // Users-table accounts only (Members + Admins).
        protected override string[] AllowedRoles
        {
            get { return new[] { "Member", "Admin" }; }
        }

        protected void Page_Load(object sender, EventArgs e) { }

        protected void btnChange_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            bool ok = AuthService.ChangePassword(CurrentUserId, txtCurrent.Text, txtNew.Text);

            lblMsg.Visible = true;
            if (ok)
            {
                lblMsg.CssClass = "alert alert-success d-block";
                lblMsg.Text = "Your password has been changed successfully.";
                txtCurrent.Text = txtNew.Text = txtConfirm.Text = "";
            }
            else
            {
                lblMsg.CssClass = "alert alert-danger d-block";
                lblMsg.Text = "Your current password is incorrect. Please try again.";
            }
        }
    }
}