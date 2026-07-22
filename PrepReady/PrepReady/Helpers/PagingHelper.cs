using System.Data;
using System.Web.UI.WebControls;

namespace PrepReady.Helpers
{
    /// <summary>Binds a single page of a DataView to a Repeater using PagedDataSource.</summary>
    public static class PagingHelper
    {
        public static int BindPage(Repeater rpt, DataView view, int pageIndex, int pageSize, out int totalPages)
        {
            PagedDataSource pds = new PagedDataSource();
            pds.DataSource = view;
            pds.AllowPaging = true;
            pds.PageSize = pageSize;

            totalPages = pds.PageCount == 0 ? 1 : pds.PageCount;
            if (pageIndex < 0) pageIndex = 0;
            if (pageIndex >= totalPages) pageIndex = totalPages - 1;

            pds.CurrentPageIndex = pageIndex;
            rpt.DataSource = pds;
            rpt.DataBind();
            return pageIndex; // normalized/clamped
        }
    }
}