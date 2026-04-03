<?php include 'config.php'; ?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ACME IT Corp — Enterprise Technology Solutions</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;0,9..40,500;1,9..40,300&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --navy:   #0B1F3A;
            --navy2:  #122848;
            --blue:   #1A56DB;
            --blue2:  #1E63F5;
            --ice:    #EEF4FF;
            --slate:  #64748B;
            --light:  #F8FAFC;
            --white:  #FFFFFF;
            --border: #E2E8F0;
            --accent: #00C2FF;
            --text:   #1E293B;
        }

        html { scroll-behavior: smooth; }

        body {
            font-family: 'DM Sans', sans-serif;
            font-size: 16px;
            color: var(--text);
            background: var(--white);
            line-height: 1.6;
            overflow-x: hidden;
        }

        /* ── NAV ─────────────────────────────────────────────── */
        nav {
            position: fixed; top: 0; left: 0; right: 0; z-index: 100;
            background: rgba(11,31,58,0.97);
            backdrop-filter: blur(12px);
            border-bottom: 1px solid rgba(255,255,255,0.07);
            padding: 0 48px;
            height: 68px;
            display: flex; align-items: center; justify-content: space-between;
        }
        .nav-logo {
            font-family: 'Syne', sans-serif;
            font-weight: 800;
            font-size: 22px;
            color: var(--white);
            letter-spacing: -0.5px;
            text-decoration: none;
        }
        .nav-logo span { color: var(--accent); }
        .nav-links { display: flex; gap: 36px; align-items: center; list-style: none; }
        .nav-links a {
            color: rgba(255,255,255,0.72);
            text-decoration: none;
            font-size: 14px;
            font-weight: 400;
            letter-spacing: 0.2px;
            transition: color 0.2s;
        }
        .nav-links a:hover { color: var(--white); }
        .nav-cta {
            background: var(--blue);
            color: var(--white) !important;
            padding: 9px 22px;
            border-radius: 6px;
            font-weight: 500 !important;
            transition: background 0.2s !important;
        }
        .nav-cta:hover { background: var(--blue2) !important; }

        /* ── HERO ─────────────────────────────────────────────── */
        .hero {
            min-height: 100vh;
            background: var(--navy);
            display: flex; align-items: center;
            position: relative;
            overflow: hidden;
            padding: 120px 48px 80px;
        }
        .hero::before {
            content: '';
            position: absolute; inset: 0;
            background:
                radial-gradient(ellipse 80% 60% at 70% 50%, rgba(26,86,219,0.18) 0%, transparent 70%),
                radial-gradient(ellipse 40% 40% at 90% 20%, rgba(0,194,255,0.10) 0%, transparent 60%);
            pointer-events: none;
        }
        .hero-grid {
            position: absolute; inset: 0;
            background-image:
                linear-gradient(rgba(255,255,255,0.025) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255,255,255,0.025) 1px, transparent 1px);
            background-size: 60px 60px;
            pointer-events: none;
        }
        .hero-content { max-width: 1200px; margin: 0 auto; width: 100%; position: relative; z-index: 2; }
        .hero-eyebrow {
            display: inline-flex; align-items: center; gap: 8px;
            background: rgba(0,194,255,0.12);
            border: 1px solid rgba(0,194,255,0.25);
            color: var(--accent);
            font-size: 12px;
            font-weight: 500;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            padding: 6px 16px;
            border-radius: 100px;
            margin-bottom: 28px;
        }
        .hero-eyebrow::before {
            content: '';
            width: 6px; height: 6px;
            background: var(--accent);
            border-radius: 50%;
            animation: pulse 2s ease-in-out infinite;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50% { opacity: 0.5; transform: scale(0.8); }
        }
        .hero h1 {
            font-family: 'Syne', sans-serif;
            font-size: clamp(42px, 5.5vw, 72px);
            font-weight: 800;
            color: var(--white);
            line-height: 1.08;
            letter-spacing: -2px;
            margin-bottom: 28px;
            max-width: 800px;
        }
        .hero h1 em {
            font-style: normal;
            color: var(--accent);
        }
        .hero-sub {
            font-size: 18px;
            font-weight: 300;
            color: rgba(255,255,255,0.62);
            max-width: 520px;
            line-height: 1.7;
            margin-bottom: 48px;
        }
        .hero-actions { display: flex; gap: 16px; flex-wrap: wrap; }
        .btn-primary {
            background: var(--blue);
            color: var(--white);
            padding: 14px 32px;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 500;
            text-decoration: none;
            transition: background 0.2s, transform 0.15s;
            display: inline-block;
        }
        .btn-primary:hover { background: var(--blue2); transform: translateY(-1px); }
        .btn-ghost {
            background: rgba(255,255,255,0.07);
            color: var(--white);
            padding: 14px 32px;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 400;
            text-decoration: none;
            border: 1px solid rgba(255,255,255,0.14);
            transition: background 0.2s;
            display: inline-block;
        }
        .btn-ghost:hover { background: rgba(255,255,255,0.12); }
        .hero-stats {
            display: flex; gap: 48px;
            margin-top: 72px;
            padding-top: 48px;
            border-top: 1px solid rgba(255,255,255,0.08);
        }
        .stat-num {
            font-family: 'Syne', sans-serif;
            font-size: 36px;
            font-weight: 800;
            color: var(--white);
            letter-spacing: -1px;
        }
        .stat-num span { color: var(--accent); }
        .stat-label { font-size: 13px; color: rgba(255,255,255,0.45); margin-top: 4px; }

        /* ── LOGOS BAR ─────────────────────────────────────────── */
        .logos-bar {
            background: var(--light);
            border-top: 1px solid var(--border);
            border-bottom: 1px solid var(--border);
            padding: 28px 48px;
            display: flex; align-items: center; justify-content: center; gap: 64px;
            flex-wrap: wrap;
        }
        .logos-label { font-size: 12px; font-weight: 500; color: var(--slate); letter-spacing: 1px; text-transform: uppercase; }
        .logo-item {
            font-family: 'Syne', sans-serif;
            font-size: 16px;
            font-weight: 700;
            color: #B0BEC5;
            letter-spacing: -0.5px;
        }

        /* ── SECTIONS ─────────────────────────────────────────── */
        section { padding: 100px 48px; }
        .section-inner { max-width: 1200px; margin: 0 auto; }
        .section-tag {
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 2px;
            text-transform: uppercase;
            color: var(--blue);
            margin-bottom: 16px;
        }
        .section-title {
            font-family: 'Syne', sans-serif;
            font-size: clamp(30px, 3.5vw, 46px);
            font-weight: 800;
            color: var(--navy);
            line-height: 1.1;
            letter-spacing: -1.5px;
            margin-bottom: 20px;
        }
        .section-sub {
            font-size: 17px;
            font-weight: 300;
            color: var(--slate);
            max-width: 540px;
            line-height: 1.7;
            margin-bottom: 60px;
        }

        /* ── SERVICES GRID ─────────────────────────────────────── */
        .services { background: var(--white); }
        .services-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 24px;
        }
        .service-card {
            background: var(--light);
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 36px 32px;
            transition: box-shadow 0.2s, transform 0.2s, border-color 0.2s;
            position: relative;
            overflow: hidden;
        }
        .service-card::after {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 3px;
            background: var(--blue);
            transform: scaleX(0);
            transform-origin: left;
            transition: transform 0.3s;
        }
        .service-card:hover { box-shadow: 0 8px 32px rgba(0,0,0,0.08); transform: translateY(-3px); border-color: #C7D7F5; }
        .service-card:hover::after { transform: scaleX(1); }
        .service-icon {
            width: 48px; height: 48px;
            background: var(--ice);
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            margin-bottom: 24px;
            font-size: 22px;
        }
        .service-card h3 {
            font-family: 'Syne', sans-serif;
            font-size: 19px;
            font-weight: 700;
            color: var(--navy);
            margin-bottom: 12px;
            letter-spacing: -0.5px;
        }
        .service-card p { font-size: 14px; color: var(--slate); line-height: 1.7; }

        /* ── WHY US ─────────────────────────────────────────────── */
        .why { background: var(--navy); }
        .why .section-title { color: var(--white); }
        .why .section-sub { color: rgba(255,255,255,0.55); }
        .why .section-tag { color: var(--accent); }
        .why-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 2px; }
        .why-item {
            background: rgba(255,255,255,0.03);
            border: 1px solid rgba(255,255,255,0.06);
            padding: 40px 36px;
            transition: background 0.2s;
        }
        .why-item:hover { background: rgba(255,255,255,0.06); }
        .why-num {
            font-family: 'Syne', sans-serif;
            font-size: 48px;
            font-weight: 800;
            color: rgba(26,86,219,0.3);
            line-height: 1;
            margin-bottom: 16px;
            letter-spacing: -2px;
        }
        .why-item h3 {
            font-family: 'Syne', sans-serif;
            font-size: 20px;
            font-weight: 700;
            color: var(--white);
            margin-bottom: 12px;
            letter-spacing: -0.5px;
        }
        .why-item p { font-size: 14px; color: rgba(255,255,255,0.5); line-height: 1.75; }

        /* ── TEAM ─────────────────────────────────────────────── */
        .team { background: var(--light); }
        .team-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 24px; }
        .team-card {
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 32px 24px;
            text-align: center;
            transition: box-shadow 0.2s, transform 0.2s;
        }
        .team-card:hover { box-shadow: 0 8px 32px rgba(0,0,0,0.07); transform: translateY(-2px); }
        .team-avatar {
            width: 72px; height: 72px;
            border-radius: 50%;
            margin: 0 auto 20px;
            display: flex; align-items: center; justify-content: center;
            font-family: 'Syne', sans-serif;
            font-size: 24px;
            font-weight: 800;
            color: var(--white);
        }
        .team-card h4 {
            font-family: 'Syne', sans-serif;
            font-size: 16px;
            font-weight: 700;
            color: var(--navy);
            margin-bottom: 6px;
            letter-spacing: -0.3px;
        }
        .team-card .role { font-size: 13px; color: var(--slate); margin-bottom: 4px; }
        .team-card .dept {
            font-size: 11px;
            font-weight: 600;
            letter-spacing: 1px;
            text-transform: uppercase;
            color: var(--blue);
            background: var(--ice);
            display: inline-block;
            padding: 3px 10px;
            border-radius: 100px;
            margin-top: 8px;
        }

        /* ── CONTACT ─────────────────────────────────────────────── */
        .contact { background: var(--white); }
        .contact-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 80px; align-items: start; }
        .contact-info h2 {
            font-family: 'Syne', sans-serif;
            font-size: 36px;
            font-weight: 800;
            color: var(--navy);
            margin-bottom: 20px;
            letter-spacing: -1px;
        }
        .contact-info p { font-size: 15px; color: var(--slate); line-height: 1.75; margin-bottom: 32px; }
        .contact-detail {
            display: flex; align-items: flex-start; gap: 14px;
            margin-bottom: 20px;
        }
        .contact-detail-icon {
            width: 40px; height: 40px; min-width: 40px;
            background: var(--ice);
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            font-size: 18px;
        }
        .contact-detail-text { font-size: 14px; color: var(--slate); line-height: 1.6; }
        .contact-detail-text strong { color: var(--navy); display: block; font-size: 13px; margin-bottom: 2px; }
        .contact-form { background: var(--light); border: 1px solid var(--border); border-radius: 16px; padding: 40px; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; font-size: 13px; font-weight: 500; color: var(--navy); margin-bottom: 8px; }
        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%; padding: 11px 14px;
            border: 1px solid var(--border);
            border-radius: 8px;
            font-family: 'DM Sans', sans-serif;
            font-size: 14px;
            color: var(--text);
            background: var(--white);
            transition: border-color 0.2s, box-shadow 0.2s;
            outline: none;
        }
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            border-color: var(--blue);
            box-shadow: 0 0 0 3px rgba(26,86,219,0.1);
        }
        .form-group textarea { resize: vertical; min-height: 110px; }
        .form-submit {
            width: 100%;
            background: var(--blue);
            color: var(--white);
            border: none;
            padding: 13px 24px;
            border-radius: 8px;
            font-family: 'DM Sans', sans-serif;
            font-size: 15px;
            font-weight: 500;
            cursor: pointer;
            transition: background 0.2s;
        }
        .form-submit:hover { background: var(--blue2); }

        /* ── FOOTER ─────────────────────────────────────────────── */
        footer {
            background: var(--navy);
            padding: 60px 48px 32px;
            color: rgba(255,255,255,0.45);
        }
        .footer-inner { max-width: 1200px; margin: 0 auto; }
        .footer-top {
            display: grid; grid-template-columns: 2fr 1fr 1fr 1fr;
            gap: 48px; margin-bottom: 48px;
            padding-bottom: 48px;
            border-bottom: 1px solid rgba(255,255,255,0.07);
        }
        .footer-brand p { font-size: 13px; line-height: 1.7; margin-top: 12px; max-width: 260px; }
        .footer-col h5 {
            font-family: 'Syne', sans-serif;
            font-size: 13px;
            font-weight: 700;
            color: var(--white);
            letter-spacing: 0.5px;
            margin-bottom: 16px;
        }
        .footer-col ul { list-style: none; }
        .footer-col ul li { margin-bottom: 10px; }
        .footer-col ul li a { color: rgba(255,255,255,0.45); text-decoration: none; font-size: 13px; transition: color 0.2s; }
        .footer-col ul li a:hover { color: var(--white); }
        .footer-bottom { display: flex; justify-content: space-between; align-items: center; font-size: 12px; }
        .footer-bottom a { color: rgba(255,255,255,0.45); text-decoration: none; }
        .footer-bottom a:hover { color: var(--white); }
    </style>
