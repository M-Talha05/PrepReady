using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI.WebControls;
using PrepReady.Helpers;

namespace PrepReady.Courses
{
    public partial class CourseDetail : System.Web.UI.Page   // public preview; enroll requires member login
    {
        private int CourseId
        {
            get { int id; return int.TryParse(Request.QueryString["id"], out id) ? id : 0; }
        }

        // Sets used while binding the lessons list (only populated for enrolled members).
        private HashSet<int> _completed = new HashSet<int>();
        private HashSet<int> _passedQuiz = new HashSet<int>();
        private bool _showLessonStatus;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (CourseId == 0) { Response.Redirect("~/Courses/Catalogue.aspx"); return; }
            if (!IsPostBack) LoadCourse();
        }

        private void LoadCourse()
        {
            DataRow course = CourseService.GetCourse(CourseId);
            if (course == null) { Response.Redirect("~/Courses/Catalogue.aspx"); return; }

            litCategory.Text = Server.HtmlEncode(course["CategoryName"].ToString());
            litTitle.Text = Server.HtmlEncode(course["Title"].ToString());
            litDesc.Text = Server.HtmlEncode(Convert.ToString(course["Description"]));
            litPartner.Text = Server.HtmlEncode(Convert.ToString(course["GovPartner"]));

            bool isMember = (Session["Role"] as string) == "Member";
            bool enrolled = isMember && CourseService.IsEnrolled(UserId(), CourseId);

            // Prepare per-lesson status sets before binding the list.
            if (enrolled)
            {
                _showLessonStatus = true;
                _completed = CourseService.GetCompletedLessonIds(UserId(), CourseId);
                _passedQuiz = QuizService.GetPassedQuizLessonIds(UserId(), CourseId);
            }

            rptLessons.DataSource = CourseService.GetLessons(CourseId);
            rptLessons.DataBind();

            if (enrolled) ShowEnrolledState();
            else { pnlProgress.Visible = false; pnlEnroll.Visible = true; }

            // EX-9: bookmark toggle (members only)
            if (isMember)
            {
                pnlBookmark.Visible = true;
                SetBookmarkButton(BookmarkService.IsBookmarked(UserId(), CourseId));
            }

            LoadReviews();
        }

        // ===== EX-9: bookmark =====
        private void SetBookmarkButton(bool saved)
        {
            btnBookmark.Text = saved ? "\u2605 Saved — remove" : "\u2606 Save this course";
            btnBookmark.CssClass = saved ? "btn pr-btn-navy w-100" : "btn pr-btn-outline w-100";
        }

        protected void btnBookmark_Click(object sender, EventArgs e)
        {
            if ((Session["Role"] as string) != "Member") return;
            bool nowSaved = BookmarkService.Toggle(UserId(), CourseId);
            SetBookmarkButton(nowSaved);
        }

        // ===== EX-5: ratings & reviews =====
        private void LoadReviews()
        {
            double avg = ReviewService.GetAverage(CourseId);
            int cnt = ReviewService.GetCount(CourseId);

            litAvgStars.Text = cnt > 0
                ? ReviewService.Stars(avg) + " <strong>" + avg.ToString("0.0") + "</strong> " +
                  "<span class=\"text-muted\">(" + cnt + " review" + (cnt == 1 ? "" : "s") + ")</span>"
                : "<span class=\"text-muted\">No ratings yet.</span>";

            DataTable reviews = ReviewService.GetReviews(CourseId);
            rptReviews.DataSource = reviews;
            rptReviews.DataBind();
            lblNoReviews.Visible = reviews.Rows.Count == 0;

            bool isMember = (Session["Role"] as string) == "Member";
            bool canReview = isMember && ReviewService.CanReview(UserId(), CourseId);
            pnlReviewForm.Visible = canReview;
            lblReviewHint.Visible = isMember && !canReview;

            if (canReview && !IsPostBack)
            {
                DataRow mine = ReviewService.GetUserReview(UserId(), CourseId);
                if (mine != null)
                {
                    ddlRating.SelectedValue = mine["Rating"].ToString();
                    txtComment.Text = mine["Comment"] == DBNull.Value ? "" : mine["Comment"].ToString();
                    btnReview.Text = "Update my review";
                }
            }
        }

