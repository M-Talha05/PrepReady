using System;
using System.Configuration;
using System.IO;
using System.Net;
using System.Net.Mail;
using System.Web;

namespace PrepReady.Helpers
{
    /// <summary>
    /// Sends email via SMTP when "Email.Enabled" = true in Web.config.
    /// Otherwise (or if SMTP fails) it appends the message to
    /// App_Data/EmailLog.txt so the app never breaks during a demo.
    /// </summary>
    public static class EmailHelper
    {
        public static void Send(string toEmail, string subject, string htmlBody)
        {
            bool enabled = string.Equals(
                ConfigurationManager.AppSettings["Email.Enabled"], "true",
                StringComparison.OrdinalIgnoreCase);

            if (enabled)
            {
                try
                {
                    SendSmtp(toEmail, subject, htmlBody);
                    return;
                }
                catch (Exception ex)
                {
                    WriteToLog(toEmail, subject, htmlBody, "SMTP FAILED -> " + ex.Message);
                    return;
                }
            }

            WriteToLog(toEmail, subject, htmlBody, "SMTP DISABLED (log fallback)");
        }

        private static void SendSmtp(string toEmail, string subject, string htmlBody)
        {
            string host = ConfigurationManager.AppSettings["Email.SmtpHost"];
            int port = int.Parse(ConfigurationManager.AppSettings["Email.SmtpPort"] ?? "587");
            string user = ConfigurationManager.AppSettings["Email.User"];
            string pass = ConfigurationManager.AppSettings["Email.Password"];
            string from = ConfigurationManager.AppSettings["Email.From"] ?? user;

            using (MailMessage msg = new MailMessage(from, toEmail, subject, htmlBody))
            using (SmtpClient client = new SmtpClient(host, port))
            {
                msg.IsBodyHtml = true;
                client.EnableSsl = true;
                client.Credentials = new NetworkCredential(user, pass);
                client.Send(msg);
            }
        }

        private static void WriteToLog(string toEmail, string subject, string htmlBody, string note)
        {
            try
            {
                string dir = HttpContext.Current.Server.MapPath("~/App_Data");
                string path = Path.Combine(dir, "EmailLog.txt");
                string nl = Environment.NewLine;
                string entry =
                    "================ " + DateTime.Now + " ================" + nl +
                    "TO: " + toEmail + nl +
                    "SUBJECT: " + subject + nl +
                    "NOTE: " + note + nl +
                    "BODY:" + nl + htmlBody + nl + nl;
                File.AppendAllText(path, entry);
            }
            catch
            {
                // Never let logging break the request.
            }
        }
    }
}