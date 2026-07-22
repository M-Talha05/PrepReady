using System;
using System.Data;
using System.Web.UI.WebControls;
using PrepReady.Helpers;

namespace PrepReady.Admin
{
    public partial class Lessons : BasePage
    {
        protected override string[] AllowedRoles { get { return new[] { "Admin" }; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ddlCourse.DataSource = AdminService.GetCourseList();
                ddlCourse.DataBind();
                BindGrid();
            }
        }

        private int SelectedCourseId
        {
            get
            {
                int id;
                return int.TryParse(ddlCourse.SelectedValue, out id) ? id : 0;
            }
        }

        private void BindGrid()
        {
            if (SelectedCourseId == 0)
            {
                gvLessons.DataSource = null;
                gvLessons.DataBind();
                return;
            }
            gvLessons.DataSource = AdminService.GetLessons(SelectedCourseId);
            gvLessons.DataBind();
        }

        protected void ddlCourse_SelectedIndexChanged(object sender, EventArgs e)
        {
            ResetForm();
            BindGrid();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (SelectedCourseId == 0)
            {
                ShowMsg("Select a course first.", false);
                return;
            }

            string title = (txtTitle.Text ?? "").Trim();
            string media = (txtMedia.Text ?? "").Trim();
            string body = txtBody.Text ?? "";
            int sort;

            if (title.Length == 0)
            {
                ShowMsg("Lesson title is required.", false);
                return;
            }
            if (!int.TryParse((txtSort.Text ?? "").Trim(), out sort) || sort < 1)
            {
                ShowMsg("Sort order must be a whole number of 1 or more.", false);
                return;
            }

            if (string.IsNullOrEmpty(hfId.Value))
                AdminService.InsertLesson(SelectedCourseId, title, body, media, sort);
            else
                AdminService.UpdateLesson(Convert.ToInt32(hfId.Value), title, body, media, sort);

            ResetForm();
            BindGrid();
            ShowMsg("Lesson saved.", true);
        }

        protected void gvLessons_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditRow")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                DataRow r = AdminService.GetLesson(id);
                if (r == null) return;

                hfId.Value = id.ToString();
                txtTitle.Text = Convert.ToString(r["Title"]);
                txtMedia.Text = Convert.ToString(r["MediaUrl"]);
                txtBody.Text = Convert.ToString(r["BodyHtml"]);
                txtSort.Text = Convert.ToString(r["SortOrder"]);
                litFormTitle.Text = "Edit lesson #" + id;
                ShowMsg("Editing lesson #" + id + " — make changes and click Save.", true);
            }
            else if (e.CommandName == "DeleteRow")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                AdminService.DeleteLesson(id);
                ResetForm();
                BindGrid();
                ShowMsg("Lesson deleted.", true);
            }
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            ResetForm();
        }

        private void ResetForm()
        {
            hfId.Value = "";
            txtTitle.Text = txtMedia.Text = txtBody.Text = "";
            txtSort.Text = "1";
            litFormTitle.Text = "Add a lesson";
        }

        private void ShowMsg(string text, bool ok)
        {
            lblMsg.Text = Server.HtmlEncode(text);
            lblMsg.CssClass = "alert d-block " + (ok ? "alert-success" : "alert-danger");
            lblMsg.Visible = true;
        }
    }
}