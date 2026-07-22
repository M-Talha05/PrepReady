using System;
using System.Data;
using System.IO;
using iTextSharp.text;
using iTextSharp.text.pdf;

namespace PrepReady.Helpers
{
    /// <summary>Builds a landscape A4 certificate PDF (iTextSharp 5.x) with an embedded QR code,
    /// plus (EX-15) a portrait personal-data export PDF.</summary>
    public static class PdfHelper
    {
        private static readonly BaseColor Navy = new BaseColor(11, 31, 58);
        private static readonly BaseColor Red = new BaseColor(230, 57, 70);
        private static readonly BaseColor Grey = new BaseColor(90, 107, 123);

        public static byte[] BuildCertificate(
            string fullName, string courseTitle, string categoryName, string govPartner,
            int tier, string certCode, DateTime issueDate, DateTime expiryDate,
            string verifyUrl, byte[] qrPng)
        {
            using (MemoryStream ms = new MemoryStream())
            {
                Document doc = new Document(PageSize.A4.Rotate(), 40, 40, 50, 40);
                PdfWriter writer = PdfWriter.GetInstance(doc, ms);
                writer.CloseStream = false;
                doc.Open();

                // Decorative double border.
                PdfContentByte cb = writer.DirectContent;
                Rectangle ps = doc.PageSize;
                cb.SetColorStroke(Navy); cb.SetLineWidth(3f);
                cb.Rectangle(25, 25, ps.Width - 50, ps.Height - 50); cb.Stroke();
                cb.SetColorStroke(Red); cb.SetLineWidth(1f);
                cb.Rectangle(32, 32, ps.Width - 64, ps.Height - 64); cb.Stroke();

                Font brand = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 16, Navy);
                Font title = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 32, Navy);
                Font sub = FontFactory.GetFont(FontFactory.HELVETICA, 13, Grey);
                Font nameF = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 26, Red);
                Font body = FontFactory.GetFont(FontFactory.HELVETICA, 13, BaseColor.DARK_GRAY);
                Font courseF = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 18, Navy);
                Font idF = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 12, Navy);
                Font small = FontFactory.GetFont(FontFactory.HELVETICA, 9, Grey);

                doc.Add(Centered("PREPREADY  \u2014  Learn It. Prove It. Serve It.", brand, 12));
                doc.Add(Centered(TierTitle(tier), title, 6));
                doc.Add(Centered("This is proudly presented to", sub, 14));
                doc.Add(Centered(fullName, nameF, 10));
                doc.Add(Centered("for successfully completing the course", sub, 4));
                doc.Add(Centered(courseTitle, courseF, 2));
                doc.Add(Centered("Category: " + categoryName + "    |    Endorsed by: " + govPartner, body, 16));
                doc.Add(Centered("Issued: " + issueDate.ToString("dd MMM yyyy") +
                                 "        Valid until: " + expiryDate.ToString("dd MMM yyyy"), body, 6));
                doc.Add(Centered("Certificate ID: " + certCode, idF, 14));

                if (qrPng != null)
                {
                    Image qr = Image.GetInstance(qrPng);
                    qr.ScaleAbsolute(96, 96);
                    qr.Alignment = Element.ALIGN_CENTER;
                    doc.Add(qr);
                }

                doc.Add(Centered("Scan the QR code to verify, or visit:", small, 2));
                doc.Add(Centered(verifyUrl, small, 0));

                doc.Close();
                return ms.ToArray();
            }
        }

        /// <summary>EX-15: a portrait A4 "personal data export" — everything PrepReady holds about the member.</summary>
        public static byte[] BuildDataExport(
            DataRow profile, DataTable enrollments, DataTable certs, DataTable txns, DateTime generatedOn)
        {
            using (MemoryStream ms = new MemoryStream())
            {
                Document doc = new Document(PageSize.A4, 40, 40, 50, 40);
                PdfWriter writer = PdfWriter.GetInstance(doc, ms);
                writer.CloseStream = false;
                doc.Open();

                Font h1 = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 20, Navy);
                Font h2 = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 13, Red);
                Font lbl = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 10, Navy);
                Font val = FontFactory.GetFont(FontFactory.HELVETICA, 10, BaseColor.DARK_GRAY);
                Font small = FontFactory.GetFont(FontFactory.HELVETICA, 8, Grey);
                Font cellH = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 9, BaseColor.WHITE);
                Font cellF = FontFactory.GetFont(FontFactory.HELVETICA, 9, BaseColor.DARK_GRAY);

                doc.Add(new Paragraph("PrepReady \u2014 Personal Data Export", h1));
                doc.Add(new Paragraph("Generated " + generatedOn.ToString("dd MMM yyyy, h:mm tt"), small));
                doc.Add(Spacer(10));

                // ----- Account -----
                doc.Add(SectionHead("Account details", h2));
                PdfPTable acc = new PdfPTable(2);
                acc.WidthPercentage = 100;
                acc.SetWidths(new float[] { 30f, 70f });
                AddKV(acc, lbl, val, "Full name", Cell(profile, "FullName"));
                AddKV(acc, lbl, val, "Email", Cell(profile, "Email"));
                AddKV(acc, lbl, val, "Role", Cell(profile, "Role"));
                AddKV(acc, lbl, val, "Member since", CellDate(profile, "RegistrationDate"));
                AddKV(acc, lbl, val, "Points balance", Cell(profile, "PointBalance"));
                AddKV(acc, lbl, val, "Bio", Cell(profile, "Bio"));
                doc.Add(acc);
                doc.Add(Spacer(10));

                // ----- Certificates -----
                doc.Add(SectionHead("Certificates (" + certs.Rows.Count + ")", h2));
                if (certs.Rows.Count == 0)
                {
                    doc.Add(new Paragraph("No certificates.", val));
                }
                else
                {
                    PdfPTable t = HeaderTable(
                        new[] { "Certificate ID", "Course", "Tier", "Issued", "Valid until" },
                        new float[] { 22, 34, 10, 17, 17 }, cellH);
                    foreach (DataRow r in certs.Rows)
                    {
                        AddCell(t, cellF, Cell(r, "CertCode"));
                        AddCell(t, cellF, Cell(r, "CourseTitle"));
                        AddCell(t, cellF, "Tier " + Cell(r, "Tier"));
                        AddCell(t, cellF, CellDate(r, "IssueDate"));
                        AddCell(t, cellF, CellDate(r, "ExpiryDate"));
                    }
                    doc.Add(t);
                }
                doc.Add(Spacer(10));

                // ----- Enrolments -----
                doc.Add(SectionHead("Course enrolments (" + enrollments.Rows.Count + ")", h2));
                if (enrollments.Rows.Count == 0)
                {
                    doc.Add(new Paragraph("No enrolments.", val));
                }
                else
                {
                    PdfPTable t = HeaderTable(
                        new[] { "Course", "Category", "Progress", "Status" },
                        new float[] { 34, 30, 18, 18 }, cellH);
                    foreach (DataRow r in enrollments.Rows)
                    {
                        AddCell(t, cellF, Cell(r, "Title"));
                        AddCell(t, cellF, Cell(r, "CategoryName"));
                        AddCell(t, cellF, Cell(r, "CompletedLessons") + "/" + Cell(r, "TotalLessons") + " lessons");
                        AddCell(t, cellF, Cell(r, "Status"));
                    }
                    doc.Add(t);
                }
                doc.Add(Spacer(10));

                // ----- Points activity -----
                doc.Add(SectionHead("Points activity (" + txns.Rows.Count + ")", h2));
                if (txns.Rows.Count == 0)
                {
                    doc.Add(new Paragraph("No points activity.", val));
                }
                else
                {
                    PdfPTable t = HeaderTable(
                        new[] { "Date", "Reason", "Points" },
                        new float[] { 22, 58, 20 }, cellH);
                    foreach (DataRow r in txns.Rows)
                    {
                        AddCell(t, cellF, CellDate(r, "TxnDate"));
                        AddCell(t, cellF, Cell(r, "Reason"));
                        AddCell(t, cellF, Cell(r, "Points"));
                    }
                    doc.Add(t);
                }

                doc.Add(Spacer(14));
                doc.Add(new Paragraph(
                    "This document contains the personal data PrepReady holds about you, exported at your " +
                    "request under our privacy policy (PDPA). Keep it secure.", small));

                doc.Close();
                return ms.ToArray();
            }
        }

        // ----- shared certificate helpers -----
        private static Paragraph Centered(string text, Font font, float spacingAfter)
        {
            Paragraph p = new Paragraph(text, font) { Alignment = Element.ALIGN_CENTER, SpacingAfter = spacingAfter };
            return p;
        }

        private static string TierTitle(int tier)
        {
            if (tier == 2) return "Certificate of Completion";
            if (tier == 3) return "Government-Recognised Badge";
            return "Certificate of Participation";
        }

        // ----- EX-15 data-export helpers -----
        private static Paragraph Spacer(float h)
        {
            Paragraph p = new Paragraph(" ");
            p.SpacingAfter = h;
            return p;
        }

        private static Paragraph SectionHead(string text, Font f)
        {
            Paragraph p = new Paragraph(text, f);
            p.SpacingBefore = 6;
            p.SpacingAfter = 6;
            return p;
        }

        private static void AddKV(PdfPTable t, Font lblFont, Font valFont, string key, string value)
        {
            PdfPCell a = new PdfPCell(new Phrase(key, lblFont)) { Border = Rectangle.NO_BORDER, PaddingBottom = 4 };
            PdfPCell b = new PdfPCell(new Phrase(string.IsNullOrEmpty(value) ? "\u2014" : value, valFont))
            { Border = Rectangle.NO_BORDER, PaddingBottom = 4 };
            t.AddCell(a);
            t.AddCell(b);
        }

        private static PdfPTable HeaderTable(string[] heads, float[] widths, Font headFont)
        {
            PdfPTable t = new PdfPTable(heads.Length);
            t.WidthPercentage = 100;
            t.SetWidths(widths);
            foreach (string h in heads)
            {
                PdfPCell c = new PdfPCell(new Phrase(h, headFont)) { BackgroundColor = Navy, Padding = 5 };
                t.AddCell(c);
            }
            return t;
        }

        private static void AddCell(PdfPTable t, Font f, string text)
        {
            PdfPCell c = new PdfPCell(new Phrase(text ?? "", f)) { Padding = 4 };
            t.AddCell(c);
        }

        private static string Cell(DataRow r, string col)
        {
            if (r == null || !r.Table.Columns.Contains(col) || r[col] == DBNull.Value) return "";
            return r[col].ToString();
        }

        private static string CellDate(DataRow r, string col)
        {
            if (r == null || !r.Table.Columns.Contains(col) || r[col] == DBNull.Value) return "";
            return Convert.ToDateTime(r[col]).ToString("dd MMM yyyy");
        }
    }
}