<%@ Page Title="Change Password" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ChangePassword.aspx.cs" Inherits="PrepReady.Account.ChangePassword" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
  <section class="pr-section">
    <div class="container">
      <div class="mx-auto" style="max-width: 520px;">
        <div class="card border-0 shadow-sm">
          <div class="card-body p-4 p-md-5">

            <h1 class="h3 mb-4" style="font-family: var(--font-head);">Change password</h1>

            <asp:Label ID="lblMsg" runat="server" Visible="false" />

            <div class="mb-3">
              <label class="form-label" for="<%= txtCurrent.ClientID %>">Current password</label>
              <asp:TextBox ID="txtCurrent" runat="server" CssClass="form-control" TextMode="Password" />
              <asp:RequiredFieldValidator ID="rfvCur" runat="server" ControlToValidate="txtCurrent"
                  ValidationGroup="cp" Display="Dynamic" CssClass="text-danger small d-block mt-1"
                  ErrorMessage="Current password is required." />
            </div>
            <div class="mb-3">
              <label class="form-label" for="<%= txtNew.ClientID %>">New password</label>
              <asp:TextBox ID="txtNew" runat="server" CssClass="form-control" TextMode="Password" />
              <asp:RequiredFieldValidator ID="rfvNew" runat="server" ControlToValidate="txtNew"
                  ValidationGroup="cp" Display="Dynamic" CssClass="text-danger small d-block mt-1"
                  ErrorMessage="New password is required." />
              <asp:RegularExpressionValidator ID="revNew" runat="server" ControlToValidate="txtNew"
                  ValidationGroup="cp" Display="Dynamic" CssClass="text-danger small d-block mt-1"
                  ValidationExpression="^(?=.*[A-Za-z])(?=.*\d).{6,}$"
                  ErrorMessage="At least 6 characters, including a letter and a number." />
            </div>
            <div class="mb-3">
              <label class="form-label" for="<%= txtConfirm.ClientID %>">Confirm new password</label>
              <asp:TextBox ID="txtConfirm" runat="server" CssClass="form-control" TextMode="Password" />
              <asp:CompareValidator ID="cmpNew" runat="server" ControlToValidate="txtConfirm"
                  ControlToCompare="txtNew" ValidationGroup="cp" Display="Dynamic"
                  CssClass="text-danger small d-block mt-1" ErrorMessage="Passwords do not match." />
            </div>

            <div class="d-flex gap-2">
              <asp:Button ID="btnChange" runat="server" CssClass="btn pr-btn-accent" Text="Update password"
                  ValidationGroup="cp" OnClick="btnChange_Click" />
              <a href="<%= ResolveUrl("~/Member/Dashboard.aspx") %>" class="btn pr-btn-outline">Cancel</a>
            </div>

          </div>
        </div>
      </div>
    </div>
  </section>
</asp:Content>