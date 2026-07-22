using System;
using System.Data;
using System.Web.UI.WebControls;
using PrepReady.Helpers;

namespace PrepReady.Admin
{
    public partial class Quizzes : BasePage
    {
        protected override string[] AllowedRoles { get { return new[] { "Admin" }; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ddlLesson.DataSource = AdminService.GetLessonList();
                ddlLesson.DataBind();
                BindGrid();
            }
        }

        private int SelectedLessonId
        {
            get
            {
                int id;
                return int.TryParse(ddlLesson.SelectedValue, out id) ? id : 0;
            }
        }

        private void BindGrid()
        {
            if (SelectedLessonId == 0)
            {
                gvQuizzes.DataSource = null;
                gvQuizzes.DataBind();
                return;
            }
            gvQuizzes.DataSource = AdminService.GetQuizzes(SelectedLessonId);
            gvQuizzes.DataBind();
        }

        protected void ddlLesson_SelectedIndexChanged(object sender, EventArgs e)
        {
            ResetForm();
            BindGrid();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (SelectedLessonId == 0)
            {
                ShowMsg("Select a lesson first.", false);
                return;
            }

            string q = (txtQuestion.Text ?? "").Trim();
            string a = (txtA.Text ?? "").Trim();
            string b = (txtB.Text ?? "").Trim();
            string c = (txtC.Text ?? "").Trim();
            string d = (txtD.Text ?? "").Trim();
            string correct = ddlCorrect.SelectedValue;

            if (q.Length == 0 || a.Length == 0 || b.Length == 0)
            {
                ShowMsg("Question and at least options A and B are required.", false);
                return;
            }
            // The chosen correct option must actually have text.
            if ((correct == "C" && c.Length == 0) || (correct == "D" && d.Length == 0))
            {
                ShowMsg("The correct option points to an empty answer. Fill it in or change the correct option.", false);
                return;
            }

            if (string.IsNullOrEmpty(hfId.Value))
                AdminService.InsertQuiz(SelectedLessonId, q, a, b, c, d, correct, chkFinal.Checked);
            else
                AdminService.UpdateQuiz(Convert.ToInt32(hfId.Value), q, a, b, c, d, correct, chkFinal.Checked);

            ResetForm();
            BindGrid();
            ShowMsg("Question saved.", true);
        }

        protected void gvQuizzes_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditRow")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                DataRow r = AdminService.GetQuiz(id);
                if (r == null) return;

                hfId.Value = id.ToString();
                txtQuestion.Text = Convert.ToString(r["Question"]);
                txtA.Text = Convert.ToString(r["OptionA"]);
                txtB.Text = Convert.ToString(r["OptionB"]);
                txtC.Text = Convert.ToString(r["OptionC"]);
                txtD.Text = Convert.ToString(r["OptionD"]);
                ddlCorrect.SelectedValue = Convert.ToString(r["CorrectOption"]);
                chkFinal.Checked = Convert.ToBoolean(r["IsFinalExam"]);
                litFormTitle.Text = "Edit question #" + id;
                ShowMsg("Editing question #" + id + " — make changes and click Save.", true);
            }
            else if (e.CommandName == "DeleteRow")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                AdminService.DeleteQuiz(id);
                ResetForm();
                BindGrid();
                ShowMsg("Question deleted.", true);
            }
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            ResetForm();
        }

        private void ResetForm()
        {
            hfId.Value = "";
            txtQuestion.Text = txtA.Text = txtB.Text = txtC.Text = txtD.Text = "";
            ddlCorrect.SelectedValue = "A";
            chkFinal.Checked = false;
            litFormTitle.Text = "Add a question";
        }

        private void ShowMsg(string text, bool ok)
        {
            lblMsg.Text = Server.HtmlEncode(text);
            lblMsg.CssClass = "alert d-block " + (ok ? "alert-success" : "alert-danger");
            lblMsg.Visible = true;
        }
    }
}