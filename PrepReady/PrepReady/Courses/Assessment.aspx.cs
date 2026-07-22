using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI.WebControls;
using PrepReady.Helpers;

namespace PrepReady.Courses
{
    // Members only.
    //   Assessment.aspx?lessonId=#         -> lesson sub-quiz (pass = 60%)
    //   Assessment.aspx?courseId=#&exam=1  -> Tier 1 final exam (pass = course PassingMark)
    //   Assessment.aspx?courseId=#&exam=2  -> Tier 2 re-exam (pass = 95%)
    public partial class Assessment : BasePage
    {
        protected override string[] AllowedRoles { get { return new[] { "Member" }; } }

        private int ExamTier
        {
            get { int t; return int.TryParse(Request.QueryString["exam"], out t) ? t : 0; }
        }
        private bool IsExam { get { return ExamTier > 0; } }

        private int _courseId;
        private int _lessonId;
        private DataRow _course;

        protected void Page_Load(object sender, EventArgs e)
        {
            ResolveContext();
            if (!IsPostBack) SetupAndBind();
        }

        private void ResolveContext()
        {
            if (IsExam)
            {
                _courseId = ParseInt(Request.QueryString["courseId"]);
                if (_courseId == 0) Response.Redirect("~/Courses/Catalogue.aspx");
            }
            else
            {
                _lessonId = ParseInt(Request.QueryString["lessonId"]);
                if (_lessonId == 0) Response.Redirect("~/Courses/Catalogue.aspx");
                DataRow lesson = CourseService.GetLesson(_lessonId);
                if (lesson == null) Response.Redirect("~/Courses/Catalogue.aspx");
                _courseId = Convert.ToInt32(lesson["CourseId"]);
            }

            _course = CourseService.GetCourse(_courseId);
            if (_course == null) Response.Redirect("~/Courses/Catalogue.aspx");

            if (!CourseService.IsEnrolled(CurrentUserId, _courseId))
                Response.Redirect("~/Courses/CourseDetail.aspx?id=" + _courseId);
        }

        private void SetupAndBind()
        {
            lnkBack.HRef = "CourseDetail.aspx?id=" + _courseId;

            if (!IsExam)
            {
                DataRow lesson = CourseService.GetLesson(_lessonId);
                litHeading.Text = "Quiz: " + Server.HtmlEncode(lesson["Title"].ToString());
                litSub.Text = "Score 60% or higher to pass. Passing on your first attempt earns 25 points.";
                BindQuestions(QuizService.GetLessonQuestions(_lessonId));
                return;
            }

            bool tier2 = ExamTier == 2;
            string title = Server.HtmlEncode(_course["Title"].ToString());

            if (tier2)
            {
                litHeading.Text = "Tier 2 Re-Exam: " + title;
                litSub.Text = "Score 95% or higher to upgrade to a Certificate of Completion.";

                DataRow cert = CertificateService.GetCertificate(CurrentUserId, _courseId);
                if (cert != null && Convert.ToInt32(cert["Tier"]) >= 2)
                {
                    ShowBlocked("You already hold a Tier 2 certificate for this course.");
                    return;
                }
                if (!CertificateService.IsTier2Eligible(CurrentUserId, _courseId))
                {
                    ShowBlocked("Tier 2 requires a valid Tier 1 certificate held for at least 6 months.");
                    return;
                }
            }
            else
            {
                litHeading.Text = "Final Exam: " + title;
                litSub.Text = "Score " + _course["PassingMark"] + "% or higher to complete the course.";

                if (QuizService.HasPassedFinalExam(CurrentUserId, _courseId))
                {
                    ShowBlocked("You have already passed this exam and completed the course.");
                    return;
                }
                if (!(QuizService.AllLessonsComplete(CurrentUserId, _courseId) &&
                      QuizService.AllQuizzesPassed(CurrentUserId, _courseId)))
                {
                    ShowBlocked("Complete all lessons and pass every lesson quiz to unlock the final exam.");
                    return;
                }
            }

            BindQuestions(QuizService.GetFinalExamQuestions(_courseId));
        }

        private void BindQuestions(DataTable questions)
        {
            if (questions.Rows.Count == 0)
            {
                ShowBlocked("No questions are available for this assessment yet.");
                return;
            }
            rptQuestions.DataSource = questions;
            rptQuestions.DataBind();
        }

        private void ShowBlocked(string msg)
        {
            lblBlocked.Text = msg;
            lblBlocked.Visible = true;
            pnlQuiz.Visible = false;
        }

        protected void rptQuestions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            DataRowView drv = (DataRowView)e.Item.DataItem;
            RadioButtonList rbl = (RadioButtonList)e.Item.FindControl("rblOptions");
            AddOption(rbl, "A", drv["OptionA"]);
            AddOption(rbl, "B", drv["OptionB"]);
            AddOption(rbl, "C", drv["OptionC"]);
            AddOption(rbl, "D", drv["OptionD"]);
        }

