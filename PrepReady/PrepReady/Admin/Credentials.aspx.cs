using System;
using System.Web.UI.WebControls;
using PrepReady.Helpers;

namespace PrepReady.Admin
{
    public partial class Credentials : BasePage
    {
        protected override string[] AllowedRoles { get { return new[] { "Admin" }; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) BindAll();
        }

        private void BindAll()
        {
            gvCerts.DataSource = AdminService.GetCertificates();
            gvCerts.DataBind();

            gvBadges.DataSource = AdminService.GetBadges();
            gvBadges.DataBind();

            gvRegistry.DataSource = AdminService.GetRegistry();
            gvRegistry.DataBind();
        }

        protected void gvCerts_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "Revoke") return;
            int certId = Convert.ToInt32(e.CommandArgument);
            AdminService.RevokeCertificate(certId);
            BindAll();
            ShowMsg("Certificate revoked (with any derived badge and registry entry).", true);
        }

        protected void gvRegistry_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "RemoveReg") return;
            int regId = Convert.ToInt32(e.CommandArgument);
            AdminService.DeleteRegistryEntry(regId);
            BindAll();
            ShowMsg("Registry entry removed.", true);
        }

        private void ShowMsg(string text, bool ok)
        {
            lblMsg.Text = Server.HtmlEncode(text);
            lblMsg.CssClass = "alert d-block " + (ok ? "alert-success" : "alert-danger");
            lblMsg.Visible = true;
        }
    }
}