</head>
<body>

<!-- NAV -->
<nav>
    <a href="/" class="nav-logo">ACME <span>IT</span> Corp</a>
    <ul class="nav-links">
        <li><a href="#services">Services</a></li>
        <li><a href="#why">Why Us</a></li>
        <li><a href="#team">Team</a></li>
        <li><a href="#contact">Contact</a></li>
        <li><a href="/admin/login.php" class="nav-cta">Client Portal</a></li>
    </ul>
</nav>

<!-- HERO -->
<section class="hero">
    <div class="hero-grid"></div>
    <div class="hero-content">
        <div class="hero-eyebrow">Enterprise IT Solutions</div>
        <h1>Technology that <em>drives</em> your business forward</h1>
        <p class="hero-sub">ACME IT Corp delivers end-to-end managed services, cybersecurity, and cloud infrastructure for mid-market enterprises across the region.</p>
        <div class="hero-actions">
            <a href="#contact" class="btn-primary">Request a Consultation</a>
            <a href="#services" class="btn-ghost">Explore Services</a>
        </div>
        <div class="hero-stats">
            <div>
                <div class="stat-num">200<span>+</span></div>
                <div class="stat-label">Enterprise Clients</div>
            </div>
            <div>
                <div class="stat-num">99<span>.9%</span></div>
                <div class="stat-label">Uptime SLA</div>
            </div>
            <div>
                <div class="stat-num">18<span>yr</span></div>
                <div class="stat-label">In Business</div>
            </div>
            <div>
                <div class="stat-num">24<span>/7</span></div>
                <div class="stat-label">Support Desk</div>
            </div>
        </div>
    </div>
