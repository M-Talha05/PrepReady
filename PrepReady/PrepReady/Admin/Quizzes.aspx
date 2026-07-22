<%@ Page Title="Manage Quizzes" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Quizzes.aspx.cs" Inherits="PrepReady.Admin.Quizzes" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <p class="pr-eyebrow mb-1">Admin console</p>
            <h1 class="pr-section-title">Manage Quizzes</h1>
            <nav class="pr-admin-nav" aria-label="Admin sections">
                <a href="<%: ResolveUrl("~/Admin/Default.aspx") %>">Dashboard</a>
                <a href="<%: ResolveUrl("~/Admin/Users.aspx") %>">Users</a>
                <a href="<%: ResolveUrl("~/Admin/Courses.aspx") %>">Courses</a>
                <a href="<%: ResolveUrl("~/Admin/Lessons.aspx") %>">Lessons</a>
                <a href="<%: ResolveUrl("~/Admin/Quizzes.aspx") %>" class="active">Quizzes</a>
                <a href="<%: ResolveUrl("~/Admin/Partners.aspx") %>">Partners</a>
                <a href="<%: ResolveUrl("~/Admin/Credentials.aspx") %>">Credentials</a>
                <a href="<%: ResolveUrl("~/Admin/Reviews.aspx") %>">Reviews</a>
                <a href="<%: ResolveUrl("~/Admin/Reports.aspx") %>">Reports</a>
                <a href="<%: ResolveUrl("~/Admin/LoginAudit.aspx") %>">Login Audit</a>
                <a href="<%: ResolveUrl("~/Admin/Messages.aspx") %>">Messages</a>
            </nav>

            <asp:Label ID="lblMsg" runat="server" Visible="false" CssClass="alert d-block" />

            <div class="mb-3" style="max-width: 560px;">
                <label class="form-label" for="<%= ddlLesson.ClientID %>">Lesson</label>
                <asp:DropDownList ID="ddlLesson" runat="server" CssClass="form-select" AutoPostBack="true"
                    DataValueField="LessonId" DataTextField="Label"
                    OnSelectedIndexChanged="ddlLesson_SelectedIndexChanged" />
            </div>

            <div class="pr-cat-card mb-4">
                <h2 class="h5 mb-3">
                    <asp:Literal ID="litFormTitle" runat="server" Text="Add a question" /></h2>
                <asp:HiddenField ID="hfId" runat="server" />
                <div class="row g-2">
                    <div class="col-12">
                        <label class="form-label small">Question</label>
                        <asp:TextBox ID="txtQuestion" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label small">Option A</label>
                        <asp:TextBox ID="txtA" runat="server" CssClass="form-control" />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label small">Option B</label>
                        <asp:TextBox ID="txtB" runat="server" CssClass="form-control" />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label small">Option C (optional)</label>
                        <asp:TextBox ID="txtC" runat="server" CssClass="form-control" />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label small">Option D (optional)</label>
                        <asp:TextBox ID="txtD" runat="server" CssClass="form-control" />
                    </div>
                    <div class="col-md-4">
                        <label class="form-label small">Correct option</label>
                        <asp:DropDownList ID="ddlCorrect" runat="server" CssClass="form-select">
                            <asp:ListItem Text="A" Value="A" />
                            <asp:ListItem Text="B" Value="B" />
                            <asp:ListItem Text="C" Value="C" />
                            <asp:ListItem Text="D" Value="D" />
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-4 d-flex align-items-end">
                        <div class="form-check">
                            <asp:CheckBox ID="chkFinal" runat="server" /><label class="form-check-label small">Final-exam question</label>
                        </div>
                    </div>
                </div>
                <asp:Button ID="btnSave" runat="server" Text="Save question" CssClass="pr-btn-accent mt-3" OnClick="btnSave_Click" />
                <asp:Button ID="btnReset" runat="server" Text="Clear" CssClass="btn btn-outline-secondary mt-3" OnClick="btnReset_Click" CausesValidation="false" />
            </div>

            <div class="table-responsive">
                <asp:GridView ID="gvQuizzes" runat="server" AutoGenerateColumns="false" DataKeyNames="QuizId"
                    CssClass="table table-striped align-middle" GridLines="None" OnRowCommand="gvQuizzes_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="QuizId" HeaderText="ID" />
                        <asp:TemplateField HeaderText="Question">
                            <ItemTemplate><%# Server.HtmlEncode(Convert.ToString(Eval("Question"))) %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="CorrectOption" HeaderText="Correct" />
                        <asp:TemplateField HeaderText="Type">
                            <ItemTemplate><%# Convert.ToBoolean(Eval("IsFinalExam")) ? "<span class='badge bg-danger'>Final exam</span>" : "<span class='badge bg-secondary'>Quiz</span>" %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn btn-sm btn-outline-secondary" CommandName="EditRow" CommandArgument='<%# Eval("QuizId") %>' Text="Edit" />
                                <asp:LinkButton ID="btnDel" runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="DeleteRow" CommandArgument='<%# Eval("QuizId") %>' Text="Delete"
                                    OnClientClick="return confirm('Delete this question?');" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </section>
</asp:Content>
