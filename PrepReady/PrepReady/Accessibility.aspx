<%@ Page Title="Accessibility Statement" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Accessibility.aspx.cs" Inherits="PrepReady.Accessibility" %>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
  <section class="pr-section">
    <div class="container" style="max-width:820px;">
      <p class="pr-eyebrow mb-1">Legal</p>
      <h1 class="pr-section-title">Accessibility Statement</h1>
      <p class="text-muted">We want PrepReady to be usable by everyone, including people who rely on assistive technology.</p>

      <h2 class="h5 mt-4">Our commitment</h2>
      <p>We aim to meet <strong>WCAG 2.1 Level AA</strong>. Accessibility is considered as part of the site's design system.</p>

      <h2 class="h5 mt-4">What we've built in</h2>
      <ul>
        <li>A "skip to content" link and semantic HTML5 landmarks for screen-reader navigation.</li>
        <li>Visible keyboard focus rings and full keyboard operability of menus, forms, and dialogs.</li>
        <li>Colour contrast that meets AA, with the navy/red theme checked for legibility.</li>
        <li>Text alternatives for meaningful images and <code>aria-hidden</code> on decorative icons.</li>
        <li>Respect for the <em>reduced motion</em> system setting — animations are minimised when requested.</li>
        <li>Responsive layouts that work from small phones to large desktops.</li>
      </ul>

      <h2 class="h5 mt-4">Known limitations</h2>
      <p>As an academic project, some third-party components (e.g. generated PDF certificates) may have limited
         assistive-technology support. We welcome feedback so we can improve.</p>

      <h2 class="h5 mt-4">Give us feedback</h2>
      <p>If you hit an accessibility barrier, please tell us via the
         <a href="<%= ResolveUrl("~/Contact.aspx") %>">contact form</a> and we'll do our best to help.</p>
    </div>
  </section>
</asp:Content>