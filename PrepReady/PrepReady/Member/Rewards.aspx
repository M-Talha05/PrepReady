<%@ Page Title="Rewards" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Rewards.aspx.cs" Inherits="PrepReady.Member.Rewards" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <p class="pr-eyebrow mb-1">Spend your points</p>
            <h1 class="pr-section-title">Rewards &amp; Redemptions</h1>
            <p class="text-muted">Current balance:
                <strong style="color:var(--red);"><asp:Literal ID="litBalance" runat="server" /></strong> points.</p>

            <asp:Label ID="lblMsg" runat="server" Visible="false" CssClass="alert d-block" />

            <h2 class="h4 mt-4 mb-3">Partner catalogue</h2>
            <div class="row g-4">
                <asp:Repeater ID="rptPartners" runat="server" OnItemCommand="rptPartners_ItemCommand">
                    <ItemTemplate>
                        <div class="col-md-4">
                            <div class="pr-cat-card h-100">
                                <span class="pr-tag mb-2" style="align-self:flex-start;"><%# Server.HtmlEncode(Convert.ToString(Eval("PartnerType"))) %></span>
                                <h3 class="h5"><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></h3>
                                <p class="mb-2"><%# Server.HtmlEncode(Convert.ToString(Eval("VoucherTitle"))) %></p>
                                <p class="fw-bold mb-3" style="color:var(--navy);"><%# Eval("PointCost") %> points</p>
                                <asp:LinkButton ID="btnRedeem" runat="server" CssClass="pr-btn-accent text-center"
                                    CommandName="Redeem" CommandArgument='<%# Eval("PartnerId") %>'
                                    Text="Redeem"
                                    data-partner='<%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %>'
                                    data-voucher='<%# Server.HtmlEncode(Convert.ToString(Eval("VoucherTitle"))) %>'
                                    data-cost='<%# Eval("PointCost") %>'
                                    OnClientClick="return prConfirmRedeem(this);" />
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <h2 class="h4 mt-5 mb-3">My vouchers</h2>
            <asp:Label ID="lblNoVouchers" runat="server" CssClass="alert alert-info d-block" Visible="false"
                       Text="You haven't redeemed any vouchers yet." />
            <div class="table-responsive">
                <asp:GridView ID="gvHistory" runat="server" AutoGenerateColumns="false"
                              CssClass="table table-striped align-middle" GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="Name"         HeaderText="Partner" />
                        <asp:BoundField DataField="VoucherTitle" HeaderText="Voucher" />
                        <asp:BoundField DataField="VoucherCode"  HeaderText="Code" />
                        <asp:BoundField DataField="PointsSpent"  HeaderText="Points" />
                        <asp:BoundField DataField="RedeemedDate" HeaderText="Redeemed" DataFormatString="{0:dd MMM yyyy}" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </section>

    <%-- ============ In-app themed confirm modal ============ --%>
    <div class="modal fade" id="prRedeemModal" tabindex="-1" aria-labelledby="prRedeemModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content" style="border-top:4px solid var(--red); overflow:hidden;">
                <div class="modal-header" style="background:var(--navy); color:#ffffff;">
                    <h5 class="modal-title" id="prRedeemModalLabel">Confirm redemption</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p class="mb-1">You're about to redeem:</p>
                    <p class="fw-bold fs-5 mb-1" id="prModalVoucher"></p>
                    <p class="text-muted small mb-3">from <span id="prModalPartner"></span></p>
                    <p class="mb-0">This will cost
                        <strong style="color:var(--red);"><span id="prModalCost"></span> points</strong>
                        from your balance.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="pr-btn-accent" onclick="prDoRedeem();">Confirm redemption</button>
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        var prPendingPostback = null;

        function prConfirmRedeem(link) {
            prPendingPostback = link.href; // "javascript:__doPostBack('...','')"
            document.getElementById('prModalPartner').textContent = link.getAttribute('data-partner');
            document.getElementById('prModalVoucher').textContent = link.getAttribute('data-voucher');
            document.getElementById('prModalCost').textContent = link.getAttribute('data-cost');
            var modalEl = document.getElementById('prRedeemModal');
            bootstrap.Modal.getOrCreateInstance(modalEl).show();
            return false; // wait for confirmation
        }

        function prDoRedeem() {
            var modalEl = document.getElementById('prRedeemModal');
            bootstrap.Modal.getOrCreateInstance(modalEl).hide();
            if (prPendingPostback) {
                var call = prPendingPostback.replace(/^javascript:/i, '');
                eval(call);
            }
        }
    </script>
</asp:Content>