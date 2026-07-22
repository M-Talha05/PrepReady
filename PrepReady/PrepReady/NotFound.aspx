<%@ Page Title="Page not found" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="NotFound.aspx.cs" Inherits="PrepReady.NotFound" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container text-center pr-narrow">
            <div class="pr-status-code">404</div>
            <span class="pr-auth-icon mt-2" aria-hidden="true">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><path d="m21 21-4.3-4.3"/></svg>
            </span>
            <h1 class="pr-section-title d-inline-block mt-3">Page not found</h1>
            <p class="text-muted">The page you're looking for doesn't exist or has moved.</p>
            <a class="pr-btn-accent d-inline-block mt-2" href="<%: ResolveUrl("~/Default.aspx") %>">Back to home</a>
        </div>
    </section>
</asp:Content>