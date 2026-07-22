<%@ Page Title="Manage Lessons" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Lessons.aspx.cs" Inherits="PrepReady.Admin.Lessons" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <p class="pr-eyebrow mb-1">Admin console</p>
            <h1 class="pr-section-title">Manage Lessons</h1>
            <nav class="pr-admin-nav" aria-label="Admin sections">
                <a href="<%: ResolveUrl("~/Admin/Default.aspx") %>">Dashboard</a>
                <a href="<%: ResolveUrl("~/Admin/Users.aspx") %>">Users</a>
                <a href="<%: ResolveUrl("~/Admin/Courses.aspx") %>">Courses</a>
                <a href="<%: ResolveUrl("~/Admin/Lessons.aspx") %>" class="active">Lessons</a>
                <a href="<%: ResolveUrl("~/Admin/Quizzes.aspx") %>">Quizzes</a>
                <a href="<%: ResolveUrl("~/Admin/Partners.aspx") %>">Partners</a>
                <a href="<%: ResolveUrl("~/Admin/Credentials.aspx") %>">Credentials</a>
                <a href="<%: ResolveUrl("~/Admin/Reviews.aspx") %>">Reviews</a>
                <a href="<%: ResolveUrl("~/Admin/Reports.aspx") %>">Reports</a>
                <a href="<%: ResolveUrl("~/Admin/LoginAudit.aspx") %>">Login Audit</a>
                <a href="<%: ResolveUrl("~/Admin/Messages.aspx") %>">Messages</a>
            </nav>

            <asp:Label ID="lblMsg" runat="server" Visible="false" CssClass="alert d-block" />

            <div class="mb-3" style="max-width: 480px;">
                <label class="form-label" for="<%= ddlCourse.ClientID %>">Course</label>
                <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-select" AutoPostBack="true"
                    DataValueField="CourseId" DataTextField="Title"
                    OnSelectedIndexChanged="ddlCourse_SelectedIndexChanged" />
            </div>

            <div class="pr-cat-card mb-4">
                <h2 class="h5 mb-3">
                    <asp:Literal ID="litFormTitle" runat="server" Text="Add a lesson" /></h2>
                <asp:HiddenField ID="hfId" runat="server" />
                <div class="row g-2">
                    <div class="col-md-8">
                        <label class="form-label small">Title</label>
                        <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" />
                    </div>
                    <div class="col-md-4">
                        <label class="form-label small">Sort order</label>
                        <asp:TextBox ID="txtSort" runat="server" CssClass="form-control" Text="1" />
                    </div>
                    <div class="col-12">
                        <label class="form-label small">Media URL (YouTube / .mp4 / image — optional)</label>
                        <asp:TextBox ID="txtMedia" runat="server" CssClass="form-control" />
                    </div>
                    <div class="col-12">
                        <label class="form-label small">Body HTML (trusted admin content)</label>
                        <asp:TextBox ID="txtBody" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="6" />
                    </div>
                </div>
                <asp:Button ID="btnSave" runat="server" Text="Save lesson" CssClass="pr-btn-accent mt-3" OnClick="btnSave_Click" />
                <asp:Button ID="btnReset" runat="server" Text="Clear" CssClass="btn btn-outline-secondary mt-3" OnClick="btnReset_Click" CausesValidation="false" />
            </div>

            <div class="table-responsive">
                <asp:GridView ID="gvLessons" runat="server" AutoGenerateColumns="false" DataKeyNames="LessonId"
                    CssClass="table table-striped align-middle" GridLines="None" OnRowCommand="gvLessons_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="LessonId" HeaderText="ID" />
                        <asp:BoundField DataField="SortOrder" HeaderText="Order" />
                        <asp:TemplateField HeaderText="Title">
                            <ItemTemplate><%# Server.HtmlEncode(Convert.ToString(Eval("Title"))) %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Media">
                            <ItemTemplate><%# Server.HtmlEncode(Convert.ToString(Eval("MediaUrl"))) %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="QuizCount" HeaderText="Quizzes" />
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn btn-sm btn-outline-secondary" CommandName="EditRow" CommandArgument='<%# Eval("LessonId") %>' Text="Edit" />
                                <asp:LinkButton ID="btnDel" runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="DeleteRow" CommandArgument='<%# Eval("LessonId") %>' Text="Delete"
                                    OnClientClick="return confirm('Delete this lesson and its quizzes/progress?');" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </section>
</asp:Content>
