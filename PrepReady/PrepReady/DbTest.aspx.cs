using System;
using System.Data;
using PrepReady.Helpers;

namespace PrepReady
{
    public partial class DbTest : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                // Counts prove connectivity + that the seed ran.
                object courses = DBHelper.ExecuteScalar("SELECT COUNT(*) FROM Courses");
                object lessons = DBHelper.ExecuteScalar("SELECT COUNT(*) FROM Lessons");
                object quizzes = DBHelper.ExecuteScalar("SELECT COUNT(*) FROM Quizzes");
                object partners = DBHelper.ExecuteScalar("SELECT COUNT(*) FROM RedemptionPartners");

                lblStatus.Text = string.Format(
                    "Connected ✓  Courses: {0} | Lessons: {1} | Quizzes: {2} | Partners: {3}",
                    courses, lessons, quizzes, partners);
                lblStatus.ForeColor = System.Drawing.Color.Green;

                // Display a few columns from the seeded courses.
                DataTable dt = DBHelper.ExecuteDataTable(
                    "SELECT CourseId, CategoryName, Title, GovPartner, PassingMark FROM Courses ORDER BY CourseId");
                gvCourses.DataSource = dt;
                gvCourses.DataBind();
            }
            catch (Exception ex)
            {
                lblStatus.Text = "Connection FAILED: " + ex.Message;
                lblStatus.ForeColor = System.Drawing.Color.Red;
            }
        }
    }
}