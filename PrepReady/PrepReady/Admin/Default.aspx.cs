using System;
using System.Data;
using PrepReady.Helpers;

namespace PrepReady.Admin
{
    public partial class Default : BasePage
    {
        protected override string[] AllowedRoles { get { return new[] { "Admin" }; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            DataRow s = AdminService.GetStats();
            litUsers.Text = s["Users"].ToString();
            litCourses.Text = s["Courses"].ToString();
            litLessons.Text = s["Lessons"].ToString();
            litQuizzes.Text = s["Quizzes"].ToString();
            litCerts.Text = s["Certificates"].ToString();
            litBadges.Text = s["Badges"].ToString();
            litRegistry.Text = s["Registry"].ToString();
            litRedemptions.Text = s["Redemptions"].ToString();
        }
    }
}