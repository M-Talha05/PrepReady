<%@ Page Title="Reset Password" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ResetPassword.aspx.cs" Inherits="PrepReady.Account.ResetPassword" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <div class="mx-auto" style="max-width: 480px;">
                <div class="card border-0 shadow-sm">
                    <div class="card-body p-4 p-md-5">

                        <div class="text-center mb-4">
                            <div class="pr-auth-icon mx-auto mb-3" aria-hidden="true">
                                <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 1 1-7.778 7.778 5.5 5.5 0 0 1 7.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3"></path></svg>
                            </div>
                            <h1 class="h3 mb-2" style="font-family: var(--font-head);">Choose a new password</h1>
                        </div>

                        <asp:Panel ID="pnlForm" runat="server">
                            <div class="mb-3">
                                <label class="form-label" for="<%= txtNewPassword.ClientID %>">New password</label>
                                <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control" TextMode="Password" onkeyup="prRevalidateMatch();" />
                                <asp:RequiredFieldValidator ID="rfvNew" runat="server" ControlToValidate="txtNewPassword"
                                    ValidationGroup="rp" Display="Dynamic" CssClass="text-danger small d-block mt-1"
                                    ErrorMessage="New password is required." />
                                <asp:RegularExpressionValidator ID="revNew" runat="server" ControlToValidate="txtNewPassword"
                                    ValidationGroup="rp" Display="Dynamic" CssClass="text-danger small d-block mt-1"
                                    ValidationExpression="^(?=.*[A-Za-z])(?=.*\d).{6,}$"
                                    ErrorMessage="At least 6 characters, including a letter and a number." />
                            </div>
                            <div class="mb-3">
                                <label class="form-label" for="<%= txtConfirm.ClientID %>">Confirm new password</label>
                                <asp:TextBox ID="txtConfirm" runat="server" CssClass="form-control" TextMode="Password" onkeyup="prRevalidateMatch();" />
                                <asp:CompareValidator ID="cmpNew" runat="server" ControlToValidate="txtConfirm"
                                    ControlToCompare="txtNewPassword" ValidationGroup="rp" Display="Dynamic"
                                    CssClass="text-danger small d-block mt-1" ErrorMessage="Passwords do not match." />
                            </div>
                            <div class="d-grid">
                                <asp:Button ID="btnReset" runat="server" CssClass="btn pr-btn-accent" Text="Reset password"
                                    ValidationGroup="rp" OnClick="btnReset_Click" />
                            </div>
                        </asp:Panel>

                        <asp:Panel ID="pnlInvalid" runat="server" Visible="false">
                            <div class="alert alert-danger" role="alert">
                                This password reset link is invalid or has expired.
                <a href="<%= ResolveUrl("~/Account/ForgotPassword.aspx") %>">Request a new one</a>.
                            </div>
                        </asp:Panel>

                        <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
                            <div class="alert alert-success" role="alert">
                                Your password has been reset. You can now
                <a href="<%= ResolveUrl("~/Account/Login.aspx") %>">sign in</a> with your new password.
                            </div>
                        </asp:Panel>

                    </div>
                </div>
            </div>
        </div>
    </section>

    <script type="text/javascript">
        // Re-run the "passwords match" check on every keystroke in EITHER box,
        // so the warning clears as soon as the values actually match.
        function prRevalidateMatch() {
            var v = document.getElementById('<%= cmpNew.ClientID %>');
            if (v && typeof ValidatorValidate === 'function') {
                ValidatorValidate(v);
            }
        }
    </script>

</asp:Content>