        private void AddOption(RadioButtonList rbl, string letter, object text)
        {
            string t = Convert.ToString(text);
            if (!string.IsNullOrWhiteSpace(t))
                rbl.Items.Add(new ListItem(letter + ") " + t, letter));
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            DataTable questions = IsExam
                ? QuizService.GetFinalExamQuestions(_courseId)
                : QuizService.GetLessonQuestions(_lessonId);

            var correct = new Dictionary<int, string>();
            foreach (DataRow r in questions.Rows)
                correct[Convert.ToInt32(r["QuizId"])] = Convert.ToString(r["CorrectOption"]);

            int score = 0, unanswered = 0;
            foreach (RepeaterItem item in rptQuestions.Items)
            {
                if (item.ItemType != ListItemType.Item && item.ItemType != ListItemType.AlternatingItem) continue;
                HiddenField hf = (HiddenField)item.FindControl("hfQuizId");
                RadioButtonList rbl = (RadioButtonList)item.FindControl("rblOptions");
                int quizId = int.Parse(hf.Value);
                string chosen = rbl.SelectedValue;
                if (string.IsNullOrEmpty(chosen)) { unanswered++; continue; }
                if (correct.ContainsKey(quizId) && chosen == correct[quizId]) score++;
            }

            if (unanswered > 0) { lblValidate.Visible = true; return; }

            int total = correct.Count;
            int pct = total == 0 ? 0 : (int)Math.Round(100.0 * score / total);

            if (!IsExam)
            {
                bool passed = pct >= 60;
                bool firstAttempt = QuizService.CountAttempts(CurrentUserId, _lessonId) == 0;
                QuizService.RecordAttempt(CurrentUserId, _courseId, _lessonId, false, score, total, pct, passed);
                if (passed && firstAttempt)
                {
                    DataRow lesson = CourseService.GetLesson(_lessonId);
                    PointsService.Award(CurrentUserId, 25, "Passed quiz: " + Convert.ToString(lesson["Title"]));
                }
                ShowResult(score, total, pct, 60, passed);
                return;
            }

            bool tier2 = ExamTier == 2;
            int threshold = tier2 ? 95 : Convert.ToInt32(_course["PassingMark"]);
            bool examPassed = pct >= threshold;
            bool alreadyPassedExam = QuizService.HasPassedFinalExam(CurrentUserId, _courseId);

            QuizService.RecordAttempt(CurrentUserId, _courseId, null, true, score, total, pct, examPassed);

            if (examPassed && !tier2 && !alreadyPassedExam)
            {
                QuizService.CompleteCourse(CurrentUserId, _courseId, pct);
                PointsService.Award(CurrentUserId, 100, "Completed course: " + Convert.ToString(_course["Title"]));
                CertificateService.IssueTier1(CurrentUserId, _courseId, GetVerifyBase());
                PointsService.Award(CurrentUserId, 50, "Earned Tier 1 certificate: " + Convert.ToString(_course["Title"]));
            }
            else if (examPassed && tier2)
            {
                CertificateService.UpgradeToTier2(CurrentUserId, _courseId);
                PointsService.Award(CurrentUserId, 100, "Upgraded to Tier 2 certificate: " + Convert.ToString(_course["Title"]));
            }

            ShowResult(score, total, pct, threshold, examPassed);
        }

        private string GetVerifyBase()
        {
            return new Uri(Request.Url, ResolveUrl("~/Verify.aspx")).AbsoluteUri + "?code=";
        }

        private void ShowResult(int score, int total, int pct, int threshold, bool passed)
        {
            pnlQuiz.Visible = false;
            pnlResult.Visible = true;

            string msg = "You scored <strong>" + score + "/" + total + " (" + pct + "%)</strong>. ";
            if (passed)
            {
                if (!IsExam) msg += "You passed this quiz.";
                else if (ExamTier == 2) msg += "You upgraded to a Tier 2 Certificate of Completion!";
                else msg += "You passed the final exam and earned your Tier 1 certificate!";
                resultBox.Attributes["class"] = "alert alert-success d-block";
            }
            else
            {
                msg += "You needed " + threshold + "%. Review the material and try again.";
                resultBox.Attributes["class"] = "alert alert-danger d-block";
            }
            litResult.Text = msg;

            if (IsExam)
            {
                lnkNext.NavigateUrl = ResolveUrl("~/Member/Certificates.aspx");
                lnkNext.Text = "View my certificates";
            }
            else
            {
                lnkNext.NavigateUrl = "CourseDetail.aspx?id=" + _courseId;
                lnkNext.Text = "Back to course";
            }
        }

        private static int ParseInt(string s)
        {
            int v; return int.TryParse(s, out v) ? v : 0;
        }
    }
}