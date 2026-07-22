using System;
using System.Data;
using PrepReady.Helpers;

namespace PrepReady.Admin
{
    public partial class LoginAudit : BasePage
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
            DataTable dt = AuditService.GetRecent(200);
            litCount.Text = dt.Rows.Count.ToString();
            rptAudit.DataSource = dt;
            rptAudit.DataBind();
            lblEmpty.Visible = dt.Rows.Count == 0;
        }
    }
}