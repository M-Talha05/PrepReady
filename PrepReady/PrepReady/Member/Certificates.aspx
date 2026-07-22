<%@ Page Title="My Certificates" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Certificates.aspx.cs" Inherits="PrepReady.Member.Certificates" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <p class="pr-eyebrow mb-1">Your credentials</p>
            <h1 class="pr-section-title">My Certificates</h1>

            <asp:Label ID="lblEmpty" runat="server" CssClass="alert alert-info d-block" Visible="false"
                       Text="You don't have any certificates yet. Complete a course's final exam to earn one." />

            <div class="row g-4">
                <asp:Repeater ID="rptCerts" runat="server" OnItemDataBound="rptCerts_ItemDataBound" OnItemCommand="rptCerts_ItemCommand">
                    <ItemTemplate>
                        <div class="col-md-6">
                            <div class="pr-cat-card">
                                <div class="d-flex justify-content-between align-items-start">
                                    <span class="pr-tag mb-2"><%# Eval("CategoryName") %></span>
                                    <asp:Literal ID="litStatus" runat="server" />
                                </div>
                                <h3><%# Eval("CourseTitle") %></h3>
                                <p class="mb-1"><strong><asp:Literal ID="litTier" runat="server" /></strong></p>
                                <p class="small text-muted mb-1"><asp:Literal ID="litDates" runat="server" /></p>
                                <p class="small text-muted">ID: <%# Eval("CertCode") %></p>

                                <div class="d-flex flex-wrap gap-2 mt-2">
                                    <asp:HyperLink ID="lnkDownload" runat="server" CssClass="pr-btn-accent"
                                                   NavigateUrl='<%# "~/Member/CertificatePdf.aspx?code=" + Eval("CertCode") %>'
                                                   Target="_blank" Text="Download PDF" />
                                    <asp:HyperLink ID="lnkVerify" runat="server" CssClass="pr-btn-outline"
                                                   NavigateUrl='<%# "~/Verify.aspx?code=" + Eval("CertCode") %>'
                                                   Target="_blank" Text="Verify" />
                                    <asp:LinkButton ID="btnTier2" runat="server" CssClass="btn btn-outline-primary"
                                                    CommandName="Tier2" CommandArgument='<%# Eval("CourseId") %>'
                                                    Visible="false" Text="Start Tier 2 upgrade" />
                                    <asp:LinkButton ID="btnRenew" runat="server" CssClass="btn btn-outline-success"
                                                    CommandName="Renew" CommandArgument='<%# Eval("CourseId") %>'
                                                    Visible="false" Text="Renew (1.5× points)" />
                                </div>

                                <%-- ===== EX-13: share this credential (points at its public Verify URL) ===== --%>
                                <div class="pr-share d-flex align-items-center flex-wrap gap-2 mt-3"
                                     data-code="<%# Eval("CertCode") %>"
                                     data-verify="<%# System.Web.VirtualPathUtility.ToAbsolute("~/Verify.aspx") %>"
                                     data-text="<%# HttpUtility.HtmlAttributeEncode("I earned a verified PrepReady credential: " + Eval("CourseTitle") + ". See it on the National Recognised Responders Registry:") %>">
                                    <span class="small text-muted me-1">Share:</span>
                                    <button type="button" class="pr-share-btn pr-share-go" data-net="linkedin" aria-label="Share on LinkedIn" title="LinkedIn">
                                        <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M4.98 3.5A2.5 2.5 0 1 0 5 8.5a2.5 2.5 0 0 0-.02-5zM3 9h4v12H3zM10 9h3.8v1.7h.05c.53-1 1.83-2.05 3.77-2.05 4.03 0 4.78 2.65 4.78 6.1V21h-4v-5.4c0-1.29-.02-2.95-1.8-2.95-1.8 0-2.08 1.4-2.08 2.85V21h-4z"/></svg>
                                    </button>
                                    <button type="button" class="pr-share-btn pr-share-go" data-net="x" aria-label="Share on X" title="X (Twitter)">
                                        <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M18.24 2.25h3.3l-7.2 8.23L22.5 21.75h-6.63l-5.2-6.8-5.94 6.8H1.43l7.7-8.8L1.5 2.25h6.8l4.7 6.22 5.24-6.22zm-1.16 17.52h1.83L7.02 4.13H5.06z"/></svg>
                                    </button>
                                    <button type="button" class="pr-share-btn pr-share-go" data-net="whatsapp" aria-label="Share on WhatsApp" title="WhatsApp">
                                        <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M17.5 14.4c-.3-.15-1.77-.87-2.04-.97-.27-.1-.47-.15-.67.15-.2.3-.77.96-.94 1.16-.17.2-.35.22-.65.07-.3-.15-1.26-.46-2.4-1.48-.89-.79-1.49-1.77-1.66-2.07-.17-.3-.02-.46.13-.61.13-.13.3-.35.45-.52.15-.17.2-.3.3-.5.1-.2.05-.37-.02-.52-.07-.15-.67-1.62-.92-2.22-.24-.58-.49-.5-.67-.51h-.57c-.2 0-.52.07-.8.37-.27.3-1.04 1.02-1.04 2.48s1.07 2.88 1.22 3.08c.15.2 2.1 3.2 5.08 4.49.71.31 1.26.49 1.7.63.71.23 1.36.2 1.87.12.57-.08 1.77-.72 2.02-1.42.25-.7.25-1.3.17-1.42-.07-.13-.27-.2-.57-.35zM12.05 21.5h-.01a9.4 9.4 0 0 1-4.8-1.32l-.34-.2-3.57.94.95-3.48-.22-.36a9.42 9.42 0 0 1 14.65-11.6 9.38 9.38 0 0 1 2.76 6.67c0 5.2-4.24 9.35-9.4 9.35zm7.86-17.2A11.36 11.36 0 0 0 12.05.25C5.8.25.73 5.32.73 11.55c0 2.02.53 3.99 1.53 5.73L.63 23.75l6.6-1.73a11.3 11.3 0 0 0 5.4 1.38h.01c6.26 0 11.33-5.07 11.33-11.3a11.27 11.27 0 0 0-3.06-7.8z"/></svg>
                                    </button>
                                    <button type="button" class="pr-share-btn pr-share-go" data-net="copy" aria-label="Copy verification link" title="Copy link">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1"/><path d="M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1"/></svg>
                                    </button>
                                    <span class="pr-share-feedback ms-1" aria-live="polite"></span>
                                </div>

                                <asp:Literal ID="litTierNote" runat="server" />
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>

    <script src="<%= ResolveUrl("~/Scripts/pr-share.js") %>"></script>
</asp:Content>