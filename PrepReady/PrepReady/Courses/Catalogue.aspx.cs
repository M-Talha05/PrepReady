using System;
using System.Data;
using System.Web.UI.WebControls;
using PrepReady.Helpers;

namespace PrepReady.Courses
{
    public partial class Catalogue : System.Web.UI.Page   // public page (visitors allowed)
    {
        private const int PageSize = 6;

        private int CurrentPage
        {
            get { return ViewState["pg"] == null ? 0 : (int)ViewState["pg"]; }
            set { ViewState["pg"] = value; }
        }

        private bool IsMember { get { return (Session["Role"] as string) == "Member"; } }
        private int Uid { get { return Session["UserId"] != null ? Convert.ToInt32(Session["UserId"]) : 0; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCategories();
                BindCourses();
            }
        }

        private void LoadCategories()
        {
            ddlCategory.Items.Clear();
            ddlCategory.Items.Add(new ListItem("All categories", ""));
            DataTable cats = CourseService.GetCategories();
            foreach (DataRow r in cats.Rows)
            {
                string name = r["CategoryName"].ToString();
                ddlCategory.Items.Add(new ListItem(name, name));
            }
        }

        private void BindCourses()
        {
            string category = ddlCategory.SelectedValue;
            DataTable dt = CourseService.GetPublishedCourses(string.IsNullOrEmpty(category) ? null : category);
            DataView view = dt.DefaultView;

            // Keyword filter (Title or Description).
            string kw = txtSearch.Text.Trim();
            if (kw.Length > 0)
            {
                string safe = kw.Replace("'", "''").Replace("[", "[[]").Replace("%", "[%]").Replace("*", "[*]");
                view.RowFilter = "Title LIKE '%" + safe + "%' OR Description LIKE '%" + safe + "%'";
            }

            // Sort.
            switch (ddlSort.SelectedValue)
            {
                case "title_desc": view.Sort = "Title DESC"; break;
                case "lessons": view.Sort = "LessonCount DESC, Title ASC"; break;
                default: view.Sort = "Title ASC"; break;
            }

            int totalPages;
            int page = PagingHelper.BindPage(rptCourses, view, CurrentPage, PageSize, out totalPages);
            CurrentPage = page;

            pnlPager.Visible = totalPages > 1;
            litPager.Text = "Page " + (page + 1) + " of " + totalPages;
            lnkPrev.CssClass = "btn pr-btn-outline btn-sm" + (page > 0 ? "" : " disabled");
            lnkNext.CssClass = "btn pr-btn-outline btn-sm" + (page < totalPages - 1 ? "" : " disabled");

            lblEmpty.Visible = view.Count == 0;
        }

        // ===== EX-9: bookmark heart per card =====
        protected void rptCourses_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            LinkButton bm = (LinkButton)e.Item.FindControl("lnkBookmark");
            if (bm == null) return;

            if (!IsMember) { bm.Visible = false; return; }

            int courseId = Convert.ToInt32(((DataRowView)e.Item.DataItem)["CourseId"]);
            bm.Visible = true;
            SetHeart(bm, BookmarkService.IsBookmarked(Uid, courseId));
        }

        private void SetHeart(LinkButton bm, bool saved)
        {
            bm.CssClass = "pr-bm-btn" + (saved ? " saved" : "");
            bm.ToolTip = saved ? "Remove from saved courses" : "Save course";
            bm.Text =
                "<svg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' " +
                "fill='" + (saved ? "currentColor" : "none") + "' stroke='currentColor' stroke-width='2' " +
                "stroke-linecap='round' stroke-linejoin='round' aria-hidden='true'>" +
                "<path d='M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.29 1.51 4.04 3 5.5l7 7Z'/></svg>";
        }

        protected void rptCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "bm") return;

            if (!IsMember)
            {
                Response.Redirect("~/Account/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }

            BookmarkService.Toggle(Uid, Convert.ToInt32(e.CommandArgument));
            BindCourses();
        }

        protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e) { CurrentPage = 0; BindCourses(); }
        protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e) { CurrentPage = 0; BindCourses(); }
        protected void btnSearch_Click(object sender, EventArgs e) { CurrentPage = 0; BindCourses(); }
        protected void lnkPrev_Click(object sender, EventArgs e) { CurrentPage = CurrentPage - 1; BindCourses(); }
        protected void lnkNext_Click(object sender, EventArgs e) { CurrentPage = CurrentPage + 1; BindCourses(); }
    }
}