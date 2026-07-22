<%@ Page Title="Reviews" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Reviews.aspx.cs" Inherits="PrepReady.Admin.Reviews" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <p class="pr-eyebrow mb-1">Admin console</p>
            <h1 class="pr-section-title">Course Reviews</h1>

            <nav class="pr-admin-nav" aria-label="Admin sections">
                <a href="<%: ResolveUrl("~/Admin/Default.aspx") %>">Dashboard</a>
                <a href="<%: ResolveUrl("~/Admin/Users.aspx") %>">Users</a>
                <a href="<%: ResolveUrl("~/Admin/Courses.aspx") %>">Courses</a>
                <a href="<%: ResolveUrl("~/Admin/Lessons.aspx") %>">Lessons</a>
                <a href="<%: ResolveUrl("~/Admin/Quizzes.aspx") %>">Quizzes</a>
                <a href="<%: ResolveUrl("~/Admin/Partners.aspx") %>">Partners</a>
                <a href="<%: ResolveUrl("~/Admin/Credentials.aspx") %>">Credentials</a>
                <a href="<%: ResolveUrl("~/Admin/Reviews.aspx") %>" class="active">Reviews</a>
                <a href="<%: ResolveUrl("~/Admin/Reports.aspx") %>">Reports</a>
                <a href="<%: ResolveUrl("~/Admin/LoginAudit.aspx") %>">Login Audit</a>
                <a href="<%: ResolveUrl("~/Admin/Messages.aspx") %>">Messages</a>
            </nav>

            <asp:Repeater ID="rptAdminReviews" runat="server" OnItemCommand="rptAdminReviews_ItemCommand">
                <HeaderTemplate>
                    <div class="table-responsive">
                        <table class="table align-middle">
                            <thead>
                                <tr>
                                    <th>Course</th>
                                    <th>Member</th>
                                    <th>Rating</th>
                                    <th>Comment</th>
                                    <th>Date</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Server.HtmlEncode(Eval("Course").ToString()) %></td>
                        <td><%# Server.HtmlEncode(Eval("FullName").ToString()) %></td>
                        <td class="pr-stars text-nowrap"><%# new string('\u2605', Convert.ToInt32(Eval("Rating"))) %></td>
                        <td class="text-muted small"><%# Server.HtmlEncode(Convert.ToString(Eval("Comment"))) %></td>
                        <td class="text-nowrap small"><%# Convert.ToDateTime(Eval("CreatedDate")).ToString("dd MMM yyyy") %></td>
                        <td>
                            <asp:LinkButton runat="server" CssClass="btn btn-sm btn-outline-danger" Text="Delete"
                                CommandName="del" CommandArgument='<%# Eval("ReviewId") %>'
                                OnClientClick="return confirm('Delete this review?');" />
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate></tbody></table></div></FooterTemplate>
            </asp:Repeater>

            <asp:Label ID="lblEmpty" runat="server" CssClass="alert alert-info d-block" Visible="false"
                Text="No reviews submitted yet." />
        </div>
    </section>
</asp:Content>
