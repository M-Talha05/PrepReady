<%@ Page Title="Access Denied" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AccessDenied.aspx.cs" Inherits="PrepReady.Account.AccessDenied" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container text-center pr-narrow">
            <%-- inline style tints this icon red for the denied state --%>
            <span class="pr-auth-icon" style="background:rgba(230,57,70,.10); color:var(--red);" aria-hidden="true">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3 20 6v5c0 5-3.5 8-8 10-4.5-2-8-5-8-10V6l8-3Z"/><rect x="9.5" y="11" width="5" height="4.5" rx="1"/><path d="M10.5 11v-1.2a1.5 1.5 0 0 1 3 0V11"/></svg>
            </span>
            <h1 class="pr-section-title d-inline-block mt-3">Access Denied</h1>
            <p class="text-muted">You don't have permission to view that page with your current role.</p>
            <a href="<%: ResolveUrl("~/Default.aspx") %>" class="pr-btn-accent d-inline-block mt-2">Back to Home</a>
        </div>
    </section>
</asp:Content>