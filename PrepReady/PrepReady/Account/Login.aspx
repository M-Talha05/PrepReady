<%@ Page Title="Login" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="PrepReady.Account.Login" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-md-6 col-lg-5">
                    <div class="card">
                        <div class="card-body p-4 p-md-5">
                            <div class="text-center mb-4">
                                <span class="pr-auth-icon" aria-hidden="true">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <rect x="4" y="10" width="16" height="11" rx="2" />
                                        <path d="M8 10V7a4 4 0 0 1 8 0v3" />
                                    </svg>
                                </span>
                                <h1 class="h3 pr-section-title d-inline-block mt-3">Log in</h1>
                            </div>

                            <% if (Request.QueryString["timeout"] == "1")
                                { %>
                            <div class="alert alert-info d-block" role="alert">
                                You were signed out because your session was idle for a while.
                                Please log in again to continue.
                            </div>
                            <% } %>

                            <% if (Request.QueryString["deleted"] == "1")
                                { %>
                            <div class="alert alert-success d-block" role="alert">
                                Your account and all associated data have been permanently deleted.
                                Thank you for using PrepReady.
                            </div>
                            <% } %>

                            <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger d-block" Visible="false" />

                            <asp:ValidationSummary ID="vsLogin" runat="server" CssClass="alert alert-warning"
                                ValidationGroup="login" DisplayMode="BulletList" HeaderText="Please fix the following:" />

                            <div class="mb-3">
                                <label class="form-label" for="<%= txtEmail.ClientID %>">Email</label>
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" />
                                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEmail"
                                    ValidationGroup="login" CssClass="text-danger small" Display="Dynamic"
                                    ErrorMessage="Email is required." Text="Email is required." />
                            </div>

                            <div class="mb-3">
                                <label class="form-label" for="<%= txtPassword.ClientID %>">Password</label>
                                <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" />
                                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPassword"
                                    ValidationGroup="login" CssClass="text-danger small" Display="Dynamic"
                                    ErrorMessage="Password is required." Text="Password is required." />
                            </div>

                            <div class="form-check mb-2">
                                <asp:CheckBox ID="chkRemember" runat="server" CssClass="form-check-input" />
                                <label class="form-check-label small" for="<%= chkRemember.ClientID %>">
                                    Remember me on this device for 30 days
                                </label>
                            </div>

                            <div class="text-end mb-3">
                                <a href="<%= ResolveUrl("~/Account/ForgotPassword.aspx") %>" class="small">Forgot password?</a>
                            </div>

                            <asp:Button ID="btnLogin" runat="server" CssClass="pr-btn-accent w-100"
                                Text="Log in" ValidationGroup="login" OnClick="btnLogin_Click" />

                            <p class="text-center mt-3 mb-0">
                                New here? <a href="<%: ResolveUrl("~/Account/Register.aspx") %>">Create an account</a>
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
</asp:Content>