using System;
using System.Data;
using System.Web.UI.WebControls;
using PrepReady.Helpers;

namespace PrepReady.Admin
{
    public partial class Courses : BasePage
    {
        protected override string[] AllowedRoles { get { return new[] { "Admin" }; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) BindGrid();
        }

        private void BindGrid()
        {
            gvCourses.DataSource = AdminService.GetCourses();
            gvCourses.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string cat = (txtCategory.Text ?? "").Trim();
            string title = (txtTitle.Text ?? "").Trim();
            string desc = (txtDesc.Text ?? "").Trim();
            string gov = (txtGov.Text ?? "").Trim();

            int pass;
            if (cat.Length == 0 || title.Length == 0)
            {
                ShowMsg("Category and title are required.", false);
                return;
            }
            if (!int.TryParse((txtPass.Text ?? "").Trim(), out pass) || pass < 0 || pass > 100)
            {
                ShowMsg("Passing mark must be a whole number from 0 to 100.", false);
                return;
            }

            if (string.IsNullOrEmpty(hfId.Value))
                AdminService.InsertCourse(cat, title, desc, gov, pass, chkPub.Checked);
            else
                AdminService.UpdateCourse(Convert.ToInt32(hfId.Value), cat, title, desc, gov, pass, chkPub.Checked);

            ResetForm();
            BindGrid();
            ShowMsg("Course saved.", true);
        }

        protected void gvCourses_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditRow")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                DataRow r = AdminService.GetCourse(id);
                if (r == null) return;

                hfId.Value = id.ToString();
                txtCategory.Text = Convert.ToString(r["CategoryName"]);
                txtTitle.Text = Convert.ToString(r["Title"]);
                txtDesc.Text = Convert.ToString(r["Description"]);
                txtGov.Text = Convert.ToString(r["GovPartner"]);
                txtPass.Text = Convert.ToString(r["PassingMark"]);
                chkPub.Checked = Convert.ToBoolean(r["IsPublished"]);
                litFormTitle.Text = "Edit course #" + id;
                ShowMsg("Editing course #" + id + " — make changes and click Save.", true);
            }
            else if (e.CommandName == "DeleteRow")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                if (AdminService.CourseHasDependents(id))
                {
                    ShowMsg("Can't delete: this course has lessons, enrolments or certificates. Remove those first.", false);
                    return;
                }
                AdminService.DeleteCourse(id);
                ResetForm();
                BindGrid();
                ShowMsg("Course deleted.", true);
            }
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            ResetForm();
        }

        private void ResetForm()
        {
            hfId.Value = "";
            txtCategory.Text = txtTitle.Text = txtDesc.Text = txtGov.Text = "";
            txtPass.Text = "60";
            chkPub.Checked = true;
            litFormTitle.Text = "Add a course";
        }

        private void ShowMsg(string text, bool ok)
        {
            lblMsg.Text = Server.HtmlEncode(text);
            lblMsg.CssClass = "alert d-block " + (ok ? "alert-success" : "alert-danger");
            lblMsg.Visible = true;
        }
    }
}