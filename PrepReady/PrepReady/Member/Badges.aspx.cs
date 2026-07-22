using System;
using System.Collections.Generic;
using System.Data;
using PrepReady.Helpers;

namespace PrepReady.Member
{
    public partial class Badges : BasePage
    {
        protected override string[] AllowedRoles { get { return new[] { "Member" }; } }

        // Small view-model for an achievement tile (properties so Eval can bind).
        public class Achievement
        {
            public string Title { get; set; }
            public string Description { get; set; }
            public string Icon { get; set; }
            public bool Unlocked { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            int uid = CurrentUserId;
            int lessons = GamificationService.LessonsCompleted(uid);
            int quizzes = GamificationService.QuizzesPassed(uid);
            int courses = GamificationService.CompletedCourses(uid);
            int certs = GamificationService.CertificateCount(uid);
            int points = CourseService.GetPointBalance(uid);

            var list = new List<Achievement>
            {
                new Achievement { Title = "First Steps",     Description = "Complete your first lesson", Icon = "📘", Unlocked = lessons >= 1 },
                new Achievement { Title = "Quiz Whiz",       Description = "Pass your first quiz",        Icon = "✅", Unlocked = quizzes >= 1 },
                new Achievement { Title = "Course Champion", Description = "Complete a full course",      Icon = "🏆", Unlocked = courses >= 1 },
                new Achievement { Title = "Certified",       Description = "Earn a certificate",          Icon = "📜", Unlocked = certs   >= 1 },
                new Achievement { Title = "Centurion",       Description = "Reach 100 points",            Icon = "💯", Unlocked = points  >= 100 },
                new Achievement { Title = "High Achiever",   Description = "Reach 500 points",            Icon = "🌟", Unlocked = points  >= 500 },
            };

            rptAchievements.DataSource = list;
            rptAchievements.DataBind();

            DataTable badges = GamificationService.GetTier3Badges(uid);
            rptBadges.DataSource = badges;
            rptBadges.DataBind();
            lblNoBadges.Visible = badges.Rows.Count == 0;
        }
    }
}