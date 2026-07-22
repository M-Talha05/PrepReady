using System;
using System.Web.UI.WebControls;
using PrepReady.Helpers;

namespace PrepReady.Admin
{
    public partial class Partners : BasePage
    {
        protected override string[] AllowedRoles { get { return new[] { "Admin" }; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) BindGrid();
        }

        private void BindGrid()
        {
            gvPartners.DataSource = AdminService.GetPartners();
            gvPartners.DataBind();
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            string name = (txtName.Text ?? "").Trim();
            string type = (txtType.Text ?? "").Trim();
            string voucher = (txtVoucher.Text ?? "").Trim();

            int cost;
            if (name.Length == 0 || type.Length == 0 || voucher.Length == 0)
            {
                ShowMsg("Name, type and voucher title are all required.", false);
                return;
            }
            if (!int.TryParse((txtCost.Text ?? "").Trim(), out cost) || cost < 0)
            {
                ShowMsg("Point cost must be a whole number of 0 or more.", false);
                return;
            }

            AdminService.InsertPartner(name, type, voucher, cost, chkActive.Checked);

            txtName.Text = txtType.Text = txtVoucher.Text = "";
            txtCost.Text = "100";
            chkActive.Checked = true;
            BindGrid();
            ShowMsg("Partner added.", true);
        }

        protected void gvPartners_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvPartners.EditIndex = e.NewEditIndex;
            BindGrid();
        }

        protected void gvPartners_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvPartners.EditIndex = -1;
            BindGrid();
        }

        protected void gvPartners_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            int id = Convert.ToInt32(gvPartners.DataKeys[e.RowIndex].Value);
            GridViewRow row = gvPartners.Rows[e.RowIndex];

            string name = ((TextBox)row.FindControl("txtEName")).Text.Trim();
            string type = ((TextBox)row.FindControl("txtEType")).Text.Trim();
            string voucher = ((TextBox)row.FindControl("txtEVoucher")).Text.Trim();
            bool active = ((CheckBox)row.FindControl("chkEActive")).Checked;

            int cost;
            if (name.Length == 0 || type.Length == 0 || voucher.Length == 0)
            {
                ShowMsg("Name, type and voucher title are all required.", false);
                return;
            }
            if (!int.TryParse(((TextBox)row.FindControl("txtECost")).Text.Trim(), out cost) || cost < 0)
            {
                ShowMsg("Point cost must be a whole number of 0 or more.", false);
                return;
            }

            AdminService.UpdatePartner(id, name, type, voucher, cost, active);
            gvPartners.EditIndex = -1;
            BindGrid();
            ShowMsg("Partner updated.", true);
        }

        protected void gvPartners_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "DeletePartner") return;
            int id = Convert.ToInt32(e.CommandArgument);
            AdminService.DeletePartner(id);
            BindGrid();
            ShowMsg("Partner deleted.", true);
        }

        private void ShowMsg(string text, bool ok)
        {
            lblMsg.Text = Server.HtmlEncode(text);
            lblMsg.CssClass = "alert d-block " + (ok ? "alert-success" : "alert-danger");
            lblMsg.Visible = true;
        }
    }
}