<%@ Page Title="Credentials" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Credentials.aspx.cs" Inherits="PrepReady.Admin.Credentials" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <p class="pr-eyebrow mb-1">Admin console</p>
            <h1 class="pr-section-title">Credentials</h1>
            <nav class="pr-admin-nav" aria-label="Admin sections">
                <a href="<%: ResolveUrl("~/Admin/Default.aspx") %>">Dashboard</a>
                <a href="<%: ResolveUrl("~/Admin/Users.aspx") %>">Users</a>
                <a href="<%: ResolveUrl("~/Admin/Courses.aspx") %>">Courses</a>
                <a href="<%: ResolveUrl("~/Admin/Lessons.aspx") %>">Lessons</a>
                <a href="<%: ResolveUrl("~/Admin/Quizzes.aspx") %>">Quizzes</a>
                <a href="<%: ResolveUrl("~/Admin/Partners.aspx") %>">Partners</a>
                <a href="<%: ResolveUrl("~/Admin/Credentials.aspx") %>" class="active">Credentials</a>
                <a href="<%: ResolveUrl("~/Admin/Reviews.aspx") %>">Reviews</a>
                <a href="<%: ResolveUrl("~/Admin/Reports.aspx") %>">Reports</a>
                <a href="<%: ResolveUrl("~/Admin/LoginAudit.aspx") %>">Login Audit</a>
                <a href="<%: ResolveUrl("~/Admin/Messages.aspx") %>">Messages</a>
            </nav>

            <asp:Label ID="lblMsg" runat="server" Visible="false" CssClass="alert d-block" />

            <h2 class="h4 mt-4 mb-3">Certificates</h2>
            <div class="table-responsive">
                <asp:GridView ID="gvCerts" runat="server" AutoGenerateColumns="false" DataKeyNames="CertificateId"
                    CssClass="table table-striped align-middle" GridLines="None" OnRowCommand="gvCerts_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="CertificateId" HeaderText="ID" />
                        <asp:TemplateField HeaderText="Holder">
                            <ItemTemplate><%# Server.HtmlEncode(Convert.ToString(Eval("FullName"))) %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Course">
                            <ItemTemplate><%# Server.HtmlEncode(Convert.ToString(Eval("Course"))) %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="Tier" HeaderText="Tier" />
                        <asp:BoundField DataField="CertCode" HeaderText="Code" />
                        <asp:BoundField DataField="IssueDate" HeaderText="Issued" DataFormatString="{0:dd MMM yyyy}" />
                        <asp:BoundField DataField="ExpiryDate" HeaderText="Expires" DataFormatString="{0:dd MMM yyyy}" />
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnRevoke" runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="Revoke" CommandArgument='<%# Eval("CertificateId") %>' Text="Revoke"
                                    OnClientClick="return confirm('Revoke this certificate? Any badge and registry entry from it will also be removed.');" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <h2 class="h4 mt-5 mb-3">Tier 3 badges</h2>
            <div class="table-responsive">
                <asp:GridView ID="gvBadges" runat="server" AutoGenerateColumns="false"
                    CssClass="table table-striped align-middle" GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="BadgeId" HeaderText="ID" />
                        <asp:TemplateField HeaderText="Holder">
                            <ItemTemplate><%# Server.HtmlEncode(Convert.ToString(Eval("FullName"))) %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Endorsing agency">
                            <ItemTemplate><%# Server.HtmlEncode(Convert.ToString(Eval("EndorsingAgency"))) %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="IssueDate" HeaderText="Issued" DataFormatString="{0:dd MMM yyyy}" />
                        <asp:BoundField DataField="ExpiryDate" HeaderText="Expires" DataFormatString="{0:dd MMM yyyy}" />
                    </Columns>
                </asp:GridView>
            </div>

            <h2 class="h4 mt-5 mb-3">Public registry</h2>
            <div class="table-responsive">
                <asp:GridView ID="gvRegistry" runat="server" AutoGenerateColumns="false" DataKeyNames="RegistryId"
                    CssClass="table table-striped align-middle" GridLines="None" OnRowCommand="gvRegistry_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="RegistryId" HeaderText="ID" />
                        <asp:TemplateField HeaderText="Holder">
                            <ItemTemplate><%# Server.HtmlEncode(Convert.ToString(Eval("FullName"))) %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Field">
                            <ItemTemplate><%# Server.HtmlEncode(Convert.ToString(Eval("RecognisedField"))) %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Agency">
                            <ItemTemplate><%# Server.HtmlEncode(Convert.ToString(Eval("EndorsingAgency"))) %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="IssueDate" HeaderText="Issued" DataFormatString="{0:dd MMM yyyy}" />
                        <asp:BoundField DataField="ExpiryDate" HeaderText="Expires" DataFormatString="{0:dd MMM yyyy}" />
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnRemove" runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="RemoveReg" CommandArgument='<%# Eval("RegistryId") %>' Text="Remove"
                                    OnClientClick="return confirm('Remove this entry from the public registry? (Badge and certificate are kept.)');" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </section>
</asp:Content>
