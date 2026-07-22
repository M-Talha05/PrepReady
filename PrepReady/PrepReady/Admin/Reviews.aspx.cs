using System;
using System.Data;
using System.Web.UI.WebControls;
using PrepReady.Helpers;

namespace PrepReady.Admin
{
    public partial class Reviews : BasePage
    {
        protected override string[] AllowedRoles
        {
            get { return new[] { "Admin" }; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) Bind();
        }

        private void Bind()
        {
            DataTable dt = ReviewService.GetAllForAdmin();
            rptAdminReviews.DataSource = dt;
            rptAdminReviews.DataBind();
            lblEmpty.Visible = dt.Rows.Count == 0;
        }

        protected void rptAdminReviews_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "del")
            {
                ReviewService.Delete(Convert.ToInt32(e.CommandArgument));
                Bind();
            }
        }
    }
}