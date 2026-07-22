using System;
using System.Data;
using System.Web.UI.WebControls;
using PrepReady.Helpers;

namespace PrepReady.Registry
{
    public partial class Index : System.Web.UI.Page
    {
        private const int PageSize = 6;

        private int CurrentPage
        {
            get { return ViewState["pg"] == null ? 0 : (int)ViewState["pg"]; }
            set { ViewState["pg"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindFields();
                BindResults();
            }
        }

        private void BindFields()
        {
            ddlField.Items.Clear();
            ddlField.Items.Add(new ListItem("All fields", ""));
            DataTable dt = RegistryService.GetFields();
            foreach (DataRow row in dt.Rows)
            {
                string f = Convert.ToString(row["RecognisedField"]);
                ddlField.Items.Add(new ListItem(f, f));
            }
        }

        private void BindResults()
        {
            DataTable dt = RegistryService.Search(txtSearch.Text, ddlField.SelectedValue);

            int totalPages;
            int page = PagingHelper.BindPage(rptRegistry, dt.DefaultView, CurrentPage, PageSize, out totalPages);
            CurrentPage = page;

            pnlPager.Visible = totalPages > 1;
            litPager.Text = "Page " + (page + 1) + " of " + totalPages;
            lnkPrev.CssClass = "btn pr-btn-outline btn-sm" + (page > 0 ? "" : " disabled");
            lnkNext.CssClass = "btn pr-btn-outline btn-sm" + (page < totalPages - 1 ? "" : " disabled");

            lblEmpty.Visible = dt.Rows.Count == 0;
            lblCount.Text = dt.Rows.Count + " recognised responder(s) found.";
        }

        protected void btnSearch_Click(object sender, EventArgs e) { CurrentPage = 0; BindResults(); }
        protected void lnkPrev_Click(object sender, EventArgs e) { CurrentPage = CurrentPage - 1; BindResults(); }
        protected void lnkNext_Click(object sender, EventArgs e) { CurrentPage = CurrentPage + 1; BindResults(); }

        protected void rptRegistry_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            DataRowView drv = (DataRowView)e.Item.DataItem;
            bool valid = Convert.ToDateTime(drv["ExpiryDate"]) > DateTime.Now;
            Literal litStatus = (Literal)e.Item.FindControl("litStatus");
            litStatus.Text = valid ? "<span class='badge bg-success'>Valid</span>"
                                   : "<span class='badge bg-danger'>Expired</span>";
        }
    }
}