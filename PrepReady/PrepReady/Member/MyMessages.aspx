<%@ Page Title="My Messages" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MyMessages.aspx.cs" Inherits="PrepReady.Member.MyMessages" %>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
  <section class="pr-section">
    <div class="container" style="max-width:760px;">

      <%-- ===== List of my threads ===== --%>
      <asp:Panel ID="pnlList" runat="server">
        <p class="pr-eyebrow mb-1">Support</p>
        <h1 class="pr-section-title">My Messages</h1>
        <p class="text-muted">Your conversations with the PrepReady team.
           <a href="<%= ResolveUrl("~/Contact.aspx") %>">Start a new one</a>.</p>

        <asp:Repeater ID="rptThreads" runat="server">
          <HeaderTemplate><div class="list-group shadow-sm mt-3"></HeaderTemplate>
          <ItemTemplate>
            <a href='<%# ResolveUrl("~/Member/MyMessages.aspx?id=" + Eval("MessageId")) %>'
               class="list-group-item list-group-item-action">
              <div class="d-flex justify-content-between align-items-start">
                <span class="fw-semibold"><%# Server.HtmlEncode(Eval("Subject").ToString()) %></span>
                <%# Convert.ToBoolean(Eval("IsResolved"))
                    ? "<span class='badge bg-success'>Resolved</span>"
                    : "<span class='badge bg-warning text-dark'>Open</span>" %>
              </div>
              <div class="small text-muted">
                <%# Convert.ToInt32(Eval("ReplyCount")) %> repl<%# Convert.ToInt32(Eval("ReplyCount")) == 1 ? "y" : "ies" %>
                · last activity <%# Convert.ToDateTime(Eval("LastActivity")).ToString("dd MMM yyyy, h:mm tt") %>
              </div>
            </a>
          </ItemTemplate>
          <FooterTemplate></div></FooterTemplate>
        </asp:Repeater>

        <asp:Label ID="lblEmpty" runat="server" CssClass="alert alert-info d-block mt-3" Visible="false"
                   Text="You haven't sent any messages yet." />
      </asp:Panel>

      <%-- ===== One conversation ===== --%>
      <asp:Panel ID="pnlThread" runat="server" Visible="false">
        <a href="<%= ResolveUrl("~/Member/MyMessages.aspx") %>" class="small">&larr; Back to my messages</a>
        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mt-2">
          <h1 class="pr-section-title mb-0"><asp:Literal ID="litSubject" runat="server" /></h1>
          <asp:Literal ID="litStatus" runat="server" />
        </div>

        <div class="card mt-3"><div class="card-body">
          <div class="pr-chat">
            <%-- original message (from you) --%>
            <div class="pr-bubble pr-bubble-user">
              <div class="pr-bubble-meta">You · <asp:Literal ID="litOrigDate" runat="server" /></div>
              <div class="pr-bubble-body"><asp:Literal ID="litOrigBody" runat="server" /></div>
            </div>

            <asp:Repeater ID="rptReplies" runat="server">
              <ItemTemplate>
                <div class='pr-bubble <%# Eval("SenderRole").ToString() == "User" ? "pr-bubble-user" : "pr-bubble-staff" %>'>
                  <div class="pr-bubble-meta">
                    <%# Server.HtmlEncode(Eval("SenderName").ToString()) %>
                    <%# Eval("SenderRole").ToString() == "User" ? "" : " (" + Server.HtmlEncode(Eval("SenderRole").ToString()) + ")" %>
                    · <%# Convert.ToDateTime(Eval("CreatedDate")).ToString("dd MMM yyyy, h:mm tt") %>
                  </div>
                  <div class="pr-bubble-body"><%# Server.HtmlEncode(Eval("Body").ToString()) %></div>
                </div>
              </ItemTemplate>
            </asp:Repeater>
          </div>
        </div></div>

        <asp:Label ID="lblResolved" runat="server" Visible="false" CssClass="alert alert-success d-block mt-3"
                   Text="This conversation is marked resolved. Sending another reply will reopen it." />

        <div class="card mt-3"><div class="card-body">
          <label class="form-label" for="<%= txtReply.ClientID %>">Your reply</label>
          <asp:TextBox ID="txtReply" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" MaxLength="2000" />
          <asp:RequiredFieldValidator runat="server" ControlToValidate="txtReply" ValidationGroup="rep"
              Display="Dynamic" CssClass="text-danger small" ErrorMessage="Type a reply first." Text="Type a reply first." />
          <div class="mt-2">
            <asp:Button ID="btnReply" runat="server" CssClass="btn pr-btn-accent" Text="Send reply"
                        ValidationGroup="rep" OnClick="btnReply_Click" />
          </div>
        </div></div>
      </asp:Panel>

    </div>
  </section>
</asp:Content>