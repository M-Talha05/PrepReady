<%@ Page Title="Leaderboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Leaderboard.aspx.cs" Inherits="PrepReady.Leaderboard" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <p class="pr-eyebrow mb-1">Top responders</p>
                    <h1 class="pr-section-title">Leaderboard</h1>
                    <p class="text-muted">Members ranked by points earned across courses, service, and streaks.</p>

                    <div class="table-responsive">
                        <table class="table table-striped align-middle">
                            <thead>
                                <tr><th style="width:70px;">Rank</th><th>Member</th><th class="text-end">Points</th></tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptBoard" runat="server">
                                    <ItemTemplate>
                                        <tr>
                                            <td>
                                                <span class='pr-rank <%# (RankOffset+Container.ItemIndex)==0 ? "pr-rank-1" : (RankOffset+Container.ItemIndex)==1 ? "pr-rank-2" : (RankOffset+Container.ItemIndex)==2 ? "pr-rank-3" : "" %>'>
                                                    <%# RankOffset + Container.ItemIndex + 1 %>
                                                </span>
                                            </td>
                                            <td><%# Server.HtmlEncode(Convert.ToString(Eval("FullName"))) %></td>
                                            <td class="text-end fw-bold"><%# Eval("PointBalance") %></td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>

                    <asp:Label ID="lblEmpty" runat="server" CssClass="alert alert-info d-block" Visible="false"
                               Text="No ranked members yet." />

                    <asp:Panel ID="pnlPager" runat="server" Visible="false" CssClass="d-flex justify-content-center align-items-center gap-3 mt-3">
                        <asp:LinkButton ID="lnkPrev" runat="server" CssClass="btn pr-btn-outline btn-sm" Text="← Prev" OnClick="lnkPrev_Click" />
                        <span class="text-muted small"><asp:Literal ID="litPager" runat="server" /></span>
                        <asp:LinkButton ID="lnkNext" runat="server" CssClass="btn pr-btn-outline btn-sm" Text="Next →" OnClick="lnkNext_Click" />
                    </asp:Panel>
                </div>
            </div>
        </div>
    </section>
</asp:Content>