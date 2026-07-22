<%@ Page Title="Manage Partners" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Partners.aspx.cs" Inherits="PrepReady.Admin.Partners" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <p class="pr-eyebrow mb-1">Admin console</p>
            <h1 class="pr-section-title">Redemption Partners</h1>
            <nav class="pr-admin-nav" aria-label="Admin sections">
                <a href="<%: ResolveUrl("~/Admin/Default.aspx") %>">Dashboard</a>
                <a href="<%: ResolveUrl("~/Admin/Users.aspx") %>">Users</a>
                <a href="<%: ResolveUrl("~/Admin/Courses.aspx") %>">Courses</a>
                <a href="<%: ResolveUrl("~/Admin/Lessons.aspx") %>">Lessons</a>
                <a href="<%: ResolveUrl("~/Admin/Quizzes.aspx") %>">Quizzes</a>
                <a href="<%: ResolveUrl("~/Admin/Partners.aspx") %>" class="active">Partners</a>
                <a href="<%: ResolveUrl("~/Admin/Credentials.aspx") %>">Credentials</a>
                <a href="<%: ResolveUrl("~/Admin/Reviews.aspx") %>">Reviews</a>
                <a href="<%: ResolveUrl("~/Admin/Reports.aspx") %>">Reports</a>
                <a href="<%: ResolveUrl("~/Admin/LoginAudit.aspx") %>">Login Audit</a>
                <a href="<%: ResolveUrl("~/Admin/Messages.aspx") %>">Messages</a>
            </nav>

            <asp:Label ID="lblMsg" runat="server" Visible="false" CssClass="alert d-block" />

            <div class="pr-cat-card mb-4">
                <h2 class="h5 mb-3">Add a partner</h2>
                <div class="row g-2">
                    <div class="col-md-3">
                        <label class="form-label small">Name</label>
                        <asp:TextBox ID="txtName" runat="server" CssClass="form-control" />
                    </div>
                    <div class="col-md-2">
                        <label class="form-label small">Type</label>
                        <asp:TextBox ID="txtType" runat="server" CssClass="form-control" placeholder="Cafe, Gym…" />
                    </div>
                    <div class="col-md-4">
                        <label class="form-label small">Voucher title</label>
                        <asp:TextBox ID="txtVoucher" runat="server" CssClass="form-control" />
                    </div>
                    <div class="col-md-2">
                        <label class="form-label small">Point cost</label>
                        <asp:TextBox ID="txtCost" runat="server" CssClass="form-control" Text="100" />
                    </div>
                    <div class="col-md-1 d-flex align-items-end">
                        <div class="form-check">
                            <asp:CheckBox ID="chkActive" runat="server" Checked="true" /><label class="form-check-label small">Active</label>
                        </div>
                    </div>
                </div>
                <asp:Button ID="btnAdd" runat="server" Text="Add partner" CssClass="pr-btn-accent mt-3" OnClick="btnAdd_Click" />
            </div>

            <div class="table-responsive">
                <asp:GridView ID="gvPartners" runat="server" AutoGenerateColumns="false" DataKeyNames="PartnerId"
                    CssClass="table table-striped align-middle" GridLines="None"
                    OnRowEditing="gvPartners_RowEditing" OnRowCancelingEdit="gvPartners_RowCancelingEdit"
                    OnRowUpdating="gvPartners_RowUpdating" OnRowCommand="gvPartners_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="PartnerId" HeaderText="ID" ReadOnly="true" />
                        <asp:TemplateField HeaderText="Name">
                            <ItemTemplate><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEName" runat="server" CssClass="form-control form-control-sm" Text='<%# Eval("Name") %>' />
                            </EditItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Type">
                            <ItemTemplate><%# Server.HtmlEncode(Convert.ToString(Eval("PartnerType"))) %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEType" runat="server" CssClass="form-control form-control-sm" Text='<%# Eval("PartnerType") %>' />
                            </EditItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Voucher">
                            <ItemTemplate><%# Server.HtmlEncode(Convert.ToString(Eval("VoucherTitle"))) %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEVoucher" runat="server" CssClass="form-control form-control-sm" Text='<%# Eval("VoucherTitle") %>' />
                            </EditItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Cost">
                            <ItemTemplate><%# Eval("PointCost") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtECost" runat="server" CssClass="form-control form-control-sm" Text='<%# Eval("PointCost") %>' />
                            </EditItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Active">
                            <ItemTemplate><%# Convert.ToBoolean(Eval("IsActive")) ? "<span class='badge bg-success'>Yes</span>" : "<span class='badge bg-secondary'>No</span>" %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:CheckBox ID="chkEActive" runat="server" Checked='<%# Convert.ToBoolean(Eval("IsActive")) %>' />
                            </EditItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn btn-sm btn-outline-secondary" CommandName="Edit" Text="Edit" />
                                <asp:LinkButton ID="btnDel" runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="DeletePartner" CommandArgument='<%# Eval("PartnerId") %>' Text="Delete"
                                    OnClientClick="return confirm('Delete this partner? Any past redemptions for it will also be removed.');" />
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:LinkButton ID="btnUpd" runat="server" CssClass="btn btn-sm pr-btn-accent" CommandName="Update" Text="Save" />
                                <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn btn-sm btn-outline-secondary" CommandName="Cancel" Text="Cancel" CausesValidation="false" />
                            </EditItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </section>
</asp:Content>
