<%@ Page Title="Privacy Policy" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Privacy.aspx.cs" Inherits="PrepReady.Privacy" %>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
  <section class="pr-section">
    <div class="container" style="max-width:820px;">
      <p class="pr-eyebrow mb-1">Legal</p>
      <h1 class="pr-section-title">Privacy Policy</h1>
      <p class="text-muted">Last updated: 2026. This describes how PrepReady collects, uses, and protects your personal data.</p>

      <div class="alert alert-info small">
        <strong>Academic notice.</strong> PrepReady is a university project (APU CT050-3-2-WAPP). It is not a live
        government service; all agencies and endorsements are mock data used for demonstration only.
      </div>

      <h2 class="h5 mt-4">1. What we collect</h2>
      <ul>
        <li><strong>Account data</strong> — your name, email, and a securely hashed password.</li>
        <li><strong>Learning data</strong> — course enrolments, lesson progress, quiz and exam results, certificates, points, and badges.</li>
        <li><strong>Optional profile data</strong> — a short bio and a profile photo, if you choose to add them.</li>
        <li><strong>Activity data</strong> — sign-in audit records (time, result, IP address) kept to protect your account.</li>
        <li><strong>Support data</strong> — messages you send us through the contact form and any replies.</li>
      </ul>

      <h2 class="h5 mt-4">2. How we use it</h2>
      <p>To operate your account, deliver courses, issue and verify certificates, publish proven responders to the
         public registry (only after you complete the Tier-3 workflow), award points, and respond to your enquiries.</p>

      <h2 class="h5 mt-4">3. How we protect it</h2>
      <ul>
        <li>Passwords are stored using <strong>BCrypt</strong> one-way hashing — never in plain text.</li>
        <li>Optional <strong>two-step verification</strong> (an emailed one-time code) is available in your Security settings.</li>
        <li>Repeated failed sign-ins trigger a temporary lockout, and every attempt is audited.</li>
        <li>Data is transmitted over the application's secured session and protected against common web attacks (CSRF, clickjacking, XSS).</li>
      </ul>

      <h2 class="h5 mt-4">4. Your rights (PDPA)</h2>
      <p>In line with Malaysia's Personal Data Protection Act 2010, you may:</p>
      <ul>
        <li><strong>Access &amp; port</strong> your data — download a copy from your account settings.</li>
        <li><strong>Correct</strong> your data — update your name, bio, and photo on your profile.</li>
        <li><strong>Erase</strong> your data — permanently delete your account and associated records.</li>
      </ul>

      <h2 class="h5 mt-4">5. Cookies</h2>
      <p>We use a strictly necessary session cookie to keep you signed in, and (if you choose it) a "remember me"
         cookie so you don't have to sign in every visit. We do not use third-party advertising or tracking cookies.</p>

      <h2 class="h5 mt-4">6. Data retention</h2>
      <p>We keep your data while your account is active. When you delete your account, your personal records are
         removed from the live database.</p>

      <h2 class="h5 mt-4">7. Contact</h2>
      <p>Questions about your data? Use our <a href="<%= ResolveUrl("~/Contact.aspx") %>">contact form</a>.</p>
    </div>
  </section>
</asp:Content>