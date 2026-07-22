<%@ Page Title="Something went wrong" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Error.aspx.cs" Inherits="PrepReady.Error" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container text-center pr-narrow">
            <span class="pr-auth-icon" style="background:rgba(230,57,70,.10); color:var(--red);" aria-hidden="true">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3 22 20H2L12 3Z"/><path d="M12 10v4M12 17h.01"/></svg>
            </span>
            <h1 class="pr-section-title d-inline-block mt-3">Something went wrong</h1>
            <p class="text-muted">An unexpected error occurred. It has been logged and we're on it.
                Please try again in a moment.</p>
            <a class="pr-btn-accent d-inline-block mt-2" href="<%: ResolveUrl("~/Default.aspx") %>">Back to home</a>
        </div>
    </section>
</asp:Content>