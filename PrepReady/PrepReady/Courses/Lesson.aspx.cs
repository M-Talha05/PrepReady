using System;
using System.Data;
using System.Web;
using PrepReady.Helpers;

namespace PrepReady.Courses
{
    public partial class Lesson : BasePage
    {
        protected override string[] AllowedRoles { get { return new[] { "Member" }; } }

        private int _courseId;

        private int LessonId
        {
            get { int id; return int.TryParse(Request.QueryString["id"], out id) ? id : 0; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (LessonId == 0) { Response.Redirect("~/Courses/Catalogue.aspx"); return; }

            DataRow lesson = CourseService.GetLesson(LessonId);
            if (lesson == null) { Response.Redirect("~/Courses/Catalogue.aspx"); return; }

            _courseId = Convert.ToInt32(lesson["CourseId"]);

            if (!CourseService.IsEnrolled(CurrentUserId, _courseId))
            {
                Response.Redirect("~/Courses/CourseDetail.aspx?id=" + _courseId);
                return;
            }

            if (!IsPostBack)
                RenderLesson(lesson);
        }

        private void RenderLesson(DataRow lesson)
        {
            litTitle.Text = Server.HtmlEncode(lesson["Title"].ToString());
            litBody.Text = Convert.ToString(lesson["BodyHtml"]);             // trusted admin HTML
            litMedia.Text = RenderMedia(Convert.ToString(lesson["MediaUrl"]));
            lnkBack.HRef = "CourseDetail.aspx?id=" + _courseId;

            int total = CourseService.CountLessons(_courseId);
            int done = CourseService.CountCompletedLessons(CurrentUserId, _courseId);
            int pct = total == 0 ? 0 : (int)Math.Round(100.0 * done / total);
            bar.Style["width"] = pct + "%";
            litProgressText.Text = done + " of " + total + " lessons completed (" + pct + "%)";

            lblDone.Visible = CourseService.IsLessonComplete(CurrentUserId, LessonId);

            // Lesson quiz CTA (only if this lesson has sub-quiz questions).
            DataTable q = QuizService.GetLessonQuestions(LessonId);
            if (q.Rows.Count > 0)
            {
                pnlQuiz.Visible = true;
                bool passed = QuizService.HasPassedQuiz(CurrentUserId, LessonId);
                lnkQuiz.NavigateUrl = "Assessment.aspx?lessonId=" + LessonId;
                lnkQuiz.Text = passed ? "Retake quiz" : "Take lesson quiz";
                litQuizMsg.Text = passed
                    ? "✔ You passed this quiz."
                    : "This quiz has " + q.Rows.Count + " question(s). Score 60% to pass.";
            }

            BuildNavLinks();
        }

        private void BuildNavLinks()
        {
            DataTable lessons = CourseService.GetLessons(_courseId);
            int index = -1;
            for (int i = 0; i < lessons.Rows.Count; i++)
                if (Convert.ToInt32(lessons.Rows[i]["LessonId"]) == LessonId) { index = i; break; }

            if (index > 0)
                lnkPrev.NavigateUrl = "Lesson.aspx?id=" + lessons.Rows[index - 1]["LessonId"];
            else
                lnkPrev.Visible = false;

            if (index >= 0 && index == lessons.Rows.Count - 1)
                btnComplete.Text = "Mark complete & finish";
        }

        protected void btnComplete_Click(object sender, EventArgs e)
        {
            DataRow lesson = CourseService.GetLesson(LessonId);
            if (lesson == null) return;
            _courseId = Convert.ToInt32(lesson["CourseId"]);

            CourseService.MarkLessonComplete(CurrentUserId, _courseId, LessonId);

            DataTable lessons = CourseService.GetLessons(_courseId);
            int index = -1;
            for (int i = 0; i < lessons.Rows.Count; i++)
                if (Convert.ToInt32(lessons.Rows[i]["LessonId"]) == LessonId) { index = i; break; }

            if (index >= 0 && index < lessons.Rows.Count - 1)
                Response.Redirect("Lesson.aspx?id=" + lessons.Rows[index + 1]["LessonId"]);
            else
                Response.Redirect("CourseDetail.aspx?id=" + _courseId);
        }

        private string RenderMedia(string url)
        {
            if (string.IsNullOrEmpty(url)) return "";

            string safe = HttpUtility.HtmlAttributeEncode(url);
            string lower = url.ToLowerInvariant();

            if (lower.Contains("youtube.com/embed") || lower.Contains("youtu.be"))
                return "<div class='ratio ratio-16x9 mb-4'><iframe src='" + safe + "' allowfullscreen></iframe></div>";
            if (lower.EndsWith(".mp4") || lower.EndsWith(".webm") || lower.EndsWith(".ogg"))
                return "<video class='w-100 rounded mb-4' controls src='" + safe + "'></video>";
            return "<img class='img-fluid rounded mb-4' src='" + safe + "' alt='Lesson media' />";
        }
    }
}