using System;
using System.Data;
using PrepReady.Helpers;

namespace PrepReady
{
    public partial class Verify : System.Web.UI.Page   // public page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string code = Request.QueryString["code"];
                if (!string.IsNullOrEmpty(code))
                {
                    txtCode.Text = code;
                    ShowResult(code.Trim());
                }
            }
        }

        protected void btnCheck_Click(object sender, EventArgs e)
        {
            Response.Redirect("Verify.aspx?code=" + Server.UrlEncode(txtCode.Text.Trim()));
        }

        private void ShowResult(string code)
        {
            DataRow c = CertificateService.GetByCode(code);
            if (c == null)
            {
                lblNotFound.Visible = true;
                pnlResult.Visible = false;
                return;
            }

            int tier = Convert.ToInt32(c["Tier"]);
            DateTime expiry = Convert.ToDateTime(c["ExpiryDate"]);
            bool valid = expiry > DateTime.Now;

            litName.Text = Server.HtmlEncode(c["FullName"].ToString());
            litCourse.Text = Server.HtmlEncode(c["CourseTitle"].ToString());
            litTier.Text = "Tier " + tier + " — " + CertificateService.TierName(tier);
            litPartner.Text = Server.HtmlEncode(Convert.ToString(c["GovPartner"]));
            litIssue.Text = Convert.ToDateTime(c["IssueDate"]).ToString("dd MMM yyyy");
            litExpiry.Text = expiry.ToString("dd MMM yyyy");
            litCode.Text = Server.HtmlEncode(c["CertCode"].ToString());
            litStatus.Text = valid
                ? "<span class='badge bg-success'>VALID</span>"
                : "<span class='badge bg-danger'>EXPIRED</span>";

            // QR as inline base64 (no extra endpoint needed).
            byte[] qr = QrHelper.GeneratePng(Convert.ToString(c["QrData"]));
            imgQr.Src = "data:image/png;base64," + Convert.ToBase64String(qr);

            pnlResult.Visible = true;
            lblNotFound.Visible = false;
        }
    }
}