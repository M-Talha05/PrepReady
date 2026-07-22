<%@ Page Title="Course Catalogue" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Catalogue.aspx.cs" Inherits="PrepReady.Courses.Catalogue" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <header class="d-flex flex-wrap justify-content-between align-items-end mb-4 gap-3">
                <div>
                    <p class="pr-eyebrow mb-1">Course catalogue</p>
                    <h1 class="pr-section-title mb-1">Browse skills by category</h1>
                    <p class="text-muted mb-0">Pick a category and start learning — every course ends with a competence-based exam.</p>
                </div>
                <div class="d-flex flex-wrap gap-2 align-items-end">
                    <div style="min-width:220px;">
                        <label class="form-label" for="<%= txtSearch.ClientID %>">Search</label>
                        <div class="input-group">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search courses..." />
                            <asp:Button ID="btnSearch" runat="server" CssClass="btn pr-btn-accent" Text="Go" OnClick="btnSearch_Click" />
                        </div>
                    </div>
                    <div style="min-width:170px;">
                        <label class="form-label" for="<%= ddlCategory.ClientID %>">Category</label>
                        <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-select"
                                          AutoPostBack="true" OnSelectedIndexChanged="ddlCategory_SelectedIndexChanged" />
                    </div>
                    <div style="min-width:160px;">
                        <label class="form-label" for="<%= ddlSort.ClientID %>">Sort by</label>
                        <asp:DropDownList ID="ddlSort" runat="server" CssClass="form-select"
                                          AutoPostBack="true" OnSelectedIndexChanged="ddlSort_SelectedIndexChanged">
                            <asp:ListItem Value="title">Title (A–Z)</asp:ListItem>
                            <asp:ListItem Value="title_desc">Title (Z–A)</asp:ListItem>
                            <asp:ListItem Value="lessons">Most lessons</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
            </header>

            <asp:Label ID="lblEmpty" runat="server" CssClass="alert alert-info d-block" Visible="false"
                       Text="No courses found." />

            <div class="row g-4">
                <asp:Repeater ID="rptCourses" runat="server"
                              OnItemCommand="rptCourses_ItemCommand" OnItemDataBound="rptCourses_ItemDataBound">
                    <ItemTemplate>
                        <article class="col-sm-6 col-lg-4">
                            <div class="pr-cat-card d-flex flex-column" style="position:relative;">
                                <asp:LinkButton ID="lnkBookmark" runat="server" CssClass="pr-bm-btn"
                                                CommandName="bm" CommandArgument='<%# Eval("CourseId") %>'
                                                CausesValidation="false" Visible="false" />
                                <span class="pr-tag mb-3" style="align-self:flex-start;"><%# Eval("CategoryName") %></span>
                                <h3 class="pr-clamp-2"><%# Eval("Title") %></h3>
                                <p class="flex-grow-1 pr-clamp-3"><%# Eval("Description") %></p>
                                <div class="d-flex align-items-center gap-2 pr-card-meta mt-2 mb-3">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 5h16v14H4z"/><path d="M4 9h16"/></svg>
                                    <span><%# Eval("LessonCount") %> lessons · <%# Eval("GovPartner") %></span>
                                </div>
                                <div class="pr-card-rating mb-2">
                                    <%# PrepReady.Helpers.ReviewService.GetCount(Convert.ToInt32(Eval("CourseId"))) > 0
                                        ? PrepReady.Helpers.ReviewService.Stars(PrepReady.Helpers.ReviewService.GetAverage(Convert.ToInt32(Eval("CourseId"))))
                                          + " <small class=\"text-muted\">(" + PrepReady.Helpers.ReviewService.GetCount(Convert.ToInt32(Eval("CourseId"))) + ")</small>"
                                        : "<small class=\"text-muted\">No ratings yet</small>" %>
                                </div>
                                <a class="pr-btn-accent text-center" href='CourseDetail.aspx?id=<%# Eval("CourseId") %>'>View course</a>
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <asp:Panel ID="pnlPager" runat="server" Visible="false" CssClass="d-flex justify-content-center align-items-center gap-3 mt-4">
                <asp:LinkButton ID="lnkPrev" runat="server" CssClass="btn pr-btn-outline btn-sm" Text="← Prev" OnClick="lnkPrev_Click" />
                <span class="text-muted small"><asp:Literal ID="litPager" runat="server" /></span>
                <asp:LinkButton ID="lnkNext" runat="server" CssClass="btn pr-btn-outline btn-sm" Text="Next →" OnClick="lnkNext_Click" />
            </asp:Panel>
        </div>
    </section>
</asp:Content>