</section>

<!-- LOGOS BAR -->
<div class="logos-bar">
    <span class="logos-label">Trusted by</span>
    <span class="logo-item">Globex Corp</span>
    <span class="logo-item">Initech LLC</span>
    <span class="logo-item">Umbrella Ltd</span>
    <span class="logo-item">Vandelay Ind.</span>
    <span class="logo-item">CyberDyne Systems</span>
</div>

<!-- SERVICES -->
<section class="services" id="services">
    <div class="section-inner">
        <div class="section-tag">What We Do</div>
        <h2 class="section-title">Full-spectrum IT services,<br>under one roof</h2>
        <p class="section-sub">From day-to-day helpdesk support to enterprise cloud migrations, we cover every layer of your technology stack.</p>
        <div class="services-grid">
            <div class="service-card">
                <div class="service-icon">&#9729;</div>
                <h3>Cloud Infrastructure</h3>
                <p>Design, migration, and ongoing management of cloud environments across AWS, Azure, and on-premise hybrid setups. We handle the complexity so you don't have to.</p>
            </div>
            <div class="service-card">
                <div class="service-icon">&#128274;</div>
                <h3>Cybersecurity</h3>
                <p>Penetration testing, vulnerability assessments, SOC monitoring, and incident response. Our security team keeps your perimeter hardened and your data protected.</p>
            </div>
            <div class="service-card">
                <div class="service-icon">&#128187;</div>
                <h3>Managed IT Support</h3>
                <p>Flat-rate helpdesk, remote monitoring, patch management, and on-site technician dispatch. Predictable costs, enterprise-grade support.</p>
            </div>
            <div class="service-card">
                <div class="service-icon">&#128101;</div>
                <h3>IT Consulting</h3>
                <p>Strategic technology planning, vendor selection, and IT roadmapping aligned to your business goals. Our vCIOs have worked with companies at every growth stage.</p>
            </div>
            <div class="service-card">
                <div class="service-icon">&#128225;</div>
                <h3>Network & Connectivity</h3>
                <p>LAN/WAN design, SD-WAN deployment, VPN configuration, and carrier management. Reliable connectivity is the backbone of everything we build.</p>
            </div>
            <div class="service-card">
                <div class="service-icon">&#128190;</div>
                <h3>Backup & DR</h3>
                <p>Automated backup solutions, disaster recovery planning, and tested failover procedures. When something goes wrong, your data comes back — fast.</p>
            </div>
        </div>
    </div>
