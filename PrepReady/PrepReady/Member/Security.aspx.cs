using System;
using PrepReady.Helpers;

namespace PrepReady.Member
{
    public partial class Security : BasePage
    {
        protected override string[] AllowedRoles
        {
            get { return new[] { "Member", "Admin" }; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) Render();
        }

        private void Render()
        {
            bool on = TwoFactorService.IsEnabled(CurrentUserId);

            litStatus.Text = on
                ? "<span class='badge bg-success'>Enabled</span>"
                : "<span class='badge bg-secondary'>Disabled</span>";

            btnToggle.Text = on ? "Turn off two-step login" : "Turn on two-step login";
            btnToggle.CssClass = on ? "btn pr-btn-outline" : "btn pr-btn-accent";
        }

        protected void btnToggle_Click(object sender, EventArgs e)
        {
            bool on = TwoFactorService.IsEnabled(CurrentUserId);
            TwoFactorService.SetEnabled(CurrentUserId, !on);

            lblMsg.Visible = true;
            lblMsg.CssClass = "alert alert-success d-block";
            lblMsg.Text = !on
                ? "Two-step login is now ON. You'll be asked for an emailed code at your next sign-in."
                : "Two-step login is now OFF.";

            Render();
        }
    }
}