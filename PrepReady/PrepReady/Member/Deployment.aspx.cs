using System;
using System.Data;
using System.Web.UI.WebControls;
using PrepReady.Helpers;

namespace PrepReady.Member
{
    public partial class Deployment : BasePage
    {
        protected override string[] AllowedRoles { get { return new[] { "Member" }; } }

        protected decimal RequiredHrs { get { return DeploymentService.RequiredServiceHours; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) Bind();
        }

        private void Bind()
        {
            DataTable eligible = DeploymentService.GetEligibleCertificates(CurrentUserId);
            rptEligible.DataSource = eligible;
            rptEligible.DataBind();
            lblNoEligible.Visible = eligible.Rows.Count == 0;

            DataTable mine = DeploymentService.GetUserDeployments(CurrentUserId);
            rptMine.DataSource = mine;
            rptMine.DataBind();
            lblNoDeployments.Visible = mine.Rows.Count == 0;
        }

        protected void rptEligible_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Apply") return;

            int courseId = Convert.ToInt32(e.CommandArgument);
            string code = DeploymentService.Apply(CurrentUserId, courseId);
            if (code != null)
            {
                lblMsg.Text = "Application submitted! Your Deployment Code is " + code +
                              ". An officer has been notified and will review it.";
                lblMsg.Visible = true;
            }
            Bind();
        }

        protected void rptMine_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            DataRowView drv = (DataRowView)e.Item.DataItem;
            string code = Convert.ToString(drv["DeploymentCode"]);

            Repeater rptSessions = (Repeater)e.Item.FindControl("rptSessions");
            DataTable sessions = DeploymentService.GetSessions(code);
            rptSessions.DataSource = sessions;
            rptSessions.DataBind();

            Literal litNo = (Literal)e.Item.FindControl("litNoSessions");
            if (sessions.Rows.Count == 0)
                litNo.Text = "<p class='small text-muted'>No verified sessions logged yet.</p>";
        }

        protected int DepPercent(object accrued)
        {
            decimal h = Convert.ToDecimal(accrued);
            decimal req = DeploymentService.RequiredServiceHours;
            if (req <= 0) return 0;
            int p = (int)Math.Round(100m * h / req);
            return p > 100 ? 100 : p;
        }

        protected string StatusBadge(object status)
        {
            string s = Convert.ToString(status);
            string css = s == "Completed" ? "bg-success" : s == "Accepted" ? "bg-primary"
                       : s == "Declined" ? "bg-danger" : "bg-secondary";
            return "<span class='badge " + css + "'>" + s + "</span>";
        }
    }
}