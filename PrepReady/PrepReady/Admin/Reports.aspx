<%@ Page Title="Reports" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Reports.aspx.cs" Inherits="PrepReady.Admin.Reports" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <p class="pr-eyebrow mb-1">Admin console</p>
            <h1 class="pr-section-title">Reports &amp; Analytics</h1>

            <nav class="pr-admin-nav" aria-label="Admin sections">
                <a href="<%: ResolveUrl("~/Admin/Default.aspx") %>">Dashboard</a>
                <a href="<%: ResolveUrl("~/Admin/Users.aspx") %>">Users</a>
                <a href="<%: ResolveUrl("~/Admin/Courses.aspx") %>">Courses</a>
                <a href="<%: ResolveUrl("~/Admin/Lessons.aspx") %>">Lessons</a>
                <a href="<%: ResolveUrl("~/Admin/Quizzes.aspx") %>">Quizzes</a>
                <a href="<%: ResolveUrl("~/Admin/Partners.aspx") %>">Partners</a>
                <a href="<%: ResolveUrl("~/Admin/Credentials.aspx") %>">Credentials</a>
                <a href="<%: ResolveUrl("~/Admin/Reviews.aspx") %>">Reviews</a>
                <a href="<%: ResolveUrl("~/Admin/Reports.aspx") %>" class="active">Reports</a>
                <a href="<%: ResolveUrl("~/Admin/LoginAudit.aspx") %>">Login Audit</a>
                <a href="<%: ResolveUrl("~/Admin/Messages.aspx") %>">Messages</a>
            </nav>

            <div class="d-flex justify-content-end gap-2 mb-3">
                <asp:Button ID="btnCsv" runat="server" CssClass="btn pr-btn-outline" Text="Export CSV" OnClick="btnCsv_Click" />
                <asp:Button ID="btnPdf" runat="server" CssClass="btn pr-btn-navy" Text="Export PDF" OnClick="btnPdf_Click" />
            </div>

            <!-- KPI cards -->
            <div class="row g-3 mb-3">
                <div class="col-6 col-md-3">
                    <div class="pr-cat-card text-center">
                        <div class="pr-stat-num">
                            <asp:Literal ID="litMembers" runat="server" />
                        </div>
                        <div class="pr-stat-label">Members</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="pr-cat-card text-center">
                        <div class="pr-stat-num">
                            <asp:Literal ID="litCourses" runat="server" />
                        </div>
                        <div class="pr-stat-label">Published courses</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="pr-cat-card text-center">
                        <div class="pr-stat-num">
                            <asp:Literal ID="litCerts" runat="server" />
                        </div>
                        <div class="pr-stat-label">Certificates</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="pr-cat-card text-center">
                        <div class="pr-stat-num">
                            <asp:Literal ID="litRegistry" runat="server" />
                        </div>
                        <div class="pr-stat-label">Registry entries</div>
                    </div>
                </div>
            </div>
            <div class="row g-3 mb-4">
                <div class="col-6 col-md-3">
                    <div class="pr-cat-card text-center">
                        <div class="pr-stat-num">
                            <asp:Literal ID="litReviews" runat="server" />
                        </div>
                        <div class="pr-stat-label">Reviews</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="pr-cat-card text-center">
                        <div class="pr-stat-num">
                            <asp:Literal ID="litPointsAwarded" runat="server" />
                        </div>
                        <div class="pr-stat-label">Points awarded</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="pr-cat-card text-center">
                        <div class="pr-stat-num">
                            <asp:Literal ID="litPointsSpent" runat="server" />
                        </div>
                        <div class="pr-stat-label">Points spent</div>
                    </div>
                </div>
            </div>

            <div class="row g-4">
                <div class="col-lg-6">
                    <div class="card">
                        <div class="card-body">
                            <h2 class="h6 text-uppercase text-muted mb-3">Certificates by tier</h2>
                            <asp:Literal ID="litTierChart" runat="server" />
                        </div>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="card">
                        <div class="card-body">
                            <h2 class="h6 text-uppercase text-muted mb-3">New members (last 6 months)</h2>
                            <asp:Literal ID="litMonthChart" runat="server" />
                        </div>
                    </div>
                </div>
            </div>

            <h2 class="h5 mt-4 mb-3">Course performance</h2>
            <asp:Repeater ID="rptPerf" runat="server">
                <HeaderTemplate>
                    <div class="table-responsive">
                        <table class="table align-middle">
                            <thead>
                                <tr>
                                    <th>Course</th>
                                    <th class="text-end">Enrollments</th>
                                    <th class="text-end">Certificates</th>
                                    <th class="text-end">Reviews</th>
                                    <th class="text-end">Avg rating</th>
                                </tr>
                            </thead>
                            <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Server.HtmlEncode(Convert.ToString(Eval("Title"))) %></td>
                        <td class="text-end"><%# Eval("Enrollments") %></td>
                        <td class="text-end"><%# Eval("Certificates") %></td>
                        <td class="text-end"><%# Eval("Reviews") %></td>
                        <td class="text-end"><%# Convert.ToDouble(Eval("AvgRating")).ToString("0.0") %></td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate></tbody></table></div></FooterTemplate>
            </asp:Repeater>
        </div>
    </section>
</asp:Content>
