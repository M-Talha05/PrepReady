<%@ Page Title="Manage Users" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Users.aspx.cs" Inherits="PrepReady.Admin.Users" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <p class="pr-eyebrow mb-1">Admin console</p>
            <h1 class="pr-section-title">Manage Users</h1>
            <nav class="pr-admin-nav" aria-label="Admin sections">
                <a href="<%: ResolveUrl("~/Admin/Default.aspx") %>">Dashboard</a>
                <a href="<%: ResolveUrl("~/Admin/Users.aspx") %>" class="active">Users</a>
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

            <asp:Label ID="lblMsg" runat="server" Visible="false" CssClass="alert d-block" />

            <div class="table-responsive">
                <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="false" DataKeyNames="UserId"
                    CssClass="table table-striped align-middle" GridLines="None"
                    OnRowEditing="gvUsers_RowEditing" OnRowCancelingEdit="gvUsers_RowCancelingEdit"
                    OnRowUpdating="gvUsers_RowUpdating" OnRowCommand="gvUsers_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="UserId" HeaderText="ID" ReadOnly="true" />
                        <asp:TemplateField HeaderText="Name">
                            <ItemTemplate><%# Server.HtmlEncode(Convert.ToString(Eval("FullName"))) %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtName" runat="server" CssClass="form-control form-control-sm" Text='<%# Eval("FullName") %>' />
                            </EditItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Email">
                            <ItemTemplate><%# Server.HtmlEncode(Convert.ToString(Eval("Email"))) %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Role">
                            <ItemTemplate><%# Eval("Role") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-select form-select-sm" SelectedValue='<%# Eval("Role") %>'>
                                    <asp:ListItem Text="Member" Value="Member" />
                                    <asp:ListItem Text="Admin" Value="Admin" />
                                </asp:DropDownList>
                            </EditItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Active">
                            <ItemTemplate><%# Convert.ToBoolean(Eval("IsActive")) ? "<span class='badge bg-success'>Active</span>" : "<span class='badge bg-secondary'>Inactive</span>" %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:CheckBox ID="chkActive" runat="server" Checked='<%# Convert.ToBoolean(Eval("IsActive")) %>' />
                            </EditItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Verified">
                            <ItemTemplate><%# Convert.ToBoolean(Eval("IsEmailVerified")) ? "Yes" : "No" %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="PointBalance" HeaderText="Points" ReadOnly="true" />
                        <asp:BoundField DataField="RegistrationDate" HeaderText="Registered" DataFormatString="{0:dd MMM yyyy}" ReadOnly="true" />
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn btn-sm btn-outline-secondary" CommandName="Edit" Text="Edit" />
                                <asp:LinkButton ID="btnDel" runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="DeleteUser" CommandArgument='<%# Eval("UserId") %>' Text="Delete"
                                    OnClientClick="return confirm('Delete this user and ALL of their data (certs, points, enrolments)? This cannot be undone.');" />
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:LinkButton ID="btnUpd" runat="server" CssClass="btn btn-sm pr-btn-accent" CommandName="Update" Text="Save" />
                                <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn btn-sm btn-outline-secondary" CommandName="Cancel" Text="Cancel" CausesValidation="false" />
                            </EditItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <div class="pr-cat-card mt-4">
                <h2 class="h5 mb-3">Adjust member points</h2>
                <div class="row g-2 align-items-end">
                    <div class="col-md-4">
                        <label class="form-label small">Member</label>
                        <asp:DropDownList ID="ddlUser" runat="server" CssClass="form-select" DataValueField="UserId" DataTextField="FullName" />
                    </div>
                    <div class="col-md-2">
                        <label class="form-label small">Amount (+/-)</label>
                        <asp:TextBox ID="txtDelta" runat="server" CssClass="form-control" placeholder="e.g. 50 or -25" />
                    </div>
                    <div class="col-md-4">
                        <label class="form-label small">Reason</label>
                        <asp:TextBox ID="txtReason" runat="server" CssClass="form-control" placeholder="e.g. Goodwill bonus" />
                    </div>
                    <div class="col-md-2">
                        <asp:Button ID="btnAdjust" runat="server" Text="Apply" CssClass="pr-btn-accent w-100" OnClick="btnAdjust_Click" />
                    </div>
                </div>
            </div>
        </div>
    </section>
</asp:Content>
