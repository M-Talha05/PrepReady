using System;
using System.Data;
using PrepReady.Helpers;

namespace PrepReady.Member
{
    public partial class CertificatePdf : BasePage
    {
        protected override string[] AllowedRoles { get { return new[] { "Member" }; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            string code = Request.QueryString["code"];
            DataRow c = string.IsNullOrEmpty(code) ? null : CertificateService.GetByCode(code);

            // Only the owner may download their certificate PDF.
            if (c == null || Convert.ToInt32(c["UserId"]) != CurrentUserId)
            {
                Response.Redirect("~/Member/Certificates.aspx");
                return;
            }

            byte[] qr = QrHelper.GeneratePng(Convert.ToString(c["QrData"]));
            byte[] pdf = PdfHelper.BuildCertificate(
                Convert.ToString(c["FullName"]),
                Convert.ToString(c["CourseTitle"]),
                Convert.ToString(c["CategoryName"]),
                Convert.ToString(c["GovPartner"]),
                Convert.ToInt32(c["Tier"]),
                Convert.ToString(c["CertCode"]),
                Convert.ToDateTime(c["IssueDate"]),
                Convert.ToDateTime(c["ExpiryDate"]),
                Convert.ToString(c["QrData"]),
                qr);

            Response.Clear();
            Response.ContentType = "application/pdf";
            Response.AddHeader("Content-Disposition", "inline; filename=PrepReady-" + code + ".pdf");
            Response.BinaryWrite(pdf);
            Response.Flush();
            Response.End();
        }
    }
}