<%@ Page Title="Notifications" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Notifications.aspx.cs" Inherits="PrepReady.Member.Notifications" %>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
  <section class="pr-section">
    <div class="container">
      <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
        <div>
          <p class="pr-eyebrow mb-1">Your activity</p>
          <h1 class="pr-section-title mb-0">Notifications</h1>
        </div>
        <asp:Panel ID="pnlMarkAll" runat="server" Visible="false">
          <asp:LinkButton ID="btnMarkAll" runat="server" CssClass="btn pr-btn-outline btn-sm"
              Text="Mark all as read" OnClick="btnMarkAll_Click" />
        </asp:Panel>
      </div>

      <div class="list-group shadow-sm">
        <asp:Repeater ID="rptNotes" runat="server">
          <ItemTemplate>
            <a href='<%# ResolveUrl("~/Member/Notifications.aspx?go=" + Eval("NotificationId")) %>'
               class='list-group-item list-group-item-action <%# Convert.ToBoolean(Eval("IsRead")) ? "" : "pr-note-unread" %>'>
              <div class="d-flex justify-content-between align-items-start">
                <span class="fw-semibold"><%# Server.HtmlEncode(Eval("Title").ToString()) %></span>
                <small class="text-muted text-nowrap ms-3"><%# Convert.ToDateTime(Eval("CreatedDate")).ToString("dd MMM yyyy, h:mm tt") %></small>
              </div>
              <div class="text-muted small"><%# Server.HtmlEncode(Eval("Message").ToString()) %></div>
            </a>
          </ItemTemplate>
        </asp:Repeater>
      </div>

      <asp:Label ID="lblEmpty" runat="server" CssClass="alert alert-info d-block mt-3" Visible="false"
                 Text="You have no notifications yet." />
    </div>
  </section>
</asp:Content>