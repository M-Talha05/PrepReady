using System;
using System.Web;
using System.Web.SessionState;

namespace PrepReady
{
    // Implements IRequiresSessionState so that simply handling this request
    // reacquires session state and resets the InProc sliding timeout.
    public class KeepAlive : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

            // The user is still "alive" only if a role is present in the session.
            // (After a real timeout ASP.NET hands us a brand-new empty session.)
            bool alive = context.Session != null && context.Session["Role"] != null;

            if (alive)
            {
                context.Session["__lastPing"] = DateTime.Now.Ticks;
                context.Response.Write("ok");
            }
            else
            {
                context.Response.Write("expired");
            }
        }

        public bool IsReusable
        {
            get { return false; }
        }
    }
}