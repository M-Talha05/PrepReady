<%@ Page Title="National Registry" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="PrepReady.Registry.Index" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <p class="pr-eyebrow mb-1">Public registry</p>
            <h1 class="pr-section-title">National Recognised Responders Registry</h1>
            <p class="text-muted">Search the public registry of government-recognised emergency
                responders. Every entry can be independently verified.</p>

            <div class="card mb-4">
                <div class="card-body">
                    <div class="row g-2 align-items-end">
                        <div class="col-md-5">
                            <label class="form-label" for="<%= txtSearch.ClientID %>">Search by name</label>
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="e.g. Aisha" />
                        </div>
                        <div class="col-md-4">
                            <label class="form-label" for="<%= ddlField.ClientID %>">Recognised field</label>
                            <asp:DropDownList ID="ddlField" runat="server" CssClass="form-select" />
                        </div>
                        <div class="col-md-3">
                            <asp:Button ID="btnSearch" runat="server" Text="Search"
                                        CssClass="pr-btn-accent w-100" OnClick="btnSearch_Click" />
                        </div>
                    </div>
                </div>
            </div>

            <asp:Label ID="lblCount" runat="server" CssClass="text-muted small d-block mb-3" />

            <asp:Label ID="lblEmpty" runat="server" CssClass="alert alert-info d-block" Visible="false"
                       Text="No responders match your search." />

            <div class="row g-4">
                <asp:Repeater ID="rptRegistry" runat="server" OnItemDataBound="rptRegistry_ItemDataBound">
                    <ItemTemplate>
                        <div class="col-md-6">
                            <div class="pr-cat-card h-100">
                                <div class="d-flex justify-content-between align-items-start">
                                    <h3 class="h5 mb-1"><%# Server.HtmlEncode(Convert.ToString(Eval("FullName"))) %></h3>
                                    <asp:Literal ID="litStatus" runat="server" />
                                </div>
                                <span class="pr-tag pr-tag-red mb-2" style="align-self:flex-start;"><%# Server.HtmlEncode(Convert.ToString(Eval("RecognisedField"))) %></span>
                                <p class="small mb-1">Endorsed by: <%# Server.HtmlEncode(Convert.ToString(Eval("EndorsingAgency"))) %></p>
                                <p class="small text-muted mb-3">
                                    Recognised <%# Convert.ToDateTime(Eval("IssueDate")).ToString("dd MMM yyyy") %>
                                    · Valid until <%# Convert.ToDateTime(Eval("ExpiryDate")).ToString("dd MMM yyyy") %>
                                </p>
                                <a class="pr-btn-outline align-self-start"
                                   href='<%# ResolveUrl("~/Verify.aspx?code=" + Server.UrlEncode(Convert.ToString(Eval("CertCode")))) %>'>
                                   Verify credential</a>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <asp:Panel ID="pnlPager" runat="server" Visible="false" CssClass="d-flex justify-content-center align-items-center gap-3 mt-4">
                <asp:LinkButton ID="lnkPrev" runat="server" CssClass="btn pr-btn-outline btn-sm" Text="← Prev" OnClick="lnkPrev_Click" />
                <span class="text-muted small"><asp:Literal ID="litPager" runat="server" /></span>
                <asp:LinkButton ID="lnkNext" runat="server" CssClass="btn pr-btn-outline btn-sm" Text="Next →" OnClick="lnkNext_Click" />
            </asp:Panel>
        </div>
    </section>
</asp:Content>