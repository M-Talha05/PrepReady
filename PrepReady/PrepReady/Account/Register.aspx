<%@ Page Title="Register" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="PrepReady.Account.Register" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-md-7 col-lg-6">
                    <div class="card">
                        <div class="card-body p-4 p-md-5">
                            <div class="text-center mb-4">
                                <span class="pr-auth-icon" aria-hidden="true">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="10" cy="8" r="4"/><path d="M3 21v-1a6 6 0 0 1 6-6h2"/><path d="M19 8v6M16 11h6"/></svg>
                                </span>
                                <h1 class="h3 pr-section-title d-inline-block mt-3">Create your account</h1>
                            </div>

                            <%-- Server-side business message (e.g. email already used) --%>
                            <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger d-block" Visible="false" />

                            <%-- Success panel with the verification link (email also logged to App_Data) --%>
                            <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
                                <div class="alert alert-success">
                                    <strong>Account created!</strong> We've sent a verification email
                                    (in demo mode it's saved to <code>App_Data/EmailLog.txt</code>).
                                </div>
                                <asp:HyperLink ID="lnkVerify" runat="server" CssClass="pr-btn-accent" />
                            </asp:Panel>

                            <asp:Panel ID="pnlForm" runat="server">
                                <asp:ValidationSummary ID="vsReg" runat="server" CssClass="alert alert-warning"
                                                       ValidationGroup="reg" DisplayMode="BulletList" HeaderText="Please fix the following:" />

                                <div class="mb-3">
                                    <label class="form-label" for="<%= txtFullName.ClientID %>">Full name</label>
                                    <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" />
                                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtFullName"
                                        ValidationGroup="reg" CssClass="text-danger small" Display="Dynamic"
                                        ErrorMessage="Full name is required." Text="Full name is required." />
                                </div>

                                <div class="mb-3">
                                    <label class="form-label" for="<%= txtEmail.ClientID %>">Email</label>
                                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" />
                                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEmail"
                                        ValidationGroup="reg" CssClass="text-danger small" Display="Dynamic"
                                        ErrorMessage="Email is required." Text="Email is required." />
                                    <asp:RegularExpressionValidator runat="server" ControlToValidate="txtEmail"
                                        ValidationGroup="reg" CssClass="text-danger small" Display="Dynamic"
                                        ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                                        ErrorMessage="Enter a valid email address." Text="Enter a valid email address." />
                                </div>

                                <div class="mb-3">
                                    <label class="form-label" for="<%= txtPassword.ClientID %>">Password</label>
                                    <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" />
                                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPassword"
                                        ValidationGroup="reg" CssClass="text-danger small" Display="Dynamic"
                                        ErrorMessage="Password is required." Text="Password is required." />
                                    <asp:RegularExpressionValidator runat="server" ControlToValidate="txtPassword"
                                        ValidationGroup="reg" CssClass="text-danger small" Display="Dynamic"
                                        ValidationExpression="^(?=.*[A-Za-z])(?=.*\d).{8,}$"
                                        ErrorMessage="Password must be 8+ characters and include a letter and a number."
                                        Text="Min 8 chars, 1 letter + 1 number." />
                                </div>

                                <div class="mb-4">
                                    <label class="form-label" for="<%= txtConfirm.ClientID %>">Confirm password</label>
                                    <asp:TextBox ID="txtConfirm" runat="server" CssClass="form-control" TextMode="Password" />
                                    <asp:CompareValidator runat="server" ControlToValidate="txtConfirm"
                                        ControlToCompare="txtPassword" Operator="Equal" Type="String"
                                        ValidationGroup="reg" CssClass="text-danger small" Display="Dynamic"
                                        ErrorMessage="Passwords do not match." Text="Passwords do not match." />
                                </div>

                                <%-- EX-8: CAPTCHA --%>
                                <div class="mb-4">
                                    <label class="form-label" for="<%= txtCaptchaReg.ClientID %>">Verification: <asp:Literal ID="litCaptchaReg" runat="server" /></label>
                                    <asp:TextBox ID="txtCaptchaReg" runat="server" CssClass="form-control" />
                                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtCaptchaReg"
                                        ValidationGroup="reg" CssClass="text-danger small" Display="Dynamic"
                                        ErrorMessage="Answer the verification question." Text="Answer the verification question." />
                                </div>

                                <asp:Button ID="btnRegister" runat="server" CssClass="pr-btn-accent w-100"
                                            Text="Create account" ValidationGroup="reg" OnClick="btnRegister_Click" />

                                <p class="text-center mt-3 mb-0">
                                    Already have an account?
                                    <a href="<%: ResolveUrl("~/Account/Login.aspx") %>">Log in</a>
                                </p>
                            </asp:Panel>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
</asp:Content>