using System;
using System.Data;
using System.Web.UI.WebControls;
using PrepReady.Helpers;

namespace PrepReady.Member
{
    public partial class MyLearning : BasePage
    {
        protected override string[] AllowedRoles
        {
            get { return new[] { "Member" }; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) BindAll();
        }

        private void BindAll()
        {
            DataTable prog = BookmarkService.GetInProgressCourses(CurrentUserId);
            rptProgress.DataSource = prog;
            rptProgress.DataBind();
            lblNoProgress.Visible = prog.Rows.Count == 0;

            DataTable saved = BookmarkService.GetSavedCourses(CurrentUserId);
            rptSaved.DataSource = saved;
            rptSaved.DataBind();
            lblNoSaved.Visible = saved.Rows.Count == 0;
        }

        // Bound in markup.
        protected int Pct(object done, object total)
        {
            int d = Convert.ToInt32(done), t = Convert.ToInt32(total);
            return t == 0 ? 0 : (int)Math.Round(100.0 * d / t);
        }

        protected string ContinueUrl(object courseId)
        {
            int cid = Convert.ToInt32(courseId);
            int next = CourseService.GetNextLessonId(CurrentUserId, cid);
            return ResolveUrl("~/Courses/Lesson.aspx?id=" + next);
        }

        protected void rptSaved_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "remove")
            {
                BookmarkService.Remove(CurrentUserId, Convert.ToInt32(e.CommandArgument));
                BindAll();
            }
        }
    }
}