</section>

<!-- WHY US -->
<section class="why" id="why">
    <div class="section-inner">
        <div class="section-tag">Why ACME IT Corp</div>
        <h2 class="section-title">Built different.<br>Proven reliable.</h2>
        <p class="section-sub">We've been doing this for 18 years. Here's what that actually means for you.</p>
        <div class="why-grid">
            <div class="why-item">
                <div class="why-num">01</div>
                <h3>No ticket queues. Real humans.</h3>
                <p>When you call our support line, you reach a certified technician — not a chatbot, not a tier-1 script reader. Average first response under 4 minutes.</p>
            </div>
            <div class="why-item">
                <div class="why-num">02</div>
                <h3>Security-first by default</h3>
                <p>Every engagement starts with a security baseline review. We identify risk before it becomes a breach, and we document everything for your compliance team.</p>
            </div>
            <div class="why-item">
                <div class="why-num">03</div>
                <h3>Fixed-price contracts</h3>
                <p>No surprise invoices, no hourly overages. Our managed service agreements cover everything in scope, so your IT budget stays predictable month over month.</p>
            </div>
            <div class="why-item">
                <div class="why-num">04</div>
                <h3>Local presence, enterprise scale</h3>
                <p>We're headquartered here, with technicians across the region. You get on-site response times that national MSPs can't match, backed by enterprise tooling.</p>
            </div>
        </div>
    </div>
