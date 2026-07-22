<%@ Page Title="Badges" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Badges.aspx.cs" Inherits="PrepReady.Member.Badges" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <p class="pr-eyebrow mb-1">Your achievements</p>
            <h1 class="pr-section-title">Badge Collection</h1>

            <h2 class="h4 mt-3 mb-3">Achievements</h2>
            <div class="row g-3">
                <asp:Repeater ID="rptAchievements" runat="server">
                    <ItemTemplate>
                        <div class="col-6 col-md-4 col-lg-3">
                            <div class='pr-cat-card text-center <%# (bool)Eval("Unlocked") ? "" : "opacity-50" %>'>
                                <span class="pr-ach-icon"><%# Eval("Icon") %></span>
                                <h3 class="h6 mt-1 mb-1"><%# Eval("Title") %></h3>
                                <p class="small text-muted mb-2"><%# Eval("Description") %></p>
                                <%# (bool)Eval("Unlocked")
                                    ? "<span class='badge bg-success'>Unlocked</span>"
                                    : "<span class='badge bg-secondary'>Locked</span>" %>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <h2 class="h4 mt-5 mb-3">Government-Recognised Badges (Tier 3)</h2>
            <asp:Label ID="lblNoBadges" runat="server" CssClass="alert alert-info d-block" Visible="false"
                       Text="No Tier 3 badges yet. Earn one through verified community service via the Tier 3 deployment workflow." />
            <div class="row g-3">
                <asp:Repeater ID="rptBadges" runat="server">
                    <ItemTemplate>
                        <div class="col-md-6 col-lg-4">
                            <div class="pr-cat-card">
                                <svg class="pr-tier3-icon mb-2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 3 20 6v5c0 5-3.5 8-8 10-4.5-2-8-5-8-10V6l8-3Z"/><path d="M9 12l2 2 4-4"/></svg>
                                <h3 class="h6"><%# Eval("CourseTitle") %></h3>
                                <p class="small mb-1">Endorsed by <%# Eval("EndorsingAgency") %></p>
                                <p class="small text-muted mb-0">
                                    Issued <%# Convert.ToDateTime(Eval("IssueDate")).ToString("dd MMM yyyy") %>
                                </p>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>
</asp:Content>