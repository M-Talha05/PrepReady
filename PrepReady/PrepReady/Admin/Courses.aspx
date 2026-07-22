<%@ Page Title="Manage Courses" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Courses.aspx.cs" Inherits="PrepReady.Admin.Courses" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <p class="pr-eyebrow mb-1">Admin console</p>
            <h1 class="pr-section-title">Manage Courses</h1>
            <nav class="pr-admin-nav" aria-label="Admin sections">
                <a href="<%: ResolveUrl("~/Admin/Default.aspx") %>">Dashboard</a>
                <a href="<%: ResolveUrl("~/Admin/Users.aspx") %>">Users</a>
                <a href="<%: ResolveUrl("~/Admin/Courses.aspx") %>" class="active">Courses</a>
                <a href="<%: ResolveUrl("~/Admin/Lessons.aspx") %>">Lessons</a>
                <a href="<%: ResolveUrl("~/Admin/Quizzes.aspx") %>">Quizzes</a>
                <a href="<%: ResolveUrl("~/Admin/Partners.aspx") %>">Partners</a>
                <a href="<%: ResolveUrl("~/Admin/Credentials.aspx") %>">Credentials</a>
                <a href="<%: ResolveUrl("~/Admin/Reviews.aspx") %>">Reviews</a>
                <a href="<%: ResolveUrl("~/Admin/Reports.aspx") %>">Reports</a>
                <a href="<%: ResolveUrl("~/Admin/LoginAudit.aspx") %>">Login Audit</a>
                <a href="<%: ResolveUrl("~/Admin/Messages.aspx") %>">Messages</a>
            </nav>

            <asp:Label ID="lblMsg" runat="server" Visible="false" CssClass="alert d-block" />

            <div class="pr-cat-card mb-4">
                <h2 class="h5 mb-3">
                    <asp:Literal ID="litFormTitle" runat="server" Text="Add a course" /></h2>
                <asp:HiddenField ID="hfId" runat="server" />
                <div class="row g-2">
                    <div class="col-md-4">
                        <label class="form-label small">Category</label>
                        <asp:TextBox ID="txtCategory" runat="server" CssClass="form-control" />
                    </div>
                    <div class="col-md-8">
                        <label class="form-label small">Title</label>
                        <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" />
                    </div>
                    <div class="col-12">
                        <label class="form-label small">Description</label>
                        <asp:TextBox ID="txtDesc" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label small">Government partner</label>
                        <asp:TextBox ID="txtGov" runat="server" CssClass="form-control" />
                    </div>
                    <div class="col-md-3">
                        <label class="form-label small">Passing mark (%)</label>
                        <asp:TextBox ID="txtPass" runat="server" CssClass="form-control" Text="60" />
                    </div>
                    <div class="col-md-3 d-flex align-items-end">
                        <div class="form-check">
                            <asp:CheckBox ID="chkPub" runat="server" Checked="true" /><label class="form-check-label small">Published</label>
                        </div>
                    </div>
                </div>
                <asp:Button ID="btnSave" runat="server" Text="Save course" CssClass="pr-btn-accent mt-3" OnClick="btnSave_Click" />
                <asp:Button ID="btnReset" runat="server" Text="Clear" CssClass="btn btn-outline-secondary mt-3" OnClick="btnReset_Click" CausesValidation="false" />
            </div>

            <div class="table-responsive">
                <asp:GridView ID="gvCourses" runat="server" AutoGenerateColumns="false" DataKeyNames="CourseId"
                    CssClass="table table-striped align-middle" GridLines="None" OnRowCommand="gvCourses_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="CourseId" HeaderText="ID" />
                        <asp:TemplateField HeaderText="Category">
                            <ItemTemplate><%# Server.HtmlEncode(Convert.ToString(Eval("CategoryName"))) %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Title">
                            <ItemTemplate><%# Server.HtmlEncode(Convert.ToString(Eval("Title"))) %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="PassingMark" HeaderText="Pass %" />
                        <asp:TemplateField HeaderText="Published">
                            <ItemTemplate><%# Convert.ToBoolean(Eval("IsPublished")) ? "<span class='badge bg-success'>Yes</span>" : "<span class='badge bg-secondary'>No</span>" %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="LessonCount" HeaderText="Lessons" />
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn btn-sm btn-outline-secondary" CommandName="EditRow" CommandArgument='<%# Eval("CourseId") %>' Text="Edit" />
                                <asp:LinkButton ID="btnDel" runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="DeleteRow" CommandArgument='<%# Eval("CourseId") %>' Text="Delete"
                                    OnClientClick="return confirm('Delete this course?');" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </section>
</asp:Content>
