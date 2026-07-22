<%@ Page Title="Home" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="PrepReady._Default" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="head" runat="server">
    <%-- INTERNAL CSS: styles specific to the homepage (hero, stats, cards, quotes) --%>
    <style>
        .pr-hero h1 { font-weight: 700; font-size: clamp(2rem, 5vw, 3.25rem); line-height: 1.08; }
        .pr-hero .pr-btn-outline { border-color: #fff; color: #fff; }
        .pr-hero .pr-btn-outline:hover { background: #fff; color: var(--navy); }
        .pr-hero-shield {
            position: absolute; right: -30px; top: 50%; transform: translateY(-50%);
            width: 360px; height: 360px; opacity: .12; pointer-events: none; user-select: none;
        }
        @media (max-width: 991.98px) { .pr-hero-shield { display: none; } }

        .pr-section-sub { color: var(--muted); max-width: 640px; margin: .5rem auto 0; }
        .pr-section-soft { background: #eef2f7; }

        .pr-cat-icon {
            width: 52px; height: 52px; border-radius: 14px;
            display: inline-flex; align-items: center; justify-content: center;
            background: rgba(11,31,58,.06); color: var(--navy);
            margin-bottom: 1rem; transition: background var(--t), color var(--t);
        }
        .pr-cat-icon svg { width: 26px; height: 26px; }
        .pr-cat-card:hover .pr-cat-icon { background: rgba(230,57,70,.10); color: var(--red); }
        .pr-cat-card h3 { font-size: 1.05rem; margin-bottom: .4rem; }
        .pr-cat-card p { color: var(--muted); font-size: .925rem; margin-bottom: 0; }

        .pr-stats { background: var(--navy-700); color: #fff; }
        .pr-stats .pr-stat-num { color: var(--red); }
        .pr-stats .pr-stat-label { color: rgba(255,255,255,.75); }

        .pr-partner-seal {
            display: inline-flex; align-items: center; justify-content: center;
            width: 34px; height: 34px; border-radius: 50%;
            background: var(--navy); color: #fff;
            font-family: var(--font-head); font-weight: 700; font-size: .72rem;
        }

        .pr-registry-cta {
            background: linear-gradient(135deg, var(--red-600), var(--red));
            color: #fff; border-radius: var(--r-lg);
            padding: clamp(1.75rem, 4vw, 3rem); box-shadow: var(--sh-lg);
        }
        .pr-registry-cta h2 { color: #fff; }
        .pr-registry-cta .pr-btn-outline { border-color: #fff; color: #fff; }
        .pr-registry-cta .pr-btn-outline:hover { background: #fff; color: var(--red); }

        .pr-quote {
            background: var(--surface); border: 1px solid var(--line);
            border-radius: var(--r-lg); padding: 1.5rem; box-shadow: var(--sh-sm);
            height: 100%; margin: 0;
        }
        .pr-quote blockquote { font-size: 1rem; color: var(--ink); margin-bottom: 1rem; }
        .pr-quote figcaption { font-family: var(--font-head); font-weight: 600; color: var(--navy); }
        .pr-role { color: var(--muted); font-weight: 400; }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ============ HERO ============ --%>
    <section class="pr-hero">
        <svg class="pr-hero-shield" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
            <path d="M32 3 L57 13 V31 C57 46 46 57 32 61 C18 57 7 46 7 31 V13 Z" fill="#ffffff" />
            <polyline points="14,34 24,34 28,23 34,45 38,34 50,34" fill="none" stroke="#0b1f3a" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
        <div class="container position-relative">
            <div class="row align-items-center">
                <div class="col-lg-8">
                    <%-- INLINE CSS demonstrated on this badge --%>
                    <span style="display:inline-block; background:rgba(230,57,70,.15); color:#ffd0d4; border:1px solid rgba(230,57,70,.6); border-radius:50px; padding:.35rem 1rem; font-weight:600; font-size:.8rem; letter-spacing:.02em; margin-bottom:1.25rem;">
                        Government-backed emergency preparedness
                    </span>
                    <h1>Learn It. Prove It. <span style="color:#e63946;">Serve It.</span></h1>
                    <p class="pr-lead mt-3">
                        Master life-saving and preparedness skills, validate real competence through a
                        three-tier certification model, and join the National Recognised Responders Registry.
                    </p>
                    <div class="mt-4 d-flex flex-wrap gap-3">
                        <a href="<%: ResolveUrl("~/Courses/Catalogue.aspx") %>" class="pr-btn-accent">Explore Courses</a>
                        <a href="<%: ResolveUrl("~/Registry/Index.aspx") %>" class="pr-btn-outline">View the Registry</a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <%-- ============ IMPACT STATS ============ --%>
    <section class="pr-stats py-4">
        <div class="container">
            <div class="row text-center gy-3">
                <div class="col-6 col-md-3"><div class="pr-stat-num">8</div><div class="pr-stat-label">Skill categories</div></div>
                <div class="col-6 col-md-3"><div class="pr-stat-num">3</div><div class="pr-stat-label">Certification tiers</div></div>
                <div class="col-6 col-md-3"><div class="pr-stat-num">5</div><div class="pr-stat-label">Endorsing agencies</div></div>
                <div class="col-6 col-md-3"><div class="pr-stat-num">100%</div><div class="pr-stat-label">Verifiable certs</div></div>
            </div>
        </div>
    </section>

    <%-- ============ COURSE CATEGORIES PREVIEW ============ --%>
    <section class="pr-section">
        <div class="container">
            <header class="text-center">
                <h2 class="pr-section-title">Eight ways to be ready</h2>
                <p class="pr-section-sub">Every category endorsed by a government partner, with courses, lessons, and competence-based quizzes.</p>
            </header>
            <div class="row g-4 mt-1">
                <article class="col-sm-6 col-lg-3">
                    <div class="pr-cat-card">
                        <span class="pr-cat-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="3"/><path d="M12 8v8M8 12h8"/></svg>
                        </span>
                        <h3>First Aid &amp; Emergency Medicine</h3>
                        <p>CPR &amp; AED, bleeding control, burns, anaphylaxis, stroke (FAST), choking.</p>
                    </div>
                </article>
                <article class="col-sm-6 col-lg-3">
                    <div class="pr-cat-card">
                        <span class="pr-cat-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2C9 6 7 8 7 12a5 5 0 0 0 10 0c0-2-1-3.5-2.5-5C13.5 8.5 13 7 12 2Z"/></svg>
                        </span>
                        <h3>Fire Safety &amp; Rescue</h3>
                        <p>Extinguisher types, home escape planning, evacuation, smoke detectors.</p>
                    </div>
                </article>
                <article class="col-sm-6 col-lg-3">
                    <div class="pr-cat-card">
                        <span class="pr-cat-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3 22 20H2L12 3Z"/><path d="M12 10v4M12 17h.01"/></svg>
                        </span>
                        <h3>Disaster Preparedness</h3>
                        <p>Earthquake, flood evacuation, emergency kit, typhoon, power outage.</p>
                    </div>
                </article>
                <article class="col-sm-6 col-lg-3">
                    <div class="pr-cat-card">
                        <span class="pr-cat-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 15s-3-1.8-3-4a1.8 1.8 0 0 1 3-1 1.8 1.8 0 0 1 3 1c0 2.2-3 4-3 4Z"/></svg>
                        </span>
                        <h3>Mental Health &amp; Crisis Response</h3>
                        <p>Recognising crisis, suicide-prevention conversations, panic attacks, trauma.</p>
                    </div>
                </article>
                <article class="col-sm-6 col-lg-3">
                    <div class="pr-cat-card">
                        <span class="pr-cat-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l1.6-4.5A2 2 0 0 1 8.5 7h7a2 2 0 0 1 1.9 1.5L19 13v4h-2v-1H7v1H5v-4Z"/><circle cx="8" cy="16" r="1.2"/><circle cx="16" cy="16" r="1.2"/></svg>
                        </span>
                        <h3>Road &amp; Transport Safety</h3>
                        <p>Post-accident procedures, helping victims, tyre blowout, safe driving.</p>
                    </div>
                </article>
                <article class="col-sm-6 col-lg-3">
                    <div class="pr-cat-card">
                        <span class="pr-cat-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 20 10 7l4 6 2-3 5 10H3Z"/></svg>
                        </span>
                        <h3>Outdoor &amp; Wilderness Survival</h3>
                        <p>Shelter building, water purification, signalling, navigation without GPS.</p>
                    </div>
                </article>
                <article class="col-sm-6 col-lg-3">
                    <div class="pr-cat-card">
                        <span class="pr-cat-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3 20 6v5c0 5-3.5 8-8 10-4.5-2-8-5-8-10V6l8-3Z"/><path d="M9 12l2 2 4-4"/></svg>
                        </span>
                        <h3>Digital &amp; Personal Safety</h3>
                        <p>Phishing &amp; scams, data protection, cyberbullying, account recovery.</p>
                    </div>
                </article>
                <article class="col-sm-6 col-lg-3">
                    <div class="pr-cat-card">
                        <span class="pr-cat-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 11 12 4l9 7"/><path d="M5 10v10h14V10"/><path d="M10 20v-5h4v5"/></svg>
                        </span>
                        <h3>Home &amp; Everyday Safety</h3>
                        <p>Child-proofing, electrical safety, food safety, CO awareness, meds storage.</p>
                    </div>
                </article>
            </div>
            <div class="text-center mt-4">
                <a href="<%: ResolveUrl("~/Courses/Catalogue.aspx") %>" class="pr-btn-navy">Browse the full catalogue</a>
            </div>
        </div>
    </section>

    <%-- ============ ENDORSING PARTNERS ============ --%>
    <section class="pr-section pr-section-soft">
        <div class="container">
            <header class="text-center">
                <h2 class="pr-section-title">Endorsed by trusted agencies</h2>
                <p class="pr-section-sub">All partners are mock data for this academic project.</p>
            </header>
            <div class="d-flex flex-wrap justify-content-center gap-3 mt-1">
                <div class="pr-partner"><span class="pr-partner-seal">MOH</span> Ministry of Health</div>
                <div class="pr-partner"><span class="pr-partner-seal">BMB</span> BOMBA (Fire &amp; Rescue)</div>
                <div class="pr-partner"><span class="pr-partner-seal">APM</span> Civil Defence</div>
                <div class="pr-partner"><span class="pr-partner-seal">PDRM</span> Royal Malaysia Police</div>
                <div class="pr-partner"><span class="pr-partner-seal">CSM</span> CyberSecurity Malaysia</div>
            </div>
        </div>
    </section>

    <%-- ============ REGISTRY CTA ============ --%>
    <section class="pr-section">
        <div class="container">
            <div class="pr-registry-cta">
                <div class="row align-items-center gy-3">
                    <div class="col-lg-8">
                        <h2 class="fw-bold mb-2">National Recognised Responders Registry</h2>
                        <p class="mb-0">Search verified, government-recognised responders by name, field, or agency — each entry carries a scannable QR code that opens a live verification page.</p>
                    </div>
                    <div class="col-lg-4 text-lg-end">
                        <a href="<%: ResolveUrl("~/Registry/Index.aspx") %>" class="pr-btn-outline">Open the Registry</a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <%-- ============ TESTIMONIALS ============ --%>
    <section class="pr-section pr-section-soft">
        <div class="container">
            <header class="text-center">
                <h2 class="pr-section-title">Trusted by everyday responders</h2>
                <p class="pr-section-sub">Members who learned it, proved it, and now serve their communities.</p>
            </header>
            <div class="row g-4 mt-1">
                <div class="col-md-4">
                    <figure class="pr-quote">
                        <blockquote>"The CPR course was hands-on and the exam actually tested whether I understood it. My certificate has a QR code my employer scanned on the spot."</blockquote>
                        <figcaption>Aisha R. <span class="pr-role">— Community First Aider</span></figcaption>
                    </figure>
                </div>
                <div class="col-md-4">
                    <figure class="pr-quote">
                        <blockquote>"Earning the government-recognised badge after logged service hours made my volunteering count. Being in the public Registry means it."</blockquote>
                        <figcaption>Daniel T. <span class="pr-role">— Disaster Response Volunteer</span></figcaption>
                    </figure>
                </div>
                <div class="col-md-4">
                    <figure class="pr-quote">
                        <blockquote>"The points and vouchers kept me coming back to finish all three tiers. Best of all, the skills are genuinely useful."</blockquote>
                        <figcaption>Mei L. <span class="pr-role">— Workplace Safety Officer</span></figcaption>
                    </figure>
                </div>
            </div>
        </div>
    </section>

</asp:Content>