        protected void btnReview_Click(object sender, EventArgs e)
        {
            bool isMember = (Session["Role"] as string) == "Member";
            if (!isMember || !ReviewService.CanReview(UserId(), CourseId))
            {
                lblReviewMsg.Visible = true;
                lblReviewMsg.CssClass = "alert alert-danger d-block";
                lblReviewMsg.Text = "Only members who have completed this course can leave a review.";
                return;
            }

            int rating;
            int.TryParse(ddlRating.SelectedValue, out rating);
            string comment = txtComment.Text.Trim();
            if (comment.Length > 1000) comment = comment.Substring(0, 1000);

            ReviewService.Save(UserId(), CourseId, rating, comment);

            lblReviewMsg.Visible = true;
            lblReviewMsg.CssClass = "alert alert-success d-block";
            lblReviewMsg.Text = "Thanks! Your review has been saved.";

            LoadReviews();
            btnReview.Text = "Update my review";
        }

        private void ShowEnrolledState()
        {
            pnlEnroll.Visible = false;
            pnlProgress.Visible = true;

            int total = CourseService.CountLessons(CourseId);
            int done = CourseService.CountCompletedLessons(UserId(), CourseId);
            int pct = total == 0 ? 0 : (int)Math.Round(100.0 * done / total);

            litPercent.Text = pct.ToString();
            bar.Style["width"] = pct + "%";
            litProgressText.Text = done + " of " + total + " lessons completed";

            int nextLesson = CourseService.GetNextLessonId(UserId(), CourseId);
            lnkContinue.NavigateUrl = "Lesson.aspx?id=" + nextLesson;
            lnkContinue.Text = (done == 0) ? "Start course" : (done >= total ? "Review course" : "Continue");

            // Final exam panel.
            pnlExam.Visible = true;
            if (QuizService.HasPassedFinalExam(UserId(), CourseId))
            {
                litExamMsg.Text = "<span class='badge bg-success'>Course completed ✓</span>" +
                                  "<p class='small text-muted mt-2 mb-0'>View or download your certificate.</p>";
                lnkExam.Visible = true;
                lnkExam.NavigateUrl = ResolveUrl("~/Member/Certificates.aspx");
                lnkExam.Text = "My certificates";
            }
            else if (QuizService.AllLessonsComplete(UserId(), CourseId) &&
                     QuizService.AllQuizzesPassed(UserId(), CourseId))
            {
                litExamMsg.Text = "<p class='small text-muted mb-0'>You're ready to take the final exam.</p>";
                lnkExam.Visible = true;
                lnkExam.NavigateUrl = "Assessment.aspx?courseId=" + CourseId + "&exam=1";
                lnkExam.Text = "Take final exam";
            }
            else
            {
                litExamMsg.Text = "<p class='small text-muted mb-0'>Complete all lessons and pass every lesson quiz to unlock the final exam.</p>";
            }
        }

        protected void rptLessons_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;
            if (!_showLessonStatus) return;

            DataRowView drv = (DataRowView)e.Item.DataItem;
            int lessonId = Convert.ToInt32(drv["LessonId"]);
            Literal status = (Literal)e.Item.FindControl("litLessonStatus");

            string badges = "";
            if (_completed.Contains(lessonId))
                badges += "<span class='badge bg-secondary ms-1'>Read ✓</span>";
            if (_passedQuiz.Contains(lessonId))
                badges += "<span class='badge bg-success ms-1'>Quiz ✓</span>";
            status.Text = badges;
        }

        protected void btnEnroll_Click(object sender, EventArgs e)
        {
            string role = Session["Role"] as string;

            if (string.IsNullOrEmpty(role))
            {
                Response.Redirect("~/Account/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }
            if (role != "Member")
            {
                lblNote.Text = "Only member accounts can enroll in courses.";
                lblNote.Visible = true;
                return;
            }

            CourseService.Enroll(UserId(), CourseId);
            int first = CourseService.GetNextLessonId(UserId(), CourseId);
            Response.Redirect("Lesson.aspx?id=" + first);
        }

        private int UserId()
        {
            return Session["UserId"] != null ? Convert.ToInt32(Session["UserId"]) : 0;
        }
    }
}