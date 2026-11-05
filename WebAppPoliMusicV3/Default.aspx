<%@ Page Title="Inicio" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="WebAppPoliMusicV3._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <style>
        :root {
            --bg: #0d0a1a;
            --panel: #161233;
            --panel-2: #1f1a3d;
            --line: rgba(255, 255, 255, 0.08);
            --text: #eef0ff;
            --muted: #9990c0;
            --purple: #7b3ff2;
            --purple-light: #9d5cff;
            --purple-deep: #5a1ed0;
            --blue: #3a6df0;
        }
        .home-wrap {
            min-height: calc(100vh - 120px);
            background: linear-gradient(180deg, #1a1430 0%, #0d0a1a 400px);
            padding: 0;
        }
        .home-hero {
            padding: 48px 40px 40px;
            display: flex;
            align-items: center;
            gap: 28px;
        }
        .hero-cover {
            width: 180px;
            height: 180px;
            border-radius: 14px;
            background: linear-gradient(140deg, var(--purple-light) 0%, var(--purple-deep) 55%, #1a0d40 100%);
            display: grid;
            place-items: center;
            box-shadow: 0 18px 44px rgba(123, 63, 242, 0.35);
            flex: none;
        }
        .hero-cover span { font-size: 68px; color: rgba(255, 255, 255, 0.9); }
        .hero-eyebrow {
            margin: 0 0 8px;
            font-size: 12px;
            letter-spacing: 2px;
            text-transform: uppercase;
            font-weight: 700;
            color: var(--muted);
        }
        .hero-title {
            margin: 0;
            font-size: clamp(32px, 5vw, 56px);
            font-weight: 800;
            letter-spacing: -2px;
            line-height: 1;
        }
        .hero-sub {
            margin: 14px 0 0;
            font-size: 15px;
            color: var(--muted);
            font-weight: 600;
        }
        .hero-sub strong { color: var(--purple-light); }
        .home-actions { padding: 0 40px 40px; }
        .card-row { display: flex; gap: 20px; flex-wrap: wrap; margin-top: 20px; }
        .quick-card {
            flex: 1;
            min-width: 200px;
            background: var(--panel);
            border: 1px solid var(--line);
            border-radius: 12px;
            padding: 24px;
            text-decoration: none;
            color: var(--text);
            transition: background .15s ease, transform .12s ease;
            display: block;
        }
        .quick-card:hover { background: var(--panel-2); transform: scale(1.02); }
        .quick-card .qc-icon {
            width: 48px;
            height: 48px;
            border-radius: 10px;
            background: linear-gradient(135deg, var(--purple), var(--blue));
            display: grid;
            place-items: center;
            margin-bottom: 16px;
        }
        .quick-card .qc-icon svg { width: 24px; height: 24px; }
        .quick-card h3 { margin: 0 0 6px; font-size: 18px; font-weight: 700; }
        .quick-card p { margin: 0; font-size: 13px; color: var(--muted); }
        .btn-go {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: linear-gradient(135deg, var(--purple), var(--blue));
            color: #fff;
            border: 0;
            border-radius: 999px;
            padding: 13px 30px;
            font-size: 15px;
            font-weight: 700;
            font-family: inherit;
            cursor: pointer;
            text-decoration: none;
            transition: transform .12s ease;
        }
        .btn-go:hover { transform: scale(1.04); }
    </style>

    <div class="home-wrap">
        <div class="home-hero">
            <div class="hero-cover"><span>&#9835;</span></div>
            <div>
                <p class="hero-eyebrow">Bienvenido a PoliMusic</p>
                <h1 class="hero-title">Hola, <asp:Label ID="lblUserName" runat="server" Text="usuario"></asp:Label></h1>
                <p class="hero-sub">Tu biblioteca musical te espera. Explora tus canciones, descubre nueva musica y disfruta del ritmo.</p>
                <div style="margin-top: 24px;">
                    <a class="btn-go" href="Songs.aspx">Ir a mis canciones &rarr;</a>
                </div>
            </div>
        </div>

        <div class="home-actions">
            <div class="card-row">
                <a class="quick-card" href="Songs.aspx">
                    <div class="qc-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round">
                            <path d="M9 18V5l12-2v13" /><circle cx="6" cy="18" r="3" /><circle cx="18" cy="16" r="3" />
                        </svg>
                    </div>
                    <h3>Canciones</h3>
                    <p>Explora y reproduce tu biblioteca completa de musica.</p>
                </a>
                <a class="quick-card" href="About.aspx">
                    <div class="qc-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round">
                            <circle cx="12" cy="12" r="10" /><path d="M12 16v-4M12 8h.01" />
                        </svg>
                    </div>
                    <h3>Acerca de</h3>
                    <p>Conoce mas sobre este proyecto y su tecnologia.</p>
                </a>
                <a class="quick-card" href="Contact.aspx">
                    <div class="qc-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round">
                            <path d="M4 4h16v16H4z" /><path d="m22 6-10 7L2 6" />
                        </svg>
                    </div>
                    <h3>Contacto</h3>
                    <p>Ponte en contacto con el equipo del proyecto.</p>
                </a>
            </div>
        </div>
    </div>

</asp:Content>
