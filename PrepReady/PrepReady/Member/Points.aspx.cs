using System;
using PrepReady.Helpers;

namespace PrepReady.Member
{
    public partial class Points : BasePage
    {
        protected override string[] AllowedRoles { get { return new[] { "Member" }; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            litBalance.Text = CourseService.GetPointBalance(CurrentUserId).ToString();
            litStreak.Text = GamificationService.GetLoginStreak(CurrentUserId).ToString();

            gvHistory.DataSource = GamificationService.GetPointHistory(CurrentUserId);
            gvHistory.DataBind();
        }
    }
}