using System;
using System.Data;
using System.Web.UI.WebControls;
using PrepReady.Helpers;

namespace PrepReady.Officer
{
    public partial class Portal : BasePage
    {
        protected override string[] AllowedRoles { get { return new[] { "Officer" }; } }

        protected decimal RequiredHrs { get { return DeploymentService.RequiredServiceHours; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                litName.Text = Server.HtmlEncode(CurrentFullName);
                BindAll();
            }
        }

        private void BindAll()
        {
            DataTable pending = DeploymentService.GetPending();
            rptPending.DataSource = pending;
            rptPending.DataBind();
            lblNoPending.Visible = pending.Rows.Count == 0;

            DataTable active = DeploymentService.GetOfficerActive(CurrentOfficerId);
            rptActive.DataSource = active;
            rptActive.DataBind();
            lblNoActive.Visible = active.Rows.Count == 0;
        }

        protected void rptPending_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int depId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "Accept")
            {
                DeploymentService.Accept(depId, CurrentOfficerId);
                ShowMsg("Deployment accepted. You can now log service sessions.");
            }
            else if (e.CommandName == "Decline")
            {
                DeploymentService.Decline(depId, CurrentOfficerId);
                ShowMsg("Deployment declined.");
            }
            BindAll();
        }

        protected void rptActive_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            DataRowView drv = (DataRowView)e.Item.DataItem;
            string code = Convert.ToString(drv["DeploymentCode"]);
            decimal hours = Convert.ToDecimal(drv["AccruedHours"]);

            Repeater rptSessions = (Repeater)e.Item.FindControl("rptSessions");
            rptSessions.DataSource = DeploymentService.GetSessions(code);
            rptSessions.DataBind();

            // Show the "issue badge" button once the required hours are reached.
            LinkButton btnIssue = (LinkButton)e.Item.FindControl("btnIssue");
            btnIssue.Visible = hours >= DeploymentService.RequiredServiceHours;
        }

        protected void rptActive_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int depId = Convert.ToInt32(e.CommandArgument);
            DataRow dep = DeploymentService.GetDeployment(depId);
            if (dep == null) return;

            if (e.CommandName == "Log")
            {
                TextBox txtDate = (TextBox)e.Item.FindControl("txtDate");
                TextBox txtHours = (TextBox)e.Item.FindControl("txtHours");
                TextBox txtNote = (TextBox)e.Item.FindControl("txtNote");

                DateTime date;
                decimal hours;
                if (!DateTime.TryParse(txtDate.Text, out date)) { ShowMsg("Enter a valid service date."); return; }
                if (!decimal.TryParse(txtHours.Text, out hours) || hours <= 0) { ShowMsg("Enter valid hours (> 0)."); return; }

                DeploymentService.LogSession(
                    Convert.ToString(dep["DeploymentCode"]),
                    Convert.ToInt32(dep["UserId"]),
                    CurrentOfficerId, date, hours, txtNote.Text.Trim());

                ShowMsg("Session logged and signed off.");
                BindAll();
            }
            else if (e.CommandName == "Issue")
            {
                string verifyBase = new Uri(Request.Url, ResolveUrl("~/Verify.aspx")).AbsoluteUri + "?code=";
                bool ok = DeploymentService.IssueBadge(depId, verifyBase);
                ShowMsg(ok
                    ? "Badge issued, learner published to the Registry, and 500 points awarded."
                    : "Could not issue badge (check the required hours and the learner's Tier 2 certificate).");
                BindAll();
            }
        }

        private void ShowMsg(string msg)
        {
            lblMsg.Text = msg;
            lblMsg.Visible = true;
        }
    }
}