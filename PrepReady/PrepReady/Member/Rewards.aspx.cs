using System;
using System.Data;
using System.Web.UI.WebControls;
using PrepReady.Helpers;

namespace PrepReady.Member
{
    public partial class Rewards : BasePage
    {
        protected override string[] AllowedRoles { get { return new[] { "Member" }; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) BindAll();
        }

        private void BindAll()
        {
            litBalance.Text = CourseService.GetPointBalance(CurrentUserId).ToString();

            rptPartners.DataSource = RedemptionService.GetActivePartners();
            rptPartners.DataBind();

            DataTable hist = RedemptionService.GetUserRedemptions(CurrentUserId);
            gvHistory.DataSource = hist;
            gvHistory.DataBind();
            gvHistory.Visible = hist.Rows.Count > 0;
            lblNoVouchers.Visible = hist.Rows.Count == 0;
        }

        protected void rptPartners_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Redeem") return;

            int partnerId = Convert.ToInt32(e.CommandArgument);
            string code = RedemptionService.Redeem(CurrentUserId, partnerId);

            if (code == null)
                ShowMsg("You don't have enough points for that voucher.", false);
            else
                ShowMsg("Success! Your voucher code is " + code + " — see \u201CMy vouchers\u201D below.", true);

            BindAll();
        }

        private void ShowMsg(string text, bool ok)
        {
            lblMsg.Text = Server.HtmlEncode(text);
            lblMsg.CssClass = "alert d-block " + (ok ? "alert-success" : "alert-danger");
            lblMsg.Visible = true;
        }
    }
}