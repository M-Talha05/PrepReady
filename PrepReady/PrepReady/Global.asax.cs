using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Optimization;
using System.Web.Routing;
using System.Web.Security;
using System.Web.SessionState;

namespace PrepReady
{
    public class Global : HttpApplication
    {
        void Application_Start(object sender, EventArgs e)
        {
            // Code that runs on application startup
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
            // Finalize seeded admin/officer passwords into real BCrypt hashes (runs once).
            try
            {
                PrepReady.Helpers.AuthService.EnsureSeedAccounts();
            }
            catch
            {
                // If the DB isn't reachable at startup, ignore; pages will surface errors.
            }
        }

        // Establish the session immediately so the SessionID is stable across
        // postbacks (required for the ViewStateUserKey anti-CSRF guard below).
        // Establish the session immediately so the SessionID is stable across
        // postbacks (required for the ViewStateUserKey anti-CSRF guard below).
        void Session_Start(object sender, EventArgs e)
        {
            Session["__init"] = 1;

            // EX-16: trusted-device auto sign-in (members only). Only attempt when this
            // fresh session isn't already authenticated.
            try
            {
                HttpContext ctx = HttpContext.Current;
                if (ctx != null && Session["UserId"] == null && Session["OfficerId"] == null)
                {
                    PrepReady.Helpers.RememberService.TryAutoLogin(ctx);
                }
            }
            catch
            {
                // Never let auto-login break session start.
            }
        }

        // Anti-CSRF: tie each page's ViewState to the user's session, so a forged
        // postback from another origin fails ViewState validation.
        void Application_PreRequestHandlerExecute(object sender, EventArgs e)
        {
            System.Web.UI.Page page = HttpContext.Current.Handler as System.Web.UI.Page;
            if (page != null && Session != null)
            {
                page.ViewStateUserKey = Session.SessionID;
            }
        }

        // Log unhandled errors to App_Data so demos can show a graceful page while
        // the detail is still captured. customErrors handles the redirect.
        void Application_Error(object sender, EventArgs e)
        {
            try
            {
                Exception ex = Server.GetLastError();
                if (ex != null)
                {
                    string path = Server.MapPath("~/App_Data/ErrorLog.txt");
                    string line = DateTime.Now.ToString("u") + "  " + ex.GetBaseException() + Environment.NewLine + Environment.NewLine;
                    System.IO.File.AppendAllText(path, line);
                }
            }
            catch
            {
                // Never let logging itself throw.
            }
        }
    }
}