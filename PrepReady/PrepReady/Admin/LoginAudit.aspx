<%@ Page Title="Login Audit" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LoginAudit.aspx.cs" Inherits="PrepReady.Admin.LoginAudit" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <p class="pr-eyebrow mb-1">Admin console</p>
            <h1 class="pr-section-title">Login Audit</h1>

            <nav class="pr-admin-nav" aria-label="Admin sections">
                <a href="<%: ResolveUrl("~/Admin/Default.aspx") %>">Dashboard</a>
                <a href="<%: ResolveUrl("~/Admin/Users.aspx") %>">Users</a>
                <a href="<%: ResolveUrl("~/Admin/Courses.aspx") %>">Courses</a>
                <a href="<%: ResolveUrl("~/Admin/Lessons.aspx") %>">Lessons</a>
                <a href="<%: ResolveUrl("~/Admin/Quizzes.aspx") %>">Quizzes</a>
                <a href="<%: ResolveUrl("~/Admin/Partners.aspx") %>">Partners</a>
                <a href="<%: ResolveUrl("~/Admin/Credentials.aspx") %>">Credentials</a>
                <a href="<%: ResolveUrl("~/Admin/Reviews.aspx") %>">Reviews</a>
                <a href="<%: ResolveUrl("~/Admin/Reports.aspx") %>">Reports</a>
                <a href="<%: ResolveUrl("~/Admin/LoginAudit.aspx") %>" class="active">Login Audit</a>
                <a href="<%: ResolveUrl("~/Admin/Messages.aspx") %>">Messages</a>
            </nav>

            <p class="text-muted">
                Most recent
                <asp:Literal ID="litCount" runat="server" />
                attempts.
        Accounts lock for <%= PrepReady.Helpers.AuditService.LockoutMinutes %> minutes after
        <%= PrepReady.Helpers.AuditService.MaxAttempts %> consecutive failures.
            </p>

            <div class="table-responsive">
                <table class="table align-middle">
                    <thead>
                        <tr>
                            <th>When</th>
                            <th>Email</th>
                            <th>Name</th>
                            <th>Result</th>
                            <th>IP</th>
                            <th>Note</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptAudit" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td class="text-nowrap"><%# Convert.ToDateTime(Eval("AttemptDate")).ToString("dd MMM yyyy, h:mm tt") %></td>
                                    <td><%# Server.HtmlEncode(Eval("Email").ToString()) %></td>
                                    <td><%# Eval("FullName") == DBNull.Value ? "<span class=\"text-muted\">&mdash;</span>" : Server.HtmlEncode(Eval("FullName").ToString()) %></td>
                                    <td>
                                        <%# Convert.ToBoolean(Eval("Success"))
                        ? "<span class=\"badge bg-success\">Success</span>"
                        : "<span class=\"badge bg-danger\">Failed</span>" %>
                                    </td>
                                    <td class="text-muted small"><%# Server.HtmlEncode(Eval("IpAddress").ToString()) %></td>
                                    <td class="text-muted small"><%# Server.HtmlEncode(Eval("Note").ToString()) %></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>

            <asp:Label ID="lblEmpty" runat="server" CssClass="alert alert-info d-block" Visible="false"
                Text="No login attempts recorded yet." />
        </div>
    </section>
</asp:Content>
