using System;
using System.Data;
using PrepReady.Helpers;

namespace PrepReady
{
    public partial class Leaderboard : System.Web.UI.Page   // public page
    {
        private const int PageSize = 10;
        protected int RankOffset = 0;   // used by the markup for global rank numbering

        private int CurrentPage
        {
            get { return ViewState["pg"] == null ? 0 : (int)ViewState["pg"]; }
            set { ViewState["pg"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) Bind();
        }

        private void Bind()
        {
            DataTable dt = GamificationService.GetLeaderboard(200);
            DataView view = dt.DefaultView;

            int totalPages = (int)Math.Ceiling(view.Count / (double)PageSize);
            if (totalPages < 1) totalPages = 1;

            int page = CurrentPage;
            if (page >= totalPages) page = totalPages - 1;
            if (page < 0) page = 0;
            CurrentPage = page;
            RankOffset = page * PageSize;   // set BEFORE the bind so the markup sees it

            int tp;
            PagingHelper.BindPage(rptBoard, view, page, PageSize, out tp);

            pnlPager.Visible = totalPages > 1;
            litPager.Text = "Page " + (page + 1) + " of " + totalPages;
            lnkPrev.CssClass = "btn pr-btn-outline btn-sm" + (page > 0 ? "" : " disabled");
            lnkNext.CssClass = "btn pr-btn-outline btn-sm" + (page < totalPages - 1 ? "" : " disabled");

            lblEmpty.Visible = dt.Rows.Count == 0;
        }

        protected void lnkPrev_Click(object sender, EventArgs e) { CurrentPage = CurrentPage - 1; Bind(); }
        protected void lnkNext_Click(object sender, EventArgs e) { CurrentPage = CurrentPage + 1; Bind(); }
    }
}