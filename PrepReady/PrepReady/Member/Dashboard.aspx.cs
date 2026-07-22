using System;
using System.Data;
using PrepReady.Helpers;

namespace PrepReady.Member
{
    public partial class Dashboard : BasePage
    {
        protected override string[] AllowedRoles { get { return new[] { "Member" }; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) LoadDashboard();
        }

        private void LoadDashboard()
        {
            int userId = CurrentUserId;

            litName.Text = Server.HtmlEncode(CurrentFullName);
            litPoints.Text = CourseService.GetPointBalance(userId).ToString();
            litCerts.Text = CourseService.CountCertificates(userId).ToString();
            litStreak.Text = GamificationService.GetLoginStreak(userId).ToString();

            // EX-14: certificates expiring within 30 days -> renewal reminder banner.
            DataTable expiring = CertificateService.GetExpiringSoon(userId, 30);
            rptExpiry.DataSource = expiring;
            rptExpiry.DataBind();
            pnlExpiry.Visible = expiring.Rows.Count > 0;

            DataTable enrollments = CourseService.GetUserEnrollments(userId);

            int totalCompleted = 0;
            foreach (DataRow r in enrollments.Rows)
                totalCompleted += Convert.ToInt32(r["CompletedLessons"]);

            litCourses.Text = enrollments.Rows.Count.ToString();
            litLessons.Text = totalCompleted.ToString();

            rptEnrollments.DataSource = enrollments;
            rptEnrollments.DataBind();
            lblEmpty.Visible = enrollments.Rows.Count == 0;
        }

        protected int CalcPercent(object completed, object total)
        {
            int c = Convert.ToInt32(completed);
            int t = Convert.ToInt32(total);
            return t == 0 ? 0 : (int)Math.Round(100.0 * c / t);
        }

        // EX-14: whole days until the given expiry date (never negative — the query only
        // returns still-valid certs anyway).
        protected int DaysLeft(object expiry)
        {
            DateTime e = Convert.ToDateTime(expiry);
            int d = (int)Math.Ceiling((e - DateTime.Now).TotalDays);
            return d < 0 ? 0 : d;
        }
    }
}