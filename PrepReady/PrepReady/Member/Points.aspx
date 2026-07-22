<%@ Page Title="Points" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Points.aspx.cs" Inherits="PrepReady.Member.Points" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <p class="pr-eyebrow mb-1">Your activity</p>
            <h1 class="pr-section-title">Points &amp; Activity</h1>

            <div class="row g-3 my-2">
                <div class="col-6 col-md-3">
                    <div class="pr-cat-card text-center">
                        <div class="pr-stat-num"><asp:Literal ID="litBalance" runat="server" /></div>
                        <div class="pr-stat-label">Current balance</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="pr-cat-card text-center">
                        <div class="pr-stat-num" style="color:var(--red);">
                            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="vertical-align:-3px;"><path d="M12 2C9 6 7 8 7 12a5 5 0 0 0 10 0c0-2-1-3.5-2.5-5C13.5 8.5 13 7 12 2Z"/></svg>
                            <asp:Literal ID="litStreak" runat="server" />
                        </div>
                        <div class="pr-stat-label">Day login streak</div>
                    </div>
                </div>
            </div>

            <h2 class="h4 mt-4 mb-3">Transaction history</h2>
            <div class="table-responsive">
                <asp:GridView ID="gvHistory" runat="server" CssClass="table table-striped align-middle"
                              AutoGenerateColumns="false" GridLines="None"
                              EmptyDataText="No point activity yet — complete lessons and quizzes to earn points.">
                    <Columns>
                        <asp:TemplateField HeaderText="Date">
                            <ItemTemplate><%# Convert.ToDateTime(Eval("TxnDate")).ToString("dd MMM yyyy, HH:mm") %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Points">
                            <ItemTemplate>
                                <span class='<%# Convert.ToInt32(Eval("Points")) >= 0 ? "text-success fw-bold" : "text-danger fw-bold" %>'>
                                    <%# Convert.ToInt32(Eval("Points")) >= 0 ? "+" : "" %><%# Eval("Points") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="Reason" HeaderText="Reason" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </section>
</asp:Content>