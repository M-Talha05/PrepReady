<%@ Page Title="Verify sign-in" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="VerifyOtp.aspx.cs" Inherits="PrepReady.Account.VerifyOtp" %>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
  <section class="pr-section">
    <div class="container" style="max-width:460px;">
      <div class="card border-0 shadow-sm">
        <div class="card-body p-4 p-md-5">
          <p class="pr-eyebrow mb-1">Two-step verification</p>
          <h1 class="h3 mb-2" style="font-family:var(--font-head);">Enter your code</h1>
          <p class="text-muted">We sent a 6-digit code to <strong><asp:Literal ID="litEmail" runat="server" /></strong>. It expires in 5 minutes.</p>

          <asp:Panel ID="pnlDev" runat="server" Visible="false" CssClass="alert alert-info">
            <strong>Dev mode:</strong> your code is <code style="font-size:1.1em;"><asp:Literal ID="litDevCode" runat="server" /></code>
            <div class="small text-muted mt-1">(Shown only on localhost — also logged to App_Data/EmailLog.txt.)</div>
          </asp:Panel>

          <asp:Label ID="lblError" runat="server" Visible="false" CssClass="alert alert-danger d-block" />
          <asp:Label ID="lblInfo" runat="server" Visible="false" CssClass="alert alert-success d-block" />

          <div class="mb-3">
            <label class="form-label" for="<%= txtCode.ClientID %>">6-digit code</label>
            <asp:TextBox ID="txtCode" runat="server" CssClass="form-control form-control-lg text-center"
                         MaxLength="6" style="letter-spacing:.4em;" autocomplete="one-time-code" inputmode="numeric" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtCode" ValidationGroup="otp"
                Display="Dynamic" CssClass="text-danger small" ErrorMessage="Enter the code." Text="Enter the code." />
            <asp:RegularExpressionValidator runat="server" ControlToValidate="txtCode" ValidationGroup="otp"
                Display="Dynamic" CssClass="text-danger small" ValidationExpression="^\d{6}$"
                ErrorMessage="The code is 6 digits." Text="The code is 6 digits." />
          </div>

          <asp:Button ID="btnVerify" runat="server" CssClass="btn pr-btn-accent w-100" Text="Verify &amp; sign in"
                      ValidationGroup="otp" OnClick="btnVerify_Click" />

          <div class="d-flex justify-content-between mt-3 small">
            <asp:LinkButton ID="btnResend" runat="server" CausesValidation="false" Text="Resend code" OnClick="btnResend_Click" />
            <asp:LinkButton ID="btnCancel" runat="server" CausesValidation="false" Text="Cancel" OnClick="btnCancel_Click" />
          </div>
        </div>
      </div>
    </div>
  </section>
</asp:Content>