using System;

namespace PrepReady
{
    public partial class SiteMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            litYear.Text = DateTime.Now.Year.ToString();

            string role = Session["Role"] as string;
            bool loggedIn = !string.IsNullOrEmpty(role);

            phAnon.Visible = !loggedIn;
            phAuth.Visible = loggedIn;
            phMember.Visible = loggedIn && role == "Member";

            if (loggedIn)
            {
                // Literal is not auto-encoded, so encode the display name manually.
                litUser.Text = Server.HtmlEncode(Session["FullName"] as string ?? "User");

                if (role == "Admin")
                    lnkDash.NavigateUrl = ResolveUrl("~/Admin/Default.aspx");
                else if (role == "Officer")
                    lnkDash.NavigateUrl = ResolveUrl("~/Officer/Portal.aspx");
                else
                    lnkDash.NavigateUrl = ResolveUrl("~/Member/Dashboard.aspx");
            }
        }
    }
}