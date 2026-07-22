<%@ Page Title="Officer Portal" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Portal.aspx.cs" Inherits="PrepReady.Officer.Portal" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <p class="pr-eyebrow mb-1">Officer console</p>
            <h1 class="pr-section-title">Officer Portal</h1>
            <p class="text-muted">Welcome,
                <asp:Literal ID="litName" runat="server" />.</p>

            <asp:Label ID="lblMsg" runat="server" CssClass="alert alert-info d-block" Visible="false" />

            <h2 class="h4 mt-4 mb-3">Pending applications</h2>
            <asp:Label ID="lblNoPending" runat="server" CssClass="alert alert-info d-block" Visible="false"
                Text="No pending applications." />
            <asp:Repeater ID="rptPending" runat="server" OnItemCommand="rptPending_ItemCommand">
                <ItemTemplate>
                    <div class="card mb-2">
                        <div class="card-body d-flex flex-wrap justify-content-between align-items-center gap-2">
                            <div>
                                <strong><%# Server.HtmlEncode(Convert.ToString(Eval("FullName"))) %></strong>
                                — <%# Eval("RecognisedField") %><br />
                                <small class="text-muted">Code: <%# Eval("DeploymentCode") %> · <%# Eval("EndorsingAgency") %>
                                    · applied <%# Convert.ToDateTime(Eval("AppliedDate")).ToString("dd MMM yyyy") %></small>
                            </div>
                            <div class="d-flex gap-2">
                                <asp:LinkButton ID="btnAccept" runat="server" CssClass="btn btn-success btn-sm"
                                    CommandName="Accept" CommandArgument='<%# Eval("DeploymentId") %>' Text="Accept" />
                                <asp:LinkButton ID="btnDecline" runat="server" CssClass="btn btn-outline-danger btn-sm"
                                    CommandName="Decline" CommandArgument='<%# Eval("DeploymentId") %>' Text="Decline" />
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <h2 class="h4 mt-5 mb-3">Active deployments</h2>
            <asp:Label ID="lblNoActive" runat="server" CssClass="alert alert-info d-block" Visible="false"
                Text="No active deployments assigned to you." />
            <asp:Repeater ID="rptActive" runat="server" OnItemDataBound="rptActive_ItemDataBound" OnItemCommand="rptActive_ItemCommand">
                <ItemTemplate>
                    <div class="card mb-3">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-start">
                                <div>
                                    <h3 class="h5 mb-1"><%# Server.HtmlEncode(Convert.ToString(Eval("FullName"))) %></h3>
                                    <small class="text-muted"><%# Eval("RecognisedField") %> · Code: <%# Eval("DeploymentCode") %></small>
                                </div>
                                <span class="badge bg-primary"><%# Eval("AccruedHours") %> / <%# RequiredHrs %> hrs</span>
                            </div>

                            <div class="row g-2 align-items-end mt-2">
                                <div class="col-sm-3">
                                    <label class="form-label small mb-0">Service date</label>
                                    <asp:TextBox ID="txtDate" runat="server" CssClass="form-control form-control-sm" TextMode="Date" />
                                </div>
                                <div class="col-sm-2">
                                    <label class="form-label small mb-0">Hours</label>
                                    <asp:TextBox ID="txtHours" runat="server" CssClass="form-control form-control-sm" TextMode="Number" />
                                </div>
                                <div class="col-sm-5">
                                    <label class="form-label small mb-0">Activity</label>
                                    <asp:TextBox ID="txtNote" runat="server" CssClass="form-control form-control-sm" />
                                </div>
                                <div class="col-sm-2">
                                    <asp:LinkButton ID="btnLog" runat="server" CssClass="btn btn-outline-primary btn-sm w-100"
                                        CommandName="Log" CommandArgument='<%# Eval("DeploymentId") %>' Text="Log &amp; sign off" />
                                </div>
                            </div>

                            <asp:Repeater ID="rptSessions" runat="server">
                                <HeaderTemplate>
                                    <div class="table-responsive">
                                        <table class="table table-sm align-middle mt-3">
                                            <thead>
                                                <tr>
                                                    <th>Date</th>
                                                    <th>Hours</th>
                                                    <th>Activity</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <tr>
                                        <td><%# Convert.ToDateTime(Eval("ServiceDate")).ToString("dd MMM yyyy") %></td>
                                        <td><%# Eval("DurationHours") %></td>
                                        <td><%# Server.HtmlEncode(Convert.ToString(Eval("ActivityNote"))) %></td>
                                    </tr>
                                </ItemTemplate>
                                <FooterTemplate></tbody></table></div></FooterTemplate>
                            </asp:Repeater>

                            <asp:LinkButton ID="btnIssue" runat="server" CssClass="pr-btn-accent mt-2" Visible="false"
                                CommandName="Issue" CommandArgument='<%# Eval("DeploymentId") %>'
                                Text="Issue badge (final verification)" />
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <div class="mb-4">
                <a href="<%: ResolveUrl("~/Admin/Messages.aspx") %>" class="btn pr-btn-outline">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none"
                        stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"
                        class="me-1">
                        <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>
                    Support Messages
                </a>
            </div>

        </div>
    </section>
</asp:Content>
