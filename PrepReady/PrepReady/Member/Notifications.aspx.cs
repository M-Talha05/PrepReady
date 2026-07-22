using System;
using System.Data;
using PrepReady.Helpers;

namespace PrepReady.Member
{
    public partial class Notifications : BasePage
    {
        protected override string[] AllowedRoles
        {
            get { return new[] { "Member", "Admin" }; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // Mark all read, then clean the URL.
            if (Request.QueryString["markall"] == "1")
            {
                NotificationService.MarkAllRead(CurrentUserId);
                Response.Redirect("~/Member/Notifications.aspx");
                return;
            }

            // Open one: mark it read and jump to its target link.
            string go = Request.QueryString["go"];
            if (!string.IsNullOrEmpty(go))
            {
                int nid;
                if (int.TryParse(go, out nid))
                {
                    NotificationService.MarkRead(nid, CurrentUserId);
                    string link = NotificationService.GetLink(nid, CurrentUserId);
                    if (!string.IsNullOrEmpty(link))
                    {
                        Response.Redirect(ResolveUrl(link));
                        return;
                    }
                }
                Response.Redirect("~/Member/Notifications.aspx");
                return;
            }

            Bind();
        }

        private void Bind()
        {
            DataTable dt = NotificationService.GetAll(CurrentUserId);
            rptNotes.DataSource = dt;
            rptNotes.DataBind();
            lblEmpty.Visible = dt.Rows.Count == 0;
            pnlMarkAll.Visible = NotificationService.CountUnread(CurrentUserId) > 0;
        }

        protected void btnMarkAll_Click(object sender, EventArgs e)
        {
            NotificationService.MarkAllRead(CurrentUserId);
            Bind();
        }
    }
}