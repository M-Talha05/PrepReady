<%@ Page Title="Contact Us" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Contact.aspx.cs" Inherits="PrepReady.Contact" %>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
  <section class="pr-section">
    <div class="container">
      <div class="mx-auto" style="max-width:640px;">
        <p class="pr-eyebrow mb-1">Get in touch</p>
        <h1 class="pr-section-title">Contact us</h1>
        <p class="text-muted">Questions about courses, certification, or the registry? Send us a message.</p>

        <asp:Panel ID="pnlLoggedInfo" runat="server" Visible="false" CssClass="alert alert-info">
          You're signed in — your reply will appear in
          <a href="<%= ResolveUrl("~/Member/MyMessages.aspx") %>">My Messages</a>, and we'll notify you when staff respond.
        </asp:Panel>

        <asp:Panel ID="pnlForm" runat="server" CssClass="card mt-3">
          <div class="card-body p-4 p-md-5">
            <asp:Label ID="lblMsg" runat="server" Visible="false" />
            <asp:ValidationSummary ID="vs" runat="server" CssClass="alert alert-warning" ValidationGroup="ct"
                                   DisplayMode="BulletList" HeaderText="Please fix the following:" />

            <div class="mb-3">
              <label class="form-label" for="<%= txtName.ClientID %>">Your name</label>
              <asp:TextBox ID="txtName" runat="server" CssClass="form-control" MaxLength="150" />
              <asp:RequiredFieldValidator runat="server" ControlToValidate="txtName" ValidationGroup="ct"
                  Display="Dynamic" CssClass="text-danger small" ErrorMessage="Name is required." Text="Name is required." />
            </div>
            <div class="mb-3">
              <label class="form-label" for="<%= txtEmail.ClientID %>">Email</label>
              <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" MaxLength="256" />
              <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEmail" ValidationGroup="ct"
                  Display="Dynamic" CssClass="text-danger small" ErrorMessage="Email is required." Text="Email is required." />
              <asp:RegularExpressionValidator runat="server" ControlToValidate="txtEmail" ValidationGroup="ct"
                  Display="Dynamic" CssClass="text-danger small" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                  ErrorMessage="Enter a valid email." Text="Enter a valid email." />
            </div>
            <div class="mb-3">
              <label class="form-label" for="<%= txtSubject.ClientID %>">Subject</label>
              <asp:TextBox ID="txtSubject" runat="server" CssClass="form-control" MaxLength="200" />
              <asp:RequiredFieldValidator runat="server" ControlToValidate="txtSubject" ValidationGroup="ct"
                  Display="Dynamic" CssClass="text-danger small" ErrorMessage="Subject is required." Text="Subject is required." />
            </div>
            <div class="mb-3">
              <label class="form-label" for="<%= txtBody.ClientID %>">Message</label>
              <asp:TextBox ID="txtBody" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="5" MaxLength="2000" />
              <asp:RequiredFieldValidator runat="server" ControlToValidate="txtBody" ValidationGroup="ct"
                  Display="Dynamic" CssClass="text-danger small" ErrorMessage="Message is required." Text="Message is required." />
            </div>

            <asp:Panel ID="pnlCaptcha" runat="server" CssClass="mb-4" style="max-width:280px;">
              <label class="form-label" for="<%= txtCaptcha.ClientID %>">Verification: <asp:Literal ID="litCaptcha" runat="server" /></label>
              <asp:TextBox ID="txtCaptcha" runat="server" CssClass="form-control" />
              <asp:RequiredFieldValidator runat="server" ControlToValidate="txtCaptcha" ValidationGroup="ct"
                  Display="Dynamic" CssClass="text-danger small" ErrorMessage="Answer the verification question." Text="Answer the verification question." />
            </asp:Panel>

            <asp:Button ID="btnSend" runat="server" CssClass="btn pr-btn-accent" Text="Send message"
                        ValidationGroup="ct" OnClick="btnSend_Click" />
          </div>
        </asp:Panel>

        <asp:Panel ID="pnlDone" runat="server" Visible="false" CssClass="mt-3">
          <div class="alert alert-success">
            <strong>Thank you!</strong> Your message has been sent — we'll reply by email soon.
          </div>
          <a href="<%= ResolveUrl("~/Default.aspx") %>" class="btn pr-btn-outline">Back to home</a>
        </asp:Panel>
      </div>
    </div>
  </section>
</asp:Content>