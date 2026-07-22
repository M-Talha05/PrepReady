using System;
using System.Data;
using System.IO;
using System.Text;
using iTextSharp.text;
using iTextSharp.text.pdf;
using PrepReady.Helpers;

namespace PrepReady.Admin
{
    public partial class Reports : BasePage
    {
        protected override string[] AllowedRoles
        {
            get { return new[] { "Admin" }; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) BindAll();
        }

        private void BindAll()
        {
            DataRow k = ReportService.GetKpis();
            litMembers.Text = k["Members"].ToString();
            litCourses.Text = k["PublishedCourses"].ToString();
            litCerts.Text = k["Certificates"].ToString();
            litRegistry.Text = k["Registry"].ToString();
            litReviews.Text = k["Reviews"].ToString();
            litPointsAwarded.Text = ReportService.PointsAwarded().ToString("N0");
            litPointsSpent.Text = ReportService.PointsSpent().ToString("N0");

            litTierChart.Text = BuildTierChart(ReportService.GetCertificatesByTier());

            DataTable months = ReportService.GetMonthlyRegistrations();
            litMonthChart.Text = months.Rows.Count == 0
                ? "<p class='text-muted small mb-0'>No data yet.</p>"
                : BuildBarChart(months, "Ym", "Cnt");

            rptPerf.DataSource = ReportService.GetCoursePerformance();
            rptPerf.DataBind();
        }

        private string BuildTierChart(DataTable dt)
        {
            if (dt.Rows.Count == 0) return "<p class='text-muted small mb-0'>No certificates yet.</p>";
            int max = 0;
            foreach (DataRow r in dt.Rows) { int v = Convert.ToInt32(r["Cnt"]); if (v > max) max = v; }
            if (max == 0) max = 1;

            StringBuilder sb = new StringBuilder();
            foreach (DataRow r in dt.Rows)
            {
                int v = Convert.ToInt32(r["Cnt"]);
                int pct = (int)Math.Round(100.0 * v / max);
                sb.Append("<div class='pr-bar-row'><span class='pr-bar-label'>Tier " + r["Tier"] + "</span>" +
                          "<span class='pr-bar-track'><span class='pr-bar-fill' style='width:" + pct + "%'></span></span>" +
                          "<span class='pr-bar-val'>" + v + "</span></div>");
            }
            return sb.ToString();
        }

        private string BuildBarChart(DataTable dt, string labelCol, string valueCol)
        {
            int max = 0;
            foreach (DataRow r in dt.Rows) { int v = Convert.ToInt32(r[valueCol]); if (v > max) max = v; }
            if (max == 0) max = 1;

            StringBuilder sb = new StringBuilder();
            foreach (DataRow r in dt.Rows)
            {
                int v = Convert.ToInt32(r[valueCol]);
                int pct = (int)Math.Round(100.0 * v / max);
                string label = Server.HtmlEncode(Convert.ToString(r[labelCol]));
                sb.Append("<div class='pr-bar-row'><span class='pr-bar-label'>" + label + "</span>" +
                          "<span class='pr-bar-track'><span class='pr-bar-fill' style='width:" + pct + "%'></span></span>" +
                          "<span class='pr-bar-val'>" + v + "</span></div>");
            }
            return sb.ToString();
        }

        // ---------- CSV export ----------
        protected void btnCsv_Click(object sender, EventArgs e)
        {
            DataTable dt = ReportService.GetCoursePerformance();

            StringBuilder sb = new StringBuilder();
            sb.AppendLine("Course,Enrollments,Certificates,Reviews,AvgRating");
            foreach (DataRow r in dt.Rows)
            {
                sb.AppendLine(
                    CsvField(Convert.ToString(r["Title"])) + "," +
                    r["Enrollments"] + "," +
                    r["Certificates"] + "," +
                    r["Reviews"] + "," +
                    Convert.ToDouble(r["AvgRating"]).ToString("0.0"));
            }

            Response.Clear();
            Response.ContentType = "text/csv";
            Response.AddHeader("content-disposition", "attachment; filename=PrepReady_CoursePerformance.csv");
            Response.Write(sb.ToString());
            Response.End();
        }

