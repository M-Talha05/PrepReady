<%@ Page Title="Forgot Password" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="PrepReady.Account.ForgotPassword" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
  <section class="pr-section">
    <div class="container">
      <!-- inline CSS demo: constrain the auth card width -->
      <div class="mx-auto" style="max-width: 480px;">
        <div class="card border-0 shadow-sm">
          <div class="card-body p-4 p-md-5">

            <div class="text-center mb-4">
              <div class="pr-auth-icon mx-auto mb-3" aria-hidden="true">
                <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
              </div>
              <h1 class="h3 mb-2" style="font-family: var(--font-head);">Forgot your password?</h1>
              <p class="text-muted mb-0">Enter your account email and we'll send you a link to reset it.</p>
            </div>

            <asp:Panel ID="pnlForm" runat="server">
              <div class="mb-3">
                <label class="form-label" for="<%= txtEmail.ClientID %>">Email address</label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="you@example.com" />
                <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
                    ValidationGroup="fp" Display="Dynamic" CssClass="text-danger small d-block mt-1"
                    ErrorMessage="Email is required." />
                <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail"
                    ValidationGroup="fp" Display="Dynamic" CssClass="text-danger small d-block mt-1"
                    ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                    ErrorMessage="Enter a valid email address." />
              </div>
              <div class="d-grid">
                <asp:Button ID="btnSubmit" runat="server" CssClass="btn pr-btn-accent" Text="Send reset link"
                    ValidationGroup="fp" OnClick="btnSubmit_Click" />
              </div>
            </asp:Panel>

            <asp:Panel ID="pnlDone" runat="server" Visible="false">
              <div class="alert alert-success" role="alert">
                If an account exists for that email, a password reset link has been sent.
                Please check your inbox (or the email log in this demo environment).
              </div>

              <asp:Panel ID="pnlDevLink" runat="server" Visible="false">
                <div class="alert alert-warning" role="alert">
                  <strong>DEV ONLY (localhost):</strong> email isn't actually delivered here, so use this link:
                  <div class="mt-2 text-break">
                    <asp:HyperLink ID="lnkDevReset" runat="server" />
                  </div>
                </div>
              </asp:Panel>
            </asp:Panel>

            <div class="text-center mt-4">
              <a href="<%= ResolveUrl("~/Account/Login.aspx") %>" class="small">Back to sign in</a>
            </div>

          </div>
        </div>
      </div>
    </div>
  </section>
</asp:Content>