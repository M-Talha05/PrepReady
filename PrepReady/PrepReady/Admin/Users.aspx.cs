using System;
using System.Data;
using System.Web.UI.WebControls;
using PrepReady.Helpers;

namespace PrepReady.Admin
{
    public partial class Users : BasePage
    {
        protected override string[] AllowedRoles { get { return new[] { "Admin" }; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindGrid();
                BindUserDropdown();
            }
        }

        private void BindGrid()
        {
            gvUsers.DataSource = AdminService.GetUsers();
            gvUsers.DataBind();
        }

        private void BindUserDropdown()
        {
            ddlUser.DataSource = AdminService.GetUsers();
            ddlUser.DataBind();
        }

        protected void gvUsers_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvUsers.EditIndex = e.NewEditIndex;
            BindGrid();
        }

        protected void gvUsers_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvUsers.EditIndex = -1;
            BindGrid();
        }

        protected void gvUsers_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            int userId = Convert.ToInt32(gvUsers.DataKeys[e.RowIndex].Value);
            GridViewRow row = gvUsers.Rows[e.RowIndex];

            string name = ((TextBox)row.FindControl("txtName")).Text.Trim();
            string role = ((DropDownList)row.FindControl("ddlRole")).SelectedValue;
            bool active = ((CheckBox)row.FindControl("chkActive")).Checked;

            if (name.Length == 0)
            {
                ShowMsg("Name cannot be empty.", false);
                return;
            }

            // Safety: don't let an admin demote or deactivate their own account.
            if (userId == CurrentUserId && (role != "Admin" || !active))
            {
                ShowMsg("You cannot change the role or active status of your own account.", false);
                return;
            }

            AdminService.UpdateUser(userId, name, role, active);
            gvUsers.EditIndex = -1;
            BindGrid();
            ShowMsg("User updated.", true);
        }

        protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "DeleteUser") return;

            int userId = Convert.ToInt32(e.CommandArgument);
            if (userId == CurrentUserId)
            {
                ShowMsg("You cannot delete your own account while logged in.", false);
                return;
            }

            AdminService.DeleteUser(userId);
            BindGrid();
            BindUserDropdown();
            ShowMsg("User and all related data deleted.", true);
        }

        protected void btnAdjust_Click(object sender, EventArgs e)
        {
            int delta;
            if (!int.TryParse((txtDelta.Text ?? "").Trim(), out delta) || delta == 0)
            {
                ShowMsg("Enter a non-zero whole number for the amount.", false);
                return;
            }
            string reason = (txtReason.Text ?? "").Trim();
            if (reason.Length == 0)
            {
                ShowMsg("Please give a reason for the adjustment.", false);
                return;
            }

            int userId = Convert.ToInt32(ddlUser.SelectedValue);
            AdminService.AdjustPoints(userId, delta, "Admin adjustment: " + reason);

            txtDelta.Text = "";
            txtReason.Text = "";
            BindGrid();
            ShowMsg("Points adjusted by " + delta + ".", true);
        }

        private void ShowMsg(string text, bool ok)
        {
            lblMsg.Text = Server.HtmlEncode(text);
            lblMsg.CssClass = "alert d-block " + (ok ? "alert-success" : "alert-danger");
            lblMsg.Visible = true;
        }
    }
}