        private static string CsvField(string s)
        {
            if (s == null) s = "";
            if (s.IndexOf(',') >= 0 || s.IndexOf('"') >= 0 || s.IndexOf('\n') >= 0)
                s = "\"" + s.Replace("\"", "\"\"") + "\"";
            return s;
        }

        // ---------- PDF export (iTextSharp 5) ----------
        protected void btnPdf_Click(object sender, EventArgs e)
        {
            DataRow k = ReportService.GetKpis();
            DataTable perf = ReportService.GetCoursePerformance();

            using (MemoryStream ms = new MemoryStream())
            {
                Document doc = new Document(PageSize.A4, 40, 40, 54, 40);
                PdfWriter.GetInstance(doc, ms);
                doc.Open();

                BaseColor navy = new BaseColor(11, 31, 58);
                Font h1 = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD, navy);
                Font h2 = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD, navy);
                Font normal = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL, BaseColor.DARK_GRAY);
                Font cellF = new Font(Font.FontFamily.HELVETICA, 9, Font.NORMAL, BaseColor.BLACK);
                Font headF = new Font(Font.FontFamily.HELVETICA, 9, Font.BOLD, BaseColor.WHITE);

                doc.Add(new Paragraph("PrepReady — Platform Report", h1));
                doc.Add(new Paragraph("Generated " + DateTime.Now.ToString("dd MMM yyyy, h:mm tt"), normal));
                doc.Add(new Paragraph(" "));

                doc.Add(new Paragraph("Summary", h2));
                doc.Add(new Paragraph(
                    "Members: " + k["Members"] + "      Published courses: " + k["PublishedCourses"] +
                    "      Certificates: " + k["Certificates"] + "      Registry entries: " + k["Registry"] +
                    "      Reviews: " + k["Reviews"], normal));
                doc.Add(new Paragraph(
                    "Points awarded: " + ReportService.PointsAwarded() +
                    "      Points spent: " + ReportService.PointsSpent(), normal));
                doc.Add(new Paragraph(" "));

                doc.Add(new Paragraph("Course performance", h2));
                doc.Add(new Paragraph(" "));

                PdfPTable t = new PdfPTable(5);
                t.WidthPercentage = 100;
                t.SetWidths(new float[] { 40, 15, 15, 15, 15 });

                AddHeaderCell(t, "Course", headF, navy);
                AddHeaderCell(t, "Enrollments", headF, navy);
                AddHeaderCell(t, "Certificates", headF, navy);
                AddHeaderCell(t, "Reviews", headF, navy);
                AddHeaderCell(t, "Avg rating", headF, navy);

                foreach (DataRow r in perf.Rows)
                {
                    t.AddCell(new Phrase(Convert.ToString(r["Title"]), cellF));
                    t.AddCell(new Phrase(Convert.ToString(r["Enrollments"]), cellF));
                    t.AddCell(new Phrase(Convert.ToString(r["Certificates"]), cellF));
                    t.AddCell(new Phrase(Convert.ToString(r["Reviews"]), cellF));
                    t.AddCell(new Phrase(Convert.ToDouble(r["AvgRating"]).ToString("0.0"), cellF));
                }
                doc.Add(t);
                doc.Close();

                byte[] bytes = ms.ToArray();
                Response.Clear();
                Response.ContentType = "application/pdf";
                Response.AddHeader("content-disposition", "attachment; filename=PrepReady_Report.pdf");
                Response.BinaryWrite(bytes);
                Response.End();
            }
        }

        private static void AddHeaderCell(PdfPTable t, string text, Font f, BaseColor bg)
        {
            PdfPCell c = new PdfPCell(new Phrase(text, f));
            c.BackgroundColor = bg;
            c.Padding = 5f;
            t.AddCell(c);
        }
    }
}