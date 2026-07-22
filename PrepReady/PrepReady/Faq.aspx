<%@ Page Title="FAQ &amp; Help" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Faq.aspx.cs" Inherits="PrepReady.Faq" %>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
  <section class="pr-section">
    <div class="container" style="max-width:820px;">
      <p class="pr-eyebrow mb-1">Help Centre</p>
      <h1 class="pr-section-title">Frequently asked questions</h1>
      <p class="text-muted">Quick answers about accounts, courses, certification, and rewards.</p>

      <div class="accordion mt-3" id="faqAcc">
        <div class="accordion-item">
          <h2 class="accordion-header"><button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#q1">How do I earn a certificate?</button></h2>
          <div id="q1" class="accordion-collapse collapse" data-bs-parent="#faqAcc"><div class="accordion-body">
            Enrol in a course, complete all its lessons, pass each lesson quiz, then pass the final exam. A Tier-1
            certificate with a unique code and QR is issued automatically.
          </div></div>
        </div>
        <div class="accordion-item">
          <h2 class="accordion-header"><button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#q2">What are the three certificate tiers?</button></h2>
          <div id="q2" class="accordion-collapse collapse" data-bs-parent="#faqAcc"><div class="accordion-body">
            <strong>Tier 1</strong> is earned by passing a course. <strong>Tier 2</strong> is a higher-mark re-exam that
            renews your credential. <strong>Tier 3</strong> is awarded by an officer after real community deployment, which
            also publishes you to the public registry.
          </div></div>
        </div>
        <div class="accordion-item">
          <h2 class="accordion-header"><button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#q3">How can anyone verify my certificate?</button></h2>
          <div id="q3" class="accordion-collapse collapse" data-bs-parent="#faqAcc"><div class="accordion-body">
            Every certificate carries a unique code and QR that link to the public <a href="<%= ResolveUrl("~/Verify.aspx") %>">verification page</a>,
            confirming it is genuine.
          </div></div>
        </div>
        <div class="accordion-item">
          <h2 class="accordion-header"><button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#q4">How do points and rewards work?</button></h2>
          <div id="q4" class="accordion-collapse collapse" data-bs-parent="#faqAcc"><div class="accordion-body">
            You earn points for learning milestones and community service. Spend them on partner vouchers in the
            Rewards area. Points have no cash value.
          </div></div>
        </div>
        <div class="accordion-item">
          <h2 class="accordion-header"><button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#q5">How do I turn on two-step verification?</button></h2>
          <div id="q5" class="accordion-collapse collapse" data-bs-parent="#faqAcc"><div class="accordion-body">
            Open the user menu → <strong>Security (2FA)</strong> and turn it on. After that, each sign-in asks for a
            6-digit code sent to your email.
          </div></div>
        </div>
        <div class="accordion-item">
          <h2 class="accordion-header"><button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#q6">I forgot my password — what do I do?</button></h2>
          <div id="q6" class="accordion-collapse collapse" data-bs-parent="#faqAcc"><div class="accordion-body">
            Use <a href="<%= ResolveUrl("~/Account/ForgotPassword.aspx") %>">Forgot password</a>. You'll receive a reset
            link valid for one hour.
          </div></div>
        </div>
        <div class="accordion-item">
          <h2 class="accordion-header"><button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#q7">Who are officers, and what do they do?</button></h2>
          <div id="q7" class="accordion-collapse collapse" data-bs-parent="#faqAcc"><div class="accordion-body">
            Officers are partner-agency staff who review community deployments, sign them off, and award Tier-3
            recognition that publishes responders to the national registry.
          </div></div>
        </div>
        <div class="accordion-item">
          <h2 class="accordion-header"><button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#q8">Still need help?</button></h2>
          <div id="q8" class="accordion-collapse collapse" data-bs-parent="#faqAcc"><div class="accordion-body">
            Send us a message through the <a href="<%= ResolveUrl("~/Contact.aspx") %>">contact form</a> — signed-in
            members can follow the conversation under <em>My Messages</em>.
          </div></div>
        </div>
      </div>
    </div>
  </section>
</asp:Content>