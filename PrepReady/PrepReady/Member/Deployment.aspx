<%@ Page Title="Tier 3 Deployment" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Deployment.aspx.cs" Inherits="PrepReady.Member.Deployment" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <p class="pr-eyebrow mb-1">Serve your community</p>
            <h1 class="pr-section-title">Tier 3 Community Deployment</h1>
            <p class="text-muted">Apply for verified community service to earn a Government-Recognised Badge.</p>

            <asp:Label ID="lblMsg" runat="server" CssClass="alert alert-success d-block" Visible="false" />

            <h2 class="h4 mt-4 mb-3">Apply</h2>
            <asp:Label ID="lblNoEligible" runat="server" CssClass="alert alert-info d-block" Visible="false"
                       Text="You need a valid Tier 2 (Certificate of Completion) with no active deployment to apply." />
            <div class="row g-3">
                <asp:Repeater ID="rptEligible" runat="server" OnItemCommand="rptEligible_ItemCommand">
                    <ItemTemplate>
                        <div class="col-md-6">
                            <div class="pr-cat-card d-flex flex-row justify-content-between align-items-center">
                                <div>
                                    <h3 class="h6 mb-1"><%# Eval("CourseTitle") %></h3>
                                    <small class="text-muted"><%# Eval("GovPartner") %></small>
                                </div>
                                <asp:LinkButton ID="btnApply" runat="server" CssClass="pr-btn-accent"
                                                CommandName="Apply" CommandArgument='<%# Eval("CourseId") %>'
                                                Text="Apply" />
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <h2 class="h4 mt-5 mb-3">My Deployments</h2>
            <asp:Label ID="lblNoDeployments" runat="server" CssClass="alert alert-info d-block" Visible="false"
                       Text="No deployments yet." />
            <asp:Repeater ID="rptMine" runat="server" OnItemDataBound="rptMine_ItemDataBound">
                <ItemTemplate>
                    <div class="card mb-3">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-start">
                                <div>
                                    <h3 class="h5 mb-1"><%# Eval("RecognisedField") %></h3>
                                    <small class="text-muted">Code: <%# Eval("DeploymentCode") %> · <%# Eval("EndorsingAgency") %></small>
                                </div>
                                <%# StatusBadge(Eval("Status")) %>
                            </div>

                            <div class="progress my-2" role="progressbar" style="height:12px;">
                                <div class="progress-bar" style='background:var(--navy); width:<%# DepPercent(Eval("AccruedHours")) %>%;'></div>
                            </div>
                            <p class="small text-muted">
                                <%# Eval("AccruedHours") %> / <%# RequiredHrs %> verified hours
                            </p>

                            <h4 class="h6 mt-3">Verified logbook</h4>
                            <asp:Repeater ID="rptSessions" runat="server">
                                <HeaderTemplate>
                                    <div class="table-responsive">
                                    <table class="table table-sm align-middle">
                                        <thead><tr><th>Date</th><th>Hours</th><th>Activity</th><th>Signed off</th></tr></thead>
                                        <tbody>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <tr>
                                        <td><%# Convert.ToDateTime(Eval("ServiceDate")).ToString("dd MMM yyyy") %></td>
                                        <td><%# Eval("DurationHours") %></td>
                                        <td><%# Server.HtmlEncode(Convert.ToString(Eval("ActivityNote"))) %></td>
                                        <td><span class="badge bg-success d-inline-flex align-items-center gap-1"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12l5 5 9-11"/></svg> Verified</span></td>
                                    </tr>
                                </ItemTemplate>
                                <FooterTemplate></tbody></table></div></FooterTemplate>
                            </asp:Repeater>
                            <asp:Literal ID="litNoSessions" runat="server" />
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </section>
</asp:Content>