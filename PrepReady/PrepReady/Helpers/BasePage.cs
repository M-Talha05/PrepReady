using System;

namespace PrepReady.Helpers
{
    /// <summary>
    /// Base page for role-gated pages. A page overrides AllowedRoles to restrict
    /// access; null/empty means the page is public. Also exposes convenient
    /// accessors for the logged-in user's session values.
    /// </summary>
    public class BasePage : System.Web.UI.Page
    {
        // Override in protected pages, e.g. return new[] { "Member" };
        protected virtual string[] AllowedRoles
        {
            get { return null; }
        }

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            string[] roles = AllowedRoles;
            if (roles != null && roles.Length > 0)
            {
                string current = Session["Role"] as string;

                if (string.IsNullOrEmpty(current))
                {
                    // Not logged in -> send to login, remember where they wanted to go.
                    Response.Redirect("~/Account/Login.aspx?returnUrl=" +
                                      Server.UrlEncode(Request.RawUrl), false);
                    Context.ApplicationInstance.CompleteRequest();
                }
                else if (Array.IndexOf(roles, current) < 0)
                {
                    // Logged in but wrong role.
                    Response.Redirect("~/Account/AccessDenied.aspx", false);
                    Context.ApplicationInstance.CompleteRequest();
                }
            }
        }

        protected int CurrentUserId
        {
            get { return Session["UserId"] != null ? Convert.ToInt32(Session["UserId"]) : 0; }
        }

        protected int CurrentOfficerId
        {
            get { return Session["OfficerId"] != null ? Convert.ToInt32(Session["OfficerId"]) : 0; }
        }

        // Returns "active" when the current page matches, for the admin tab-bar.
        protected string AdminNavActive(string pageFileName)
        {
            string current = System.IO.Path.GetFileName(Request.Path);
            return string.Equals(current, pageFileName, System.StringComparison.OrdinalIgnoreCase) ? "active" : "";
        }

        protected string CurrentRole { get { return Session["Role"] as string; } }
        protected string CurrentFullName { get { return Session["FullName"] as string; } }
    }
}