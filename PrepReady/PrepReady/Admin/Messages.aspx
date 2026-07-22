<%@ Page Title="Messages" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Messages.aspx.cs" Inherits="PrepReady.Admin.Messages" %>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
  <section class="pr-section">
    <div class="container">
      <p class="pr-eyebrow mb-1"><asp:Literal ID="litConsole" runat="server" Text="Admin console" /></p>
      <h1 class="pr-section-title">Support Messages</h1>

      <asp:Panel ID="pnlAdminNav" runat="server">
        <nav class="pr-admin-nav" aria-label="Admin sections">
          <a href="<%: ResolveUrl("~/Admin/Default.aspx") %>">Dashboard</a>
          <a href="<%: ResolveUrl("~/Admin/Users.aspx") %>">Users</a>
          <a href="<%: ResolveUrl("~/Admin/Courses.aspx") %>">Courses</a>
          <a href="<%: ResolveUrl("~/Admin/Lessons.aspx") %>">Lessons</a>
          <a href="<%: ResolveUrl("~/Admin/Quizzes.aspx") %>">Quizzes</a>
          <a href="<%: ResolveUrl("~/Admin/Partners.aspx") %>">Partners</a>
          <a href="<%: ResolveUrl("~/Admin/Credentials.aspx") %>">Credentials</a>
          <a href="<%: ResolveUrl("~/Admin/Reviews.aspx") %>">Reviews</a>
          <a href="<%: ResolveUrl("~/Admin/Reports.aspx") %>">Reports</a>
          <a href="<%: ResolveUrl("~/Admin/LoginAudit.aspx") %>">Login Audit</a>
          <a href="<%: ResolveUrl("~/Admin/Messages.aspx") %>" class="active">Messages</a>
        </nav>
      </asp:Panel>

      <asp:Panel ID="pnlOfficerBack" runat="server" Visible="false" CssClass="mb-3">
        <a href="<%: ResolveUrl("~/Officer/Portal.aspx") %>" class="small">&larr; Back to Officer Portal</a>
      </asp:Panel>

      <%-- ===== Inbox ===== --%>
      <asp:Panel ID="pnlInbox" runat="server">
        <asp:Repeater ID="rptMsgs" runat="server">
          <HeaderTemplate>
            <div class="table-responsive"><table class="table align-middle">
              <thead><tr><th>From</th><th>Subject</th><th>Activity</th><th>Status</th><th></th></tr></thead><tbody>
          </HeaderTemplate>
          <ItemTemplate>
            <tr>
              <td>
                <div class="fw-semibold"><%# Server.HtmlEncode(Eval("FullName").ToString()) %></div>
                <div class="small text-muted"><%# Server.HtmlEncode(Eval("Email").ToString()) %></div>
                <%# Eval("UserId") == DBNull.Value
                    ? "<span class='badge bg-secondary'>Guest</span>"
                    : "<span class='badge bg-info text-dark'>Registered</span>" %>
              </td>
              <td>
                <div><%# Server.HtmlEncode(Eval("Subject").ToString()) %></div>
                <div class="small text-muted"><%# Convert.ToInt32(Eval("ReplyCount")) %> repl<%# Convert.ToInt32(Eval("ReplyCount")) == 1 ? "y" : "ies" %></div>
              </td>
              <td class="text-nowrap small"><%# Convert.ToDateTime(Eval("LastActivity")).ToString("dd MMM yyyy") %></td>
              <td>
                <%# Convert.ToBoolean(Eval("IsResolved"))
                    ? "<span class='badge bg-success'>Resolved</span>"
                    : "<span class='badge bg-warning text-dark'>Open</span>" %>
              </td>
              <td class="text-nowrap">
                <a class="btn btn-sm pr-btn-outline" href='<%# ResolveUrl("~/Admin/Messages.aspx?id=" + Eval("MessageId")) %>'>Open</a>
              </td>
            </tr>
          </ItemTemplate>
          <FooterTemplate></tbody></table></div></FooterTemplate>
        </asp:Repeater>
        <asp:Label ID="lblEmpty" runat="server" CssClass="alert alert-info d-block" Visible="false" Text="No messages yet." />
      </asp:Panel>

      <%-- ===== One conversation ===== --%>
      <asp:Panel ID="pnlThread" runat="server" Visible="false" style="max-width:760px;">
        <a href="<%: ResolveUrl("~/Admin/Messages.aspx") %>" class="small">&larr; Back to inbox</a>

        <div class="card mt-2"><div class="card-body">
          <div class="d-flex justify-content-between align-items-start flex-wrap gap-2">
            <div>
              <h2 class="h4 mb-1"><asp:Literal ID="litSubject" runat="server" /></h2>
              <div class="small text-muted">
                From <strong><asp:Literal ID="litFromName" runat="server" /></strong>
                &lt;<asp:Literal ID="litFromEmail" runat="server" />&gt;
              </div>
              <div class="mt-1"><asp:Literal ID="litWho" runat="server" /> <asp:Literal ID="litStatus" runat="server" /></div>
            </div>
            <div class="text-nowrap">
              <asp:Button ID="btnResolve" runat="server" CssClass="btn btn-sm btn-outline-secondary"
                          CausesValidation="false" Text="Mark resolved" OnClick="btnResolve_Click" />
              <asp:Button ID="btnDelete" runat="server" CssClass="btn btn-sm btn-outline-danger"
                          CausesValidation="false" Text="Delete" OnClick="btnDelete_Click"
                          OnClientClick="return confirm('Delete this whole conversation?');" />
            </div>
          </div>

          <hr />
          <div class="pr-chat">
            <div class="pr-bubble pr-bubble-user">
              <div class="pr-bubble-meta"><asp:Literal ID="litMetaName" runat="server" /> · <asp:Literal ID="litOrigDate" runat="server" /></div>
              <div class="pr-bubble-body"><asp:Literal ID="litOrigBody" runat="server" /></div>
            </div>

            <asp:Repeater ID="rptThread" runat="server">
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

        <asp:Label ID="lblThreadMsg" runat="server" Visible="false" />

        <div class="card mt-3"><div class="card-body">
          <label class="form-label" for="<%= txtReply.ClientID %>">Reply</label>
          <asp:TextBox ID="txtReply" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" MaxLength="2000" />
          <asp:RequiredFieldValidator runat="server" ControlToValidate="txtReply" ValidationGroup="rep"
              Display="Dynamic" CssClass="text-danger small" ErrorMessage="Type a reply first." Text="Type a reply first." />
          <div class="small text-muted mt-1">
            Registered users are notified in-app; guests get an emailed reply (logged locally).
          </div>
          <div class="mt-2">
            <asp:Button ID="btnReply" runat="server" CssClass="btn pr-btn-accent" Text="Send reply"
                        ValidationGroup="rep" OnClick="btnReply_Click" />
          </div>
        </div></div>
      </asp:Panel>

    </div>
  </section>
</asp:Content>