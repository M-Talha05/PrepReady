<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="PrepReady.Member.Dashboard" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-1">
                <h1 class="pr-section-title mb-0">Welcome back, <asp:Literal ID="litName" runat="server" />!</h1>
                <span class="pr-streak-chip">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 2C9 6 7 8 7 12a5 5 0 0 0 10 0c0-2-1-3.5-2.5-5C13.5 8.5 13 7 12 2Z"/></svg>
                    <asp:Literal ID="litStreak" runat="server" />-day login streak
                </span>
            </div>

            <%-- ===== EX-14: certificate-expiry reminder (read-only) ===== --%>
            <asp:Panel ID="pnlExpiry" runat="server" Visible="false"
                       CssClass="alert alert-warning d-flex flex-wrap align-items-start gap-3 mt-3" role="alert">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="flex:0 0 auto; margin-top:2px;">
                    <path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/>
                </svg>
                <div class="flex-grow-1">
                    <h2 class="h6 mb-1">Certificate renewal reminder</h2>
                    <p class="mb-2 small">
                        One or more of your certificates expire within the next 30 days. Renew before they
                        lapse to keep your standing on the National Recognised Responders Registry.
                    </p>
                    <ul class="mb-2 ps-3 small">
                        <asp:Repeater ID="rptExpiry" runat="server">
                            <ItemTemplate>
                                <li>
                                    <strong><%# Server.HtmlEncode(Eval("CourseTitle").ToString()) %></strong>
                                    (Tier <%# Eval("Tier") %>) — expires
                                    <%# Convert.ToDateTime(Eval("ExpiryDate")).ToString("dd MMM yyyy") %>
                                    <span class="text-danger fw-semibold">(<%# DaysLeft(Eval("ExpiryDate")) %> days left)</span>
                                </li>
                            </ItemTemplate>
                        </asp:Repeater>
                    </ul>
                    <a href="Certificates.aspx" class="btn btn-sm pr-btn-accent">Renew a certificate</a>
                </div>
            </asp:Panel>

            <div class="row g-3 my-2">
                <div class="col-6 col-md-3">
                    <div class="pr-cat-card text-center">
                        <div class="pr-stat-num"><asp:Literal ID="litPoints" runat="server" /></div>
                        <div class="pr-stat-label">Points</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="pr-cat-card text-center">
                        <div class="pr-stat-num"><asp:Literal ID="litCourses" runat="server" /></div>
                        <div class="pr-stat-label">Enrolled courses</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="pr-cat-card text-center">
                        <div class="pr-stat-num"><asp:Literal ID="litLessons" runat="server" /></div>
                        <div class="pr-stat-label">Lessons done</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="pr-cat-card text-center">
                        <div class="pr-stat-num" style="color:var(--red);"><asp:Literal ID="litCerts" runat="server" /></div>
                        <div class="pr-stat-label">Certificates</div>
                    </div>
                </div>
            </div>

            <div class="d-flex flex-wrap gap-2 mt-3">
                <a href="Points.aspx" class="btn btn-outline-secondary btn-sm">Points &amp; activity</a>
                <a href="Badges.aspx" class="btn btn-outline-secondary btn-sm">Badges</a>
                <a href="Certificates.aspx" class="btn btn-outline-secondary btn-sm">Certificates</a>
                <a href="Deployment.aspx" class="btn btn-outline-secondary btn-sm">Tier 3 deployment</a>
                <a href="Rewards.aspx" class="btn btn-outline-secondary btn-sm">Rewards</a>
                <a href="<%: ResolveUrl("~/Leaderboard.aspx") %>" class="btn btn-outline-secondary btn-sm">Leaderboard</a>
            </div>

            <div class="d-flex justify-content-between align-items-center mt-4 mb-3">
                <h2 class="h4 mb-0">My courses</h2>
                <a href="<%: ResolveUrl("~/Courses/Catalogue.aspx") %>" class="pr-btn-accent">Browse catalogue</a>
            </div>

            <asp:Label ID="lblEmpty" runat="server" CssClass="alert alert-info d-block" Visible="false"
                       Text="You haven't enrolled in any courses yet. Browse the catalogue to get started!" />

            <div class="row g-4">
                <asp:Repeater ID="rptEnrollments" runat="server">
                    <ItemTemplate>
                        <div class="col-md-6">
                            <div class="pr-cat-card">
                                <span class="pr-tag mb-2" style="align-self:flex-start;"><%# Eval("CategoryName") %></span>
                                <h3 class="pr-clamp-2"><%# Eval("Title") %></h3>
                                <div class="progress my-2" role="progressbar" style="height:12px;">
                                    <div class="progress-bar" style='width:<%# CalcPercent(Eval("CompletedLessons"), Eval("TotalLessons")) %>%;'>
                                    </div>
                                </div>
                                <small class="text-muted">
                                    <%# Eval("CompletedLessons") %>/<%# Eval("TotalLessons") %> lessons · <%# Eval("Status") %>
                                </small>
                                <a class="pr-btn-accent mt-3 text-center" href='<%# ResolveUrl("~/Courses/CourseDetail.aspx?id=" + Eval("CourseId")) %>'>Open</a>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>
</asp:Content>