using System;
using System.Data;
using PrepReady.Helpers;

namespace PrepReady.Member
{
    public partial class DataExportPdf : BasePage
    {
        protected override string[] AllowedRoles { get { return new[] { "Member" }; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            int uid = CurrentUserId;

            DataRow profile = ProfileService.GetProfile(uid);
            DataTable enrollments = CourseService.GetUserEnrollments(uid);
            DataTable certs = CertificateService.GetUserCertificates(uid);
            DataTable txns = PointsService.GetTransactions(uid);

            byte[] pdf = PdfHelper.BuildDataExport(profile, enrollments, certs, txns, DateTime.Now);

            Response.Clear();
            Response.ContentType = "application/pdf";
            Response.AddHeader("Content-Disposition", "attachment; filename=PrepReady-MyData-" + uid + ".pdf");
            Response.BinaryWrite(pdf);
            Response.Flush();
            Response.End();
        }
    }
}