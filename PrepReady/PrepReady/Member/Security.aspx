<%@ Page Title="Security" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Security.aspx.cs" Inherits="PrepReady.Member.Security" %>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
  <section class="pr-section">
    <div class="container" style="max-width:640px;">
      <p class="pr-eyebrow mb-1">Account</p>
      <h1 class="pr-section-title">Security</h1>

      <div class="card border-0 shadow-sm mt-3">
        <div class="card-body p-4 p-md-5">
          <asp:Label ID="lblMsg" runat="server" Visible="false" />

          <div class="d-flex justify-content-between align-items-start flex-wrap gap-3">
            <div>
              <h2 class="h5 mb-1">Two-step login</h2>
              <p class="text-muted mb-0" style="max-width:420px;">
                When enabled, we email you a 6-digit code each time you sign in — so a password alone
                isn't enough to access your account.
              </p>
            </div>
            <asp:Literal ID="litStatus" runat="server" />
          </div>

          <div class="mt-4">
            <asp:Button ID="btnToggle" runat="server" OnClick="btnToggle_Click" />
          </div>
        </div>
      </div>

      <p class="small text-muted mt-3">
        Codes are delivered by email. In this academic build, email is handled locally — codes are written to
        <code>App_Data/EmailLog.txt</code> and shown on-screen when running on localhost.
      </p>
    </div>
  </section>
</asp:Content>