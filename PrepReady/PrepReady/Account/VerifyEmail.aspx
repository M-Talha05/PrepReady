<%@ Page Title="Verify Email" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="VerifyEmail.aspx.cs" Inherits="PrepReady.Account.VerifyEmail" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-md-7 col-lg-6">
                    <div class="card">
                        <div class="card-body p-4 p-md-5 text-center">
                            <span class="pr-auth-icon" aria-hidden="true">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/></svg>
                            </span>
                            <h1 class="h3 pr-section-title d-inline-block mt-3">Email Verification</h1>

                            <asp:Label ID="lblResult" runat="server" CssClass="alert d-block mt-3" />

                            <a href="<%: ResolveUrl("~/Account/Login.aspx") %>" class="pr-btn-accent mt-2 d-inline-block">Go to Login</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
</asp:Content>