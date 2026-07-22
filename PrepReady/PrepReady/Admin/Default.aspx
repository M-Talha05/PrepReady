<%@ Page Title="Admin Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="PrepReady.Admin.Default" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <p class="pr-eyebrow mb-1">Admin console</p>
            <h1 class="pr-section-title">Administrator Dashboard</h1>
            <nav class="pr-admin-nav" aria-label="Admin sections">
                <a href="<%: ResolveUrl("~/Admin/Default.aspx") %>" class="active">Dashboard</a>
                <a href="<%: ResolveUrl("~/Admin/Users.aspx") %>">Users</a>
                <a href="<%: ResolveUrl("~/Admin/Courses.aspx") %>">Courses</a>
                <a href="<%: ResolveUrl("~/Admin/Lessons.aspx") %>">Lessons</a>
                <a href="<%: ResolveUrl("~/Admin/Quizzes.aspx") %>">Quizzes</a>
                <a href="<%: ResolveUrl("~/Admin/Partners.aspx") %>">Partners</a>
                <a href="<%: ResolveUrl("~/Admin/Credentials.aspx") %>">Credentials</a>
                <a href="<%: ResolveUrl("~/Admin/Reviews.aspx") %>">Reviews</a>
                <a href="<%: ResolveUrl("~/Admin/Reports.aspx") %>">Reports</a>
                <a href="<%: ResolveUrl("~/Admin/LoginAudit.aspx") %>">Login Audit</a>
                <a href="<%: ResolveUrl("~/Admin/Messages.aspx") %>">Messages</a>
            </nav>

            <div class="row g-3 my-2">
                <div class="col-6 col-md-3">
                    <div class="pr-cat-card text-center">
                        <div class="pr-stat-num">
                            <asp:Literal ID="litUsers" runat="server" />
                        </div>
                        <div class="pr-stat-label">Users</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="pr-cat-card text-center">
                        <div class="pr-stat-num">
                            <asp:Literal ID="litCourses" runat="server" />
                        </div>
                        <div class="pr-stat-label">Courses</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="pr-cat-card text-center">
                        <div class="pr-stat-num">
                            <asp:Literal ID="litLessons" runat="server" />
                        </div>
                        <div class="pr-stat-label">Lessons</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="pr-cat-card text-center">
                        <div class="pr-stat-num">
                            <asp:Literal ID="litQuizzes" runat="server" />
                        </div>
                        <div class="pr-stat-label">Quiz questions</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="pr-cat-card text-center">
                        <div class="pr-stat-num" style="color: var(--red);">
                            <asp:Literal ID="litCerts" runat="server" />
                        </div>
                        <div class="pr-stat-label">Certificates</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="pr-cat-card text-center">
                        <div class="pr-stat-num" style="color: var(--red);">
                            <asp:Literal ID="litBadges" runat="server" />
                        </div>
                        <div class="pr-stat-label">Tier 3 badges</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="pr-cat-card text-center">
                        <div class="pr-stat-num" style="color: var(--red);">
                            <asp:Literal ID="litRegistry" runat="server" />
                        </div>
                        <div class="pr-stat-label">Registry entries</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="pr-cat-card text-center">
                        <div class="pr-stat-num">
                            <asp:Literal ID="litRedemptions" runat="server" />
                        </div>
                        <div class="pr-stat-label">Redemptions</div>
                    </div>
                </div>
            </div>

            <h2 class="h4 mt-4 mb-3">Management</h2>
            <div class="row g-3">
                <div class="col-md-4">
                    <a class="pr-cat-card h-100 text-decoration-none d-block" href="<%: ResolveUrl("~/Admin/Users.aspx") %>">
                        <h3 class="h5 mb-1">Users</h3>
                        <p class="text-muted small mb-0">Edit roles, activate/deactivate, adjust points, delete.</p>
                    </a>
                </div>
                <div class="col-md-4">
                    <a class="pr-cat-card h-100 text-decoration-none d-block" href="<%: ResolveUrl("~/Admin/Courses.aspx") %>">
                        <h3 class="h5 mb-1">Courses</h3>
                        <p class="text-muted small mb-0">Create and manage courses.</p>
                    </a>
                </div>
                <div class="col-md-4">
                    <a class="pr-cat-card h-100 text-decoration-none d-block" href="<%: ResolveUrl("~/Admin/Lessons.aspx") %>">
                        <h3 class="h5 mb-1">Lessons</h3>
                        <p class="text-muted small mb-0">Manage lesson content per course.</p>
                    </a>
                </div>
                <div class="col-md-4">
                    <a class="pr-cat-card h-100 text-decoration-none d-block" href="<%: ResolveUrl("~/Admin/Quizzes.aspx") %>">
                        <h3 class="h5 mb-1">Quizzes</h3>
                        <p class="text-muted small mb-0">Manage questions &amp; final exams.</p>
                    </a>
                </div>
                <div class="col-md-4">
                    <a class="pr-cat-card h-100 text-decoration-none d-block" href="<%: ResolveUrl("~/Admin/Partners.aspx") %>">
                        <h3 class="h5 mb-1">Redemption partners</h3>
                        <p class="text-muted small mb-0">Add, edit and remove reward partners.</p>
                    </a>
                </div>
                <div class="col-md-4">
                    <a class="pr-cat-card h-100 text-decoration-none d-block" href="<%: ResolveUrl("~/Admin/Credentials.aspx") %>">
                        <h3 class="h5 mb-1">Credentials</h3>
                        <p class="text-muted small mb-0">Certificates, badges &amp; registry.</p>
                    </a>
                </div>
            </div>
        </div>
    </section>
</asp:Content>
