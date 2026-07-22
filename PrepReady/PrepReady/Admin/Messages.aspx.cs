using System;
using System.Data;
using PrepReady.Helpers;

namespace PrepReady.Admin
{
    public partial class Messages : BasePage
    {
        protected override string[] AllowedRoles
        {
            get { return new[] { "Admin", "Officer" }; }
        }

        private int MsgId
        {
            get { int id; return int.TryParse(Request.QueryString["id"], out id) ? id : 0; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            bool isAdmin = CurrentRole == "Admin";
            pnlAdminNav.Visible = isAdmin;
            pnlOfficerBack.Visible = !isAdmin;
            litConsole.Text = isAdmin ? "Admin console" : "Officer console";

            if (IsPostBack) return;

            if (MsgId > 0) BindThread();
            else BindInbox();
        }

        private void BindInbox()
        {
            pnlThread.Visible = false;
            pnlInbox.Visible = true;
            DataTable dt = ContactService.GetAll();
            rptMsgs.DataSource = dt;
            rptMsgs.DataBind();
            lblEmpty.Visible = dt.Rows.Count == 0;
        }

        private void BindThread()
        {
            DataRow m = ContactService.GetMessage(MsgId);
            if (m == null) { Response.Redirect("~/Admin/Messages.aspx"); return; }

            pnlInbox.Visible = false;
            pnlThread.Visible = true;

            bool resolved = Convert.ToBoolean(m["IsResolved"]);
            bool registered = m["UserId"] != DBNull.Value;

            litSubject.Text = Server.HtmlEncode(Convert.ToString(m["Subject"]));
            litFromName.Text = Server.HtmlEncode(Convert.ToString(m["FullName"]));
            litFromEmail.Text = Server.HtmlEncode(Convert.ToString(m["Email"]));
            litMetaName.Text = Server.HtmlEncode(Convert.ToString(m["FullName"]));
            litWho.Text = registered
                ? "<span class='badge bg-info text-dark'>Registered user</span>"
                : "<span class='badge bg-secondary'>Guest — reply goes by email</span>";
            litStatus.Text = resolved
                ? "<span class='badge bg-success'>Resolved</span>"
                : "<span class='badge bg-warning text-dark'>Open</span>";
            litOrigBody.Text = Server.HtmlEncode(Convert.ToString(m["Body"]));
            litOrigDate.Text = Convert.ToDateTime(m["CreatedDate"]).ToString("dd MMM yyyy, h:mm tt");

            btnResolve.Text = resolved ? "Reopen" : "Mark resolved";
            btnResolve.CommandArgument = resolved ? "reopen" : "resolve";

            DataTable th = ContactService.GetThread(MsgId);
            rptThread.DataSource = th;
            rptThread.DataBind();
        }

        protected void btnReply_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid || MsgId == 0) return;
            string body = txtReply.Text.Trim();
            if (body.Length == 0) { BindThread(); return; }

            // Officers have no Users row, so their SenderUserId stays null.
            int? senderUid = CurrentRole == "Admin" ? (int?)CurrentUserId : null;
            ContactService.AddReply(MsgId, CurrentRole, senderUid, CurrentFullName, body);

            DataRow m = ContactService.GetMessage(MsgId);
            string subject = Convert.ToString(m["Subject"]);
            txtReply.Text = "";

            lblThreadMsg.Visible = true;
            lblThreadMsg.CssClass = "alert alert-success d-block";

            if (m["UserId"] != DBNull.Value)
            {
                int ownerId = Convert.ToInt32(m["UserId"]);
                NotificationService.Notify(ownerId,
                    "New reply to your message",
                    "Support replied to: " + subject,
                    "~/Member/MyMessages.aspx?id=" + MsgId);
                lblThreadMsg.Text = "Reply posted. The member has been notified in-app.";
            }
            else
            {
                string email = Convert.ToString(m["Email"]);
                EmailHelper.Send(email, "Reply to your message — PrepReady",
                    "<p>Hi " + Server.HtmlEncode(Convert.ToString(m["FullName"])) + ",</p>" +
                    "<p>" + Server.HtmlEncode(body).Replace("\n", "<br/>") + "</p>" +
                    "<p><em>Re:</em> " + Server.HtmlEncode(subject) + "</p>");
                lblThreadMsg.Text = "Reply emailed to " + Server.HtmlEncode(email) +
                                    " (logged to App_Data/EmailLog.txt).";
            }

            BindThread();
        }

        protected void btnResolve_Click(object sender, EventArgs e)
        {
            if (MsgId == 0) return;
            ContactService.SetResolved(MsgId, btnResolve.CommandArgument == "resolve");
            BindThread();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            if (MsgId == 0) return;
            ContactService.Delete(MsgId);
            Response.Redirect("~/Admin/Messages.aspx");
        }
    }
}