using System;
using System.Data;
using System.Web.UI.WebControls;
using PrepReady.Helpers;

namespace PrepReady.Member
{
    public partial class Certificates : BasePage
    {
        protected override string[] AllowedRoles { get { return new[] { "Member" }; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) Bind();
        }

        private void Bind()
        {
            DataTable dt = CertificateService.GetUserCertificates(CurrentUserId);
            rptCerts.DataSource = dt;
            rptCerts.DataBind();
            lblEmpty.Visible = dt.Rows.Count == 0;
        }

        protected void rptCerts_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            DataRowView drv = (DataRowView)e.Item.DataItem;
            int tier = Convert.ToInt32(drv["Tier"]);
            DateTime issue = Convert.ToDateTime(drv["IssueDate"]);
            DateTime expiry = Convert.ToDateTime(drv["ExpiryDate"]);
            bool valid = expiry > DateTime.Now;

            Literal litTier = (Literal)e.Item.FindControl("litTier");
            Literal litDates = (Literal)e.Item.FindControl("litDates");
            Literal litStatus = (Literal)e.Item.FindControl("litStatus");
            Literal litNote = (Literal)e.Item.FindControl("litTierNote");
            LinkButton btnTier2 = (LinkButton)e.Item.FindControl("btnTier2");
            LinkButton btnRenew = (LinkButton)e.Item.FindControl("btnRenew");

            litTier.Text = "Tier " + tier + " — " + CertificateService.TierName(tier);
            litDates.Text = "Issued " + issue.ToString("dd MMM yyyy") + " · Valid until " + expiry.ToString("dd MMM yyyy");
            litStatus.Text = valid ? "<span class='badge bg-success'>Valid</span>"
                                   : "<span class='badge bg-danger'>Expired</span>";

            bool tier2Eligible = tier == 1 && valid && issue <= DateTime.Now.AddMonths(-6);
            btnTier2.Visible = tier2Eligible;

            // Renewal is available while the certificate is still valid (before expiry).
            btnRenew.Visible = valid;

            if (tier == 1 && valid && !tier2Eligible)
                litNote.Text = "<p class='small text-muted mt-2 mb-0'>Tier 2 upgrade unlocks 6 months after issue.</p>";
            else if (tier >= 2 && valid)
                litNote.Text = "<p class='small mt-2 mb-0'><a href='Deployment.aspx'>Apply for the Tier 3 Government-Recognised Badge</a> via verified community service.</p>";
        }

        protected void rptCerts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int courseId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "Tier2")
            {
                string email = Session["Email"] as string;
                if (!string.IsNullOrEmpty(email))
                {
                    EmailHelper.Send(email, "Your Tier 2 pathway is unlocked",
                        "<p>Your Tier 2 Certificate of Completion pathway is now available. " +
                        "Complete the refresher and re-sit the exam (score 95% or higher) to upgrade.</p>");
                }
                Response.Redirect("~/Courses/Assessment.aspx?courseId=" + courseId + "&exam=2");
                return;
            }

            if (e.CommandName == "Renew")
            {
                int tier = CertificateService.RenewCertificate(CurrentUserId, courseId);
                int basePts = tier >= 2 ? 200 : 100;                 // base "complete course" points by tier
                int award = (int)(basePts * 1.5);                    // 1.5× renewal multiplier
                PointsService.Award(CurrentUserId, award, "Renewed certificate (1.5× course points)");
                Bind();
            }
        }
    }
}