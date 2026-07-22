using System;
using System.Data;
using PrepReady.Helpers;

namespace PrepReady.Member
{
    public partial class MyMessages : BasePage
    {
        protected override string[] AllowedRoles
        {
            get { return new[] { "Member", "Admin" }; }
        }

        private int MsgId
        {
            get { int id; return int.TryParse(Request.QueryString["id"], out id) ? id : 0; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            if (MsgId > 0)
            {
                if (!ContactService.IsOwner(MsgId, CurrentUserId))
                {
                    Response.Redirect("~/Member/MyMessages.aspx");
                    return;
                }
                BindThread();
            }
            else
            {
                BindList();
            }
        }

        private void BindList()
        {
            pnlThread.Visible = false;
            pnlList.Visible = true;
            DataTable dt = ContactService.GetThreadsForUser(CurrentUserId);
            rptThreads.DataSource = dt;
            rptThreads.DataBind();
            lblEmpty.Visible = dt.Rows.Count == 0;
        }

        private void BindThread()
        {
            DataRow m = ContactService.GetMessage(MsgId);
            if (m == null) { Response.Redirect("~/Member/MyMessages.aspx"); return; }

            pnlList.Visible = false;
            pnlThread.Visible = true;

            bool resolved = Convert.ToBoolean(m["IsResolved"]);
            litSubject.Text = Server.HtmlEncode(Convert.ToString(m["Subject"]));
            litStatus.Text = resolved
                ? "<span class='badge bg-success'>Resolved</span>"
                : "<span class='badge bg-warning text-dark'>Open</span>";
            litOrigBody.Text = Server.HtmlEncode(Convert.ToString(m["Body"]));
            litOrigDate.Text = Convert.ToDateTime(m["CreatedDate"]).ToString("dd MMM yyyy, h:mm tt");

            DataTable th = ContactService.GetThread(MsgId);
            rptReplies.DataSource = th;
            rptReplies.DataBind();

            lblResolved.Visible = resolved;
        }

        protected void btnReply_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid || MsgId == 0) return;
            if (!ContactService.IsOwner(MsgId, CurrentUserId))
            {
                Response.Redirect("~/Member/MyMessages.aspx");
                return;
            }

            string body = txtReply.Text.Trim();
            if (body.Length == 0) { BindThread(); return; }

            ContactService.AddReply(MsgId, "User", CurrentUserId, CurrentFullName, body);
            ContactService.Reopen(MsgId);  // a fresh user reply reopens the conversation for staff
            txtReply.Text = "";
            BindThread();
        }
    }
}