</section>

<!-- TEAM -->
<section class="team" id="team">
    <div class="section-inner">
        <div class="section-tag">Our People</div>
        <h2 class="section-title">The team behind<br>your technology</h2>
        <p class="section-sub">Certified professionals with real-world experience across every discipline we offer.</p>
        <div class="team-grid">
            <div class="team-card">
                <div class="team-avatar" style="background: linear-gradient(135deg,#1A56DB,#00C2FF);">AB</div>
                <h4>Alice Brown</h4>
                <div class="role">IT Specialist</div>
                <div class="dept">IT</div>
            </div>
            <div class="team-card">
                <div class="team-avatar" style="background: linear-gradient(135deg,#0B1F3A,#1A56DB);">BB</div>
                <h4>Bob Barker</h4>
                <div class="role">Director of Customer Success</div>
                <div class="dept">Sales</div>
            </div>
            <div class="team-card">
                <div class="team-avatar" style="background: linear-gradient(135deg,#1A56DB,#534AB7);">EJ</div>
                <h4>Eve Johnson</h4>
                <div class="role">Tech Lead</div>
                <div class="dept">IT</div>
            </div>
            <div class="team-card">
                <div class="team-avatar" style="background: linear-gradient(135deg,#0F6E56,#1D9E75);">CR</div>
                <h4>Claire Redfield</h4>
                <div class="role">Accountant</div>
                <div class="dept">Finance</div>
            </div>
            <div class="team-card">
                <div class="team-avatar" style="background: linear-gradient(135deg,#993556,#D4537E);">MM</div>
                <h4>Mallory Martinez</h4>
                <div class="role">IT Security</div>
                <div class="dept">IT</div>
            </div>
            <div class="team-card">
                <div class="team-avatar" style="background: linear-gradient(135deg,#854F0B,#EF9F27);">MM</div>
                <h4>Mitch Marcus</h4>
                <div class="role">Systems Administrator</div>
                <div class="dept">IT</div>
            </div>
            <div class="team-card">
                <div class="team-avatar" style="background: linear-gradient(135deg,#185FA5,#378ADD);">FL</div>
                <h4>Fong Ling</h4>
                <div class="role">Web Developer</div>
                <div class="dept">IT</div>
            </div>
            <div class="team-card" style="background: var(--navy); border-color: rgba(255,255,255,0.07); display:flex; flex-direction:column; align-items:center; justify-content:center;">
                <div style="font-size:28px; margin-bottom:12px;">&#43;</div>
                <h4 style="color:rgba(255,255,255,0.7); font-size:14px;">We're hiring</h4>
                <div class="role" style="color:rgba(255,255,255,0.4); font-size:12px;">Open positions available</div>
                <a href="#contact" style="color:var(--accent); font-size:12px; margin-top:10px; text-decoration:none;">View roles &rarr;</a>
            </div>
        </div>
    </div>
</section>

<!-- CONTACT -->
<section class="contact" id="contact">
    <div class="section-inner">
        <div class="contact-grid">
            <div class="contact-info">
                <div class="section-tag">Get In Touch</div>
                <h2>Let's talk about your IT needs</h2>
                <p>Whether you're looking to outsource your entire IT department or just need help with a specific project, we're ready to have a real conversation about what makes sense for your business.</p>
                <div class="contact-detail">
                    <div class="contact-detail-icon">&#128205;</div>
                    <div class="contact-detail-text">
                        <strong>Address</strong>
                        1200 Commerce Drive, Suite 400<br>Birmingham, AL 35203
                    </div>
                </div>
                <div class="contact-detail">
                    <div class="contact-detail-icon">&#128222;</div>
                    <div class="contact-detail-text">
                        <strong>Phone</strong>
                        (205) 555-0142
                    </div>
                </div>
                <div class="contact-detail">
                    <div class="contact-detail-icon">&#9993;</div>
                    <div class="contact-detail-text">
                        <strong>Email</strong>
                        info@acmecorp.internal<br>
                        support@acmecorp.internal
                    </div>
                </div>
                <div class="contact-detail">
                    <div class="contact-detail-icon">&#128336;</div>
                    <div class="contact-detail-text">
                        <strong>Support Hours</strong>
                        24/7 for managed clients<br>
                        Mon–Fri 8am–6pm for new inquiries
                    </div>
                </div>
            </div>
            <div class="contact-form">
                <h3 style="font-family:'Syne',sans-serif; font-size:20px; font-weight:700; color:var(--navy); margin-bottom:24px; letter-spacing:-0.5px;">Send us a message</h3>
                <div class="form-row">
                    <div class="form-group">
                        <label>First Name</label>
                        <input type="text" placeholder="John">
                    </div>
                    <div class="form-group">
                        <label>Last Name</label>
                        <input type="text" placeholder="Smith">
                    </div>
                </div>
                <div class="form-group">
                    <label>Work Email</label>
                    <input type="email" placeholder="john@company.com">
                </div>
                <div class="form-group">
                    <label>Company</label>
                    <input type="text" placeholder="Your company name">
                </div>
                <div class="form-group">
                    <label>Service Interest</label>
                    <select>
                        <option>Select a service...</option>
                        <option>Managed IT Support</option>
                        <option>Cybersecurity</option>
                        <option>Cloud Infrastructure</option>
                        <option>IT Consulting</option>
                        <option>Network & Connectivity</option>
                        <option>Backup & DR</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Message</label>
                    <textarea placeholder="Tell us about your current setup and what you're looking to achieve..."></textarea>
                </div>
                <button class="form-submit">Send Message &rarr;</button>
            </div>
        </div>
    </div>
</section>

<!-- FOOTER -->
<footer>
    <div class="footer-inner">
        <div class="footer-top">
            <div class="footer-brand">
                <div class="nav-logo" style="font-size:20px;">ACME <span style="color:var(--accent);">IT</span> Corp</div>
                <p>Enterprise technology solutions for businesses that can't afford downtime. Serving the region since 2006.</p>
            </div>
            <div class="footer-col">
                <h5>Services</h5>
                <ul>
                    <li><a href="#services">Cloud Infrastructure</a></li>
                    <li><a href="#services">Cybersecurity</a></li>
                    <li><a href="#services">Managed IT</a></li>
                    <li><a href="#services">IT Consulting</a></li>
                </ul>
            </div>
            <div class="footer-col">
                <h5>Company</h5>
                <ul>
                    <li><a href="#team">Our Team</a></li>
                    <li><a href="#why">Why ACME</a></li>
                    <li><a href="#contact">Contact</a></li>
                    <li><a href="/admin/login.php">Client Portal</a></li>
                </ul>
            </div>
            <div class="footer-col">
                <h5>Legal</h5>
                <ul>
                    <li><a href="#">Privacy Policy</a></li>
                    <li><a href="#">Terms of Service</a></li>
                    <li><a href="#">SLA Agreement</a></li>
                    <li><a href="#">Cookie Policy</a></li>
                </ul>
            </div>
        </div>
        <div class="footer-bottom">
            <span>&copy; 2024 ACME IT Corp. All rights reserved.</span>
            <span>Birmingham, AL &nbsp;&middot;&nbsp; <a href="mailto:info@acmecorp.internal">info@acmecorp.internal</a></span>
        </div>
    </div>
</footer>

</body>
</html>
