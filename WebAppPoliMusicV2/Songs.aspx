<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Songs.aspx.cs" Inherits="WebAppPoliMusicV2.Songs" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>PoliMusic · Canciones</title>
    <style type="text/css">
        /* ============================================================
           PoliMusic - Modulo de canciones
           Estetica tipo Spotify sobre una paleta azul.
           ============================================================ */

        :root {
            --bg: #060b15;
            --panel: #0b1424;
            --panel-2: #122036;
            --panel-3: #16263f;
            --line: rgba(255, 255, 255, 0.07);
            --text: #eef4ff;
            --muted: #8ba1c0;
            --blue: #2e7dff;
            --blue-light: #5c9dff;
            --blue-deep: #1b5fe0;
            --danger: #ff5c7a;
        }

        * { box-sizing: border-box; }

        html, body {
            height: 100%;
            margin: 0;
        }

        body {
            background: var(--bg);
            color: var(--text);
            font-family: "Segoe UI", "Helvetica Neue", Arial, sans-serif;
            font-size: 14px;
            overflow: hidden;
        }

        a { color: inherit; text-decoration: none; }

        /* ---------- Estructura general ---------- */
        .shell {
            display: grid;
            grid-template-columns: 260px 1fr;
            gap: 8px;
            height: calc(100vh - 100px);
            padding: 8px;
        }

        /* ---------- Barra lateral ---------- */
        .sidebar {
            background: #04070d;
            border-radius: 12px;
            padding: 18px 12px;
            display: flex;
            flex-direction: column;
            gap: 6px;
            overflow-y: auto;
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 4px 10px 20px;
            font-size: 20px;
            font-weight: 800;
            letter-spacing: -0.4px;
        }

        .logo-mark {
            width: 34px;
            height: 34px;
            border-radius: 50%;
            background: linear-gradient(140deg, var(--blue-light), var(--blue-deep));
            display: grid;
            place-items: center;
            box-shadow: 0 0 18px rgba(46, 125, 255, 0.45);
        }

        .logo-mark svg { width: 19px; height: 19px; }

        .nav { display: flex; flex-direction: column; gap: 2px; }

        .nav-item {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 11px 12px;
            border-radius: 8px;
            color: var(--muted);
            font-weight: 700;
            transition: color .15s ease, background .15s ease;
        }

        .nav-item:hover { color: var(--text); }

        .nav-item.is-active {
            background: rgba(46, 125, 255, 0.14);
            color: #ffffff;
        }

        .nav-item svg { width: 21px; height: 21px; flex: none; }

        .side-section {
            margin-top: 26px;
            padding: 0 12px;
            font-size: 11px;
            letter-spacing: 1.6px;
            text-transform: uppercase;
            color: var(--muted);
            font-weight: 700;
        }

        .pl-list {
            margin-top: 12px;
            display: flex;
            flex-direction: column;
            gap: 2px;
        }

        .pl-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 7px 12px;
            border-radius: 8px;
            color: var(--muted);
        }

        .pl-item:hover { background: rgba(255, 255, 255, 0.05); color: var(--text); }

        .pl-thumb {
            width: 42px;
            height: 42px;
            border-radius: 6px;
            flex: none;
            display: grid;
            place-items: center;
            font-size: 15px;
            color: rgba(255, 255, 255, 0.85);
            background: linear-gradient(135deg, #1f4b96, #0a1c38);
        }

        .pl-item:nth-child(2) .pl-thumb { background: linear-gradient(135deg, #2e7dff, #10275a); }
        .pl-item:nth-child(3) .pl-thumb { background: linear-gradient(135deg, #4a6fa8, #0d1a30); }
        .pl-item:nth-child(4) .pl-thumb { background: linear-gradient(135deg, #1b5fe0, #071227); }
        .pl-item:nth-child(5) .pl-thumb { background: linear-gradient(135deg, #6ea4ff, #14294c); }

        .pl-name { font-size: 13.5px; font-weight: 600; }

        .side-note {
            margin-top: auto;
            padding: 16px 12px 4px;
            font-size: 11px;
            color: rgba(139, 161, 192, 0.65);
            line-height: 1.5;
        }

        /* ---------- Panel principal ---------- */
        .main {
            background: linear-gradient(180deg, #14294a 0%, #0b1424 340px, #0b1424 100%);
            border-radius: 12px;
            overflow-y: auto;
            position: relative;
        }

        .topbar {
            position: sticky;
            top: 0;
            z-index: 10;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;
            padding: 14px 26px;
            background: rgba(11, 20, 36, 0.78);
            backdrop-filter: blur(14px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.04);
        }

        .search {
            display: flex;
            align-items: center;
            gap: 8px;
            background: #0a1220;
            border: 1px solid var(--line);
            border-radius: 999px;
            padding: 4px 4px 4px 14px;
            width: min(460px, 60%);
        }

        .search:focus-within { border-color: rgba(46, 125, 255, 0.65); }

        .search svg { width: 17px; height: 17px; color: var(--muted); flex: none; }

        .search-input {
            flex: 1;
            min-width: 0;
            background: transparent;
            border: 0;
            outline: 0;
            color: var(--text);
            font-size: 13.5px;
            padding: 8px 0;
            font-family: inherit;
        }

        .search-input::placeholder { color: rgba(139, 161, 192, 0.75); }

        .search-btn {
            border: 0;
            background: var(--blue);
            color: #fff;
            font-weight: 700;
            font-size: 12.5px;
            padding: 8px 18px;
            border-radius: 999px;
            cursor: pointer;
            font-family: inherit;
        }

        .search-btn:hover { background: var(--blue-light); }

        .topbar-right { display: flex; align-items: center; gap: 12px; }

        .user-chip {
            display: flex;
            align-items: center;
            gap: 9px;
            background: #0a1220;
            border: 1px solid var(--line);
            border-radius: 999px;
            padding: 4px 14px 4px 4px;
            font-size: 12.5px;
            font-weight: 600;
            color: var(--muted);
        }

        .user-chip .avatar {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            background: linear-gradient(140deg, var(--blue-light), var(--blue-deep));
            display: grid;
            place-items: center;
            font-size: 13px;
            color: #fff;
            flex: 0 0 auto;
        }

        /* Nombre del usuario logueado: si es muy largo se recorta con puntos suspensivos */
        .user-chip .user-name {
            display: inline-block;
            max-width: 190px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            vertical-align: middle;
        }

        .chip-link {
            font-size: 12.5px;
            font-weight: 700;
            color: var(--muted);
            padding: 9px 16px;
            border-radius: 999px;
            border: 1px solid var(--line);
        }

        .chip-link:hover { color: #fff; border-color: rgba(255, 255, 255, 0.35); }

        /* ---------- Encabezado tipo hero ---------- */
        .hero {
            display: flex;
            align-items: flex-end;
            gap: 26px;
            padding: 34px 26px 26px;
        }

        .hero-cover {
            width: 178px;
            height: 178px;
            border-radius: 10px;
            background: linear-gradient(140deg, #3b8bff 0%, #14439c 55%, #0a1c3c 100%);
            display: grid;
            place-items: center;
            box-shadow: 0 18px 40px rgba(0, 0, 0, 0.55);
            flex: none;
        }

        .hero-cover span {
            font-size: 62px;
            color: rgba(255, 255, 255, 0.9);
            line-height: 1;
        }

        .eyebrow {
            margin: 0 0 10px;
            font-size: 11px;
            letter-spacing: 2px;
            text-transform: uppercase;
            font-weight: 700;
            color: var(--muted);
        }

        .hero h1 {
            margin: 0;
            font-size: clamp(34px, 5vw, 62px);
            font-weight: 800;
            letter-spacing: -2.2px;
            line-height: 1;
        }

        .hero-meta {
            margin: 14px 0 0;
            font-size: 13px;
            color: var(--muted);
            font-weight: 600;
        }

        .hero-meta .dot { margin: 0 8px; opacity: .6; }

        .hero-actions {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-top: 22px;
        }

        /* ---------- Botones ---------- */
        .btn-play {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: var(--blue);
            color: #fff;
            border: 0;
            border-radius: 999px;
            padding: 12px 28px;
            font-size: 14px;
            font-weight: 700;
            font-family: inherit;
            cursor: pointer;
            transition: transform .12s ease, background .15s ease;
        }

        .btn-play:hover { background: var(--blue-light); transform: scale(1.04); }

        .ico-tri {
            width: 0;
            height: 0;
            border-left: 10px solid #fff;
            border-top: 6px solid transparent;
            border-bottom: 6px solid transparent;
        }

        .btn-ghost {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: transparent;
            color: var(--text);
            border: 1px solid rgba(255, 255, 255, 0.28);
            border-radius: 999px;
            padding: 11px 22px;
            font-size: 13.5px;
            font-weight: 700;
            cursor: pointer;
            transition: border-color .15s ease, background .15s ease;
        }

        .btn-ghost:hover { border-color: #fff; background: rgba(255, 255, 255, 0.06); }

        /* ---------- Lista de canciones ---------- */
        .list-wrap { padding: 0 12px 40px; }

        .list-head {
            display: grid;
            grid-template-columns: 48px minmax(0, 1.7fr) minmax(0, 1fr) 140px 150px;
            gap: 16px;
            align-items: center;
            padding: 0 12px 10px;
            margin: 0 0 8px;
            border-bottom: 1px solid var(--line);
            color: var(--muted);
            font-size: 11px;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            font-weight: 700;
        }

        .row {
            display: grid;
            grid-template-columns: 48px minmax(0, 1.7fr) minmax(0, 1fr) 140px 150px;
            gap: 16px;
            align-items: center;
            padding: 8px 12px;
            border-radius: 8px;
            transition: background .12s ease;
        }

        .row:hover { background: rgba(255, 255, 255, 0.06); }

        .row.is-playing { background: rgba(46, 125, 255, 0.12); }
        .row.is-playing .t-name { color: var(--blue-light); }

        .cell-num {
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 34px;
        }

        .idx {
            color: var(--muted);
            font-variant-numeric: tabular-nums;
            font-size: 13px;
        }

        .play-mini {
            display: none;
            position: relative;
            width: 30px;
            height: 30px;
            border-radius: 50%;
            background: #ffffff;
        }

        .play-mini::after {
            content: "";
            position: absolute;
            left: 11px;
            top: 9px;
            width: 0;
            height: 0;
            border-left: 10px solid #0a1220;
            border-top: 6px solid transparent;
            border-bottom: 6px solid transparent;
        }

        .row:hover .idx { display: none; }
        .row:hover .play-mini { display: block; }

        .cell-title {
            display: flex;
            align-items: center;
            gap: 14px;
            min-width: 0;
        }

        .thumb {
            width: 44px;
            height: 44px;
            border-radius: 6px;
            flex: none;
            display: grid;
            place-items: center;
            color: rgba(255, 255, 255, 0.9);
            font-size: 17px;
            background: linear-gradient(135deg, #2e7dff, #0b2a6b);
        }

        .row:nth-child(4n) .thumb { background: linear-gradient(135deg, #4a7bd0, #0e1f3c); }
        .row:nth-child(4n+1) .thumb { background: linear-gradient(135deg, #1b5fe0, #08152c); }
        .row:nth-child(4n+2) .thumb { background: linear-gradient(135deg, #6ea4ff, #14294c); }

        .titles { display: flex; flex-direction: column; gap: 4px; min-width: 0; }

        .t-name {
            font-size: 14.5px;
            font-weight: 600;
            color: var(--text);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .t-artist {
            font-size: 12.5px;
            color: var(--muted);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .cell-album {
            color: var(--muted);
            font-size: 13px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .cell-plays {
            color: var(--muted);
            font-size: 13px;
            font-variant-numeric: tabular-nums;
        }

        .cell-actions {
            display: flex;
            gap: 8px;
            justify-content: flex-end;
            opacity: 0;
            transition: opacity .12s ease;
        }

        .row:hover .cell-actions { opacity: 1; }

        .act {
            font-size: 12px;
            font-weight: 700;
            color: var(--muted);
            border: 1px solid var(--line);
            border-radius: 999px;
            padding: 6px 13px;
            cursor: pointer;
        }

        .act:hover { color: #fff; border-color: rgba(255, 255, 255, 0.45); }

        .act-danger:hover { color: var(--danger); border-color: rgba(255, 92, 122, 0.6); }

        /* ---------- Estado vacio ---------- */
        .empty {
            margin: 10px 24px 40px;
            padding: 48px 24px;
            border: 1px dashed rgba(255, 255, 255, 0.14);
            border-radius: 14px;
            text-align: center;
        }

        .empty-title { margin: 0 0 8px; font-size: 18px; font-weight: 700; }
        .empty-sub { margin: 0; color: var(--muted); font-size: 13.5px; }

        /* ---------- Reproductor inferior ---------- */
        .player {
            position: fixed;
            left: 0;
            right: 0;
            bottom: 0;
            height: 92px;
            display: grid;
            grid-template-columns: 1fr minmax(320px, 2fr) 1fr;
            align-items: center;
            gap: 20px;
            padding: 0 22px;
            background: rgba(4, 7, 13, 0.97);
            border-top: 1px solid var(--line);
            backdrop-filter: blur(14px);
            z-index: 30;
        }

        .now { display: flex; align-items: center; gap: 13px; min-width: 0; }

        .now-cover {
            width: 52px;
            height: 52px;
            border-radius: 6px;
            flex: none;
            display: grid;
            place-items: center;
            font-size: 19px;
            color: rgba(255, 255, 255, 0.9);
            background: linear-gradient(135deg, #1b5fe0, #08152c);
        }

        .now-meta { display: flex; flex-direction: column; gap: 4px; min-width: 0; }

        .now-title {
            font-size: 13.5px;
            font-weight: 700;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .now-artist {
            font-size: 12px;
            color: var(--muted);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .center { display: flex; flex-direction: column; align-items: center; gap: 9px; }

        .controls { display: flex; align-items: center; gap: 18px; }

        .ctl {
            background: transparent;
            border: 0;
            color: var(--muted);
            cursor: pointer;
            padding: 0;
            display: grid;
            place-items: center;
            width: 26px;
            height: 26px;
        }

        .ctl:hover { color: #fff; }

        .ctl svg { width: 18px; height: 18px; }

        .ctl-main {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            background: #ffffff;
            color: #0a1220;
        }

        .ctl-main:hover { background: #ffffff; transform: scale(1.05); }

        .ctl-main .ico-play {
            width: 0;
            height: 0;
            margin-left: 3px;
            border-left: 12px solid #0a1220;
            border-top: 7px solid transparent;
            border-bottom: 7px solid transparent;
        }

        .ctl-main .ico-pause {
            display: none;
            width: 12px;
            height: 14px;
            border-left: 4px solid #0a1220;
            border-right: 4px solid #0a1220;
        }

        .ctl-main.is-playing .ico-play { display: none; }
        .ctl-main.is-playing .ico-pause { display: block; }

        .progress {
            display: flex;
            align-items: center;
            gap: 10px;
            width: 100%;
            max-width: 520px;
        }

        .time {
            font-size: 11px;
            color: var(--muted);
            font-variant-numeric: tabular-nums;
            width: 34px;
            text-align: center;
            flex: none;
        }

        .bar {
            flex: 1;
            height: 4px;
            border-radius: 2px;
            background: rgba(255, 255, 255, 0.18);
            cursor: pointer;
        }

        .bar:hover .bar-fill { background: var(--blue-light); }

        .bar-fill {
            height: 100%;
            width: 0;
            border-radius: 2px;
            background: var(--blue);
            transition: width .1s linear;
        }

        .player-right {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 16px;
        }

        .plays-chip {
            font-size: 11.5px;
            font-weight: 700;
            color: var(--muted);
            border: 1px solid var(--line);
            border-radius: 999px;
            padding: 7px 13px;
            white-space: nowrap;
        }

        .vol { width: 96px; accent-color: var(--blue); cursor: pointer; }

        /* ---------- Modal del formulario ---------- */
        .modal-backdrop {
            display: none;
            position: fixed;
            inset: 0;
            z-index: 60;
            background: rgba(3, 6, 12, 0.82);
            backdrop-filter: blur(6px);
            align-items: center;
            justify-content: center;
            padding: 24px;
        }

        .modal-backdrop.is-open { display: flex; }

        .modal {
            width: min(520px, 100%);
            max-height: 90vh;
            overflow-y: auto;
            background: var(--panel-2);
            border: 1px solid rgba(255, 255, 255, 0.09);
            border-radius: 16px;
            padding: 26px 28px 24px;
            box-shadow: 0 30px 70px rgba(0, 0, 0, 0.6);
        }

        .modal-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
        }

        .modal-head h2 { margin: 0; font-size: 22px; font-weight: 800; letter-spacing: -0.6px; }

        .modal-x {
            font-size: 12px;
            font-weight: 700;
            color: var(--muted);
            border: 1px solid var(--line);
            border-radius: 999px;
            padding: 6px 13px;
        }

        .modal-x:hover { color: #fff; border-color: rgba(255, 255, 255, 0.4); }

        .modal-sub { margin: 8px 0 22px; color: var(--muted); font-size: 12.5px; }

        .field { margin-bottom: 16px; }

        .lbl {
            display: block;
            margin-bottom: 7px;
            font-size: 11px;
            letter-spacing: 1.2px;
            text-transform: uppercase;
            font-weight: 700;
            color: var(--muted);
        }

        .input {
            width: 100%;
            background: #0a1220;
            border: 1px solid var(--line);
            border-radius: 9px;
            padding: 11px 13px;
            color: var(--text);
            font-size: 13.5px;
            font-family: inherit;
            outline: none;
        }

        .input:focus { border-color: rgba(46, 125, 255, 0.75); }

        .input-file {
            width: 100%;
            color: var(--muted);
            font-size: 12.5px;
            font-family: inherit;
            background: #0a1220;
            border: 1px dashed rgba(255, 255, 255, 0.18);
            border-radius: 9px;
            padding: 12px;
        }

        /* Boton interno del input file para que combine con el tema oscuro */
        .input-file::-webkit-file-upload-button {
            background: var(--panel-3);
            color: var(--text);
            border: 1px solid rgba(255, 255, 255, 0.16);
            border-radius: 6px;
            padding: 7px 14px;
            margin-right: 12px;
            font-family: inherit;
            font-size: 12.5px;
            font-weight: 600;
            cursor: pointer;
        }

        .input-file::file-selector-button {
            background: var(--panel-3);
            color: var(--text);
            border: 1px solid rgba(255, 255, 255, 0.16);
            border-radius: 6px;
            padding: 7px 14px;
            margin-right: 12px;
            font-family: inherit;
            font-size: 12.5px;
            font-weight: 600;
            cursor: pointer;
        }

        .hint { display: block; margin-top: 6px; font-size: 11.5px; color: rgba(139, 161, 192, 0.8); }

        .form-msg {
            display: block;
            min-height: 18px;
            margin: 4px 0 12px;
            font-size: 12.5px;
            font-weight: 600;
            color: var(--danger);
        }

        .modal-actions {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            gap: 10px;
            margin-top: 6px;
        }

        .modal-actions input.btn-play { padding: 11px 26px; }

        /* ---------- Aviso flotante ---------- */
        .toast {
            position: fixed;
            left: 50%;
            bottom: 112px;
            transform: translate(-50%, 14px);
            background: #10233f;
            border: 1px solid rgba(46, 125, 255, 0.5);
            color: var(--text);
            padding: 12px 22px;
            border-radius: 999px;
            font-size: 13px;
            font-weight: 600;
            box-shadow: 0 14px 34px rgba(0, 0, 0, 0.5);
            opacity: 0;
            pointer-events: none;
            transition: opacity .22s ease, transform .22s ease;
            z-index: 70;
            max-width: 90vw;
        }

        .toast.is-visible { opacity: 1; transform: translate(-50%, 0); }

        /* ---------- Scrollbar ---------- */
        .main::-webkit-scrollbar, .sidebar::-webkit-scrollbar, .modal::-webkit-scrollbar { width: 10px; }
        .main::-webkit-scrollbar-thumb, .sidebar::-webkit-scrollbar-thumb, .modal::-webkit-scrollbar-thumb {
            background: rgba(255, 255, 255, 0.12);
            border-radius: 6px;
        }

        /* ---------- Adaptacion a pantallas pequenas ---------- */
        @media (max-width: 980px) {
            .shell { grid-template-columns: 1fr; }
            .sidebar { display: none; }
            .list-head, .row { grid-template-columns: 40px minmax(0, 1fr) 100px 110px; }
            .cell-album { display: none; }
            .player { grid-template-columns: 1fr auto; }
            .player-right { display: none; }
        }
    </style>
</head>
<body>
    <form id="formSongs" runat="server" enctype="multipart/form-data">
        <div class="shell">

            <!-- ================= Barra lateral ================= -->
            <aside class="sidebar">
                <div class="logo">
                    <span class="logo-mark">
                        <svg viewBox="0 0 24 24" fill="none" stroke="#ffffff" stroke-width="2" stroke-linecap="round">
                            <path d="M4 14v-2a8 8 0 0 1 16 0v2" />
                            <path d="M4 14h2v5H4zM18 14h2v5h-2z" />
                        </svg>
                    </span>
                    PoliMusic
                </div>

                <nav class="nav">
                    <a class="nav-item is-active" href="Songs.aspx">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linejoin="round">
                            <path d="M3 10.5 12 3l9 7.5" />
                            <path d="M5 9.8V21h14V9.8" />
                        </svg>
                        Inicio
                    </a>
                    <a class="nav-item" href="Songs.aspx">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
                            <circle cx="11" cy="11" r="7" />
                            <path d="m20 20-3.5-3.5" />
                        </svg>
                        Buscar
                    </a>
                    <a class="nav-item" href="Songs.aspx">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
                            <path d="M4 4v16M9.5 4v16M15 5.5 20 20" />
                        </svg>
                        Tu biblioteca
                    </a>
                </nav>

                <p class="side-section">Tus playlists</p>

                <div class="pl-list">
                    <div class="pl-item" title="Módulo de playlists en construcción">
                        <span class="pl-thumb">&#9834;</span>
                        <span class="pl-name">Playlist 1</span>
                    </div>
                    <div class="pl-item" title="Módulo de playlists en construcción">
                        <span class="pl-thumb">&#9834;</span>
                        <span class="pl-name">Playlist 2</span>
                    </div>
                    <div class="pl-item" title="Módulo de playlists en construcción">
                        <span class="pl-thumb">&#9834;</span>
                        <span class="pl-name">Playlist 3</span>
                    </div>
                    <div class="pl-item" title="Módulo de playlists en construcción">
                        <span class="pl-thumb">&#9834;</span>
                        <span class="pl-name">Playlist 4</span>
                    </div>
                    <div class="pl-item" title="Módulo de playlists en construcción">
                        <span class="pl-thumb">&#9834;</span>
                        <span class="pl-name">Playlist 5</span>
                    </div>
                </div>

                <p class="side-note">
                    Las playlists se conectarán en el siguiente módulo del proyecto.
                </p>
            </aside>

            <!-- ================= Contenido ================= -->
            <main class="main">

                <div class="topbar">
                    <div class="search">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
                            <circle cx="11" cy="11" r="7" />
                            <path d="m20 20-3.5-3.5" />
                        </svg>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input" placeholder="¿Qué quieres escuchar?"></asp:TextBox>
                        <asp:Button ID="btnSearch" runat="server" CssClass="search-btn" Text="Buscar" OnClick="btnSearch_Click" />
                    </div>

                    <div class="topbar-right">
                        <span class="user-chip"><span class="avatar">&#9834;</span><asp:Label ID="lblUserName" runat="server" CssClass="user-name" Text="Mi cuenta"></asp:Label></span>
                        <a class="chip-link" href="Logout.aspx">Salir</a>
                    </div>
                </div>

                <section class="hero">
                    <div class="hero-cover"><span>&#9834;</span></div>
                    <div class="hero-info">
                        <p class="eyebrow">Biblioteca</p>
                        <h1>Canciones</h1>
                        <p class="hero-meta">
                            <asp:Label ID="lblSummary" runat="server" Text="0 canciones"></asp:Label>
                            <span class="dot">&middot;</span>
                            <asp:Label ID="lblTotalPlays" runat="server" Text="0 reproducciones"></asp:Label>
                        </p>
                        <div class="hero-actions">
                            <button type="button" class="btn-play" onclick="playAt(0); return false;">
                                <span class="ico-tri"></span>
                                Reproducir
                            </button>
                            <asp:LinkButton ID="btnNew" runat="server" CssClass="btn-ghost" OnClick="btnNew_Click" Text="+ Agregar canción" />
                        </div>
                    </div>
                </section>

                <div class="list-wrap">
                    <div class="list-head">
                        <span>#</span>
                        <span>Título</span>
                        <span>Álbum</span>
                        <span>Reproducciones</span>
                        <span></span>
                    </div>

                    <div id="songList">
                        <asp:Repeater ID="rptSongs" runat="server" OnItemCommand="rptSongs_ItemCommand">
                            <ItemTemplate>
                                <div class="row"
                                     data-id='<%# Eval("IdSong") %>'
                                     data-src='<%# SongUrl(Eval("SongPath")) %>'
                                     data-title='<%# Attr(Eval("SongName")) %>'
                                     data-artist='<%# Attr(ArtistLabel(Eval("ArtistName"))) %>'>
                                    <div class="cell-num">
                                        <span class="idx"><%# Container.ItemIndex + 1 %></span>
                                        <a href="#" class="play-mini" title="Reproducir" onclick='playAt(<%# Container.ItemIndex %>); return false;'></a>
                                    </div>
                                    <div class="cell-title">
                                        <span class="thumb">&#9834;</span>
                                        <span class="titles">
                                            <span class="t-name"><%# Txt(Eval("SongName")) %></span>
                                            <span class="t-artist"><%# Txt(ArtistLabel(Eval("ArtistName"))) %></span>
                                        </span>
                                    </div>
                                    <div class="cell-album"><%# Txt(AlbumLabel(Eval("AlbumTitle"))) %></div>
                                    <div class="cell-plays"><span id='plays-<%# Eval("IdSong") %>'><%# Eval("Plays") %></span></div>
                                    <div class="cell-actions">
                                        <asp:LinkButton ID="lnkEdit" runat="server" CssClass="act" CommandName="Edit"
                                            CommandArgument='<%# Eval("IdSong") %>' Text="Editar" CausesValidation="false" />
                                        <asp:LinkButton ID="lnkDelete" runat="server" CssClass="act act-danger" CommandName="Delete"
                                            CommandArgument='<%# Eval("IdSong") %>' Text="Eliminar" CausesValidation="false"
                                            OnClientClick="return confirm('¿Seguro que quieres eliminar esta canción de la biblioteca?');" />
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                    <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty" Visible="false">
                        <p class="empty-title">Todavía no hay canciones por aquí</p>
                        <p class="empty-sub">Agrega tu primer archivo de audio para empezar tu biblioteca.</p>
                    </asp:Panel>
                </div>
            </main>
        </div>

        <!-- ================= Reproductor ================= -->
        <footer class="player">
            <div class="now">
                <div class="now-cover"><span>&#9834;</span></div>
                <div class="now-meta">
                    <span class="now-title" id="nowTitle">Nada en reproducción</span>
                    <span class="now-artist" id="nowArtist">Selecciona una canción</span>
                </div>
            </div>

            <div class="center">
                <div class="controls">
                    <button type="button" class="ctl" title="Anterior" onclick="prevSong(); return false;">
                        <svg viewBox="0 0 24 24" fill="currentColor">
                            <path d="M6 5h2v14H6zM20 5v14L9 12z" />
                        </svg>
                    </button>
                    <button type="button" class="ctl ctl-main" id="btnToggle" title="Reproducir" onclick="togglePlay(); return false;">
                        <span class="ico-play"></span>
                        <span class="ico-pause"></span>
                    </button>
                    <button type="button" class="ctl" title="Siguiente" onclick="nextSong(); return false;">
                        <svg viewBox="0 0 24 24" fill="currentColor">
                            <path d="M16 5h2v14h-2zM4 5v14l11-7z" />
                        </svg>
                    </button>
                </div>

                <div class="progress">
                    <span class="time" id="timeCur">0:00</span>
                    <div class="bar" id="barTrack" onclick="seek(event)">
                        <div class="bar-fill" id="barFill"></div>
                    </div>
                    <span class="time" id="timeDur">0:00</span>
                </div>
            </div>

            <div class="player-right">
                <span class="plays-chip"><span id="nowPlays">0</span> <span id="nowPlaysLabel">reproducciones</span></span>
                <input type="range" class="vol" id="vol" min="0" max="100" value="80" oninput="setVolume(this.value)" />
            </div>

            <audio id="audio" preload="none"></audio>
        </footer>

        <!-- ================= Modal de alta / edicion ================= -->
        <asp:Panel ID="pnlForm" runat="server" CssClass="modal-backdrop">
            <div class="modal">
                <div class="modal-head">
                    <h2><asp:Label ID="lblFormTitle" runat="server" Text="Nueva canción"></asp:Label></h2>
                    <asp:LinkButton ID="btnClose" runat="server" CssClass="modal-x" OnClick="btnCancel_Click" Text="Cerrar" CausesValidation="false" />
                </div>

                <p class="modal-sub">Sube un archivo de audio o registra la ruta de un archivo que ya esté en el servidor.</p>

                <div class="field">
                    <span class="lbl">Nombre de la canción *</span>
                    <asp:TextBox ID="txtSongName" runat="server" CssClass="input" MaxLength="50" placeholder="Ej. Adventure"></asp:TextBox>
                </div>

                <div class="field">
                    <span class="lbl">Archivo de audio</span>
                    <asp:FileUpload ID="fupSongFile" runat="server" CssClass="input-file" />
                    <span class="hint">Formatos permitidos: mp3, wav, ogg, m4a · máximo 25 MB</span>
                </div>

                <div class="field">
                    <span class="lbl">o ruta virtual del archivo</span>
                    <asp:TextBox ID="txtSongPath" runat="server" CssClass="input" placeholder="~/SongFiles/mi-cancion.mp3"></asp:TextBox>
                </div>

                <div class="field">
                    <span class="lbl">Reproducciones</span>
                    <asp:TextBox ID="txtPlays" runat="server" CssClass="input" Text="0"></asp:TextBox>
                </div>

                <asp:Label ID="lblFormMessage" runat="server" CssClass="form-msg"></asp:Label>

                <div class="modal-actions">
                    <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn-ghost" OnClick="btnCancel_Click" Text="Cancelar" CausesValidation="false" />
                    <asp:Button ID="btnSave" runat="server" CssClass="btn-play" Text="Guardar" OnClick="btnSave_Click" />
                </div>
            </div>
        </asp:Panel>

        <!-- ================= Aviso ================= -->
        <asp:Panel ID="pnlToast" runat="server" CssClass="toast">
            <asp:Label ID="lblToast" runat="server"></asp:Label>
        </asp:Panel>

        <script type="text/javascript">
            // =========================================================
            // Reproductor estilo Spotify: toda la interaccion es cliente,
            // el contador de reproducciones se registra en segundo plano.
            // =========================================================
            var audio = document.getElementById('audio');
            var rows = [];
            var current = -1;

            function collectSongs() {
                rows = [];
                var nodes = document.querySelectorAll('#songList .row');

                for (var i = 0; i < nodes.length; i++) {
                    var node = nodes[i];
                    rows.push({
                        el: node,
                        id: node.getAttribute('data-id'),
                        src: node.getAttribute('data-src'),
                        title: node.getAttribute('data-title'),
                        artist: node.getAttribute('data-artist')
                    });
                }
            }

            function formatTime(seconds) {
                if (!seconds || isNaN(seconds)) { return '0:00'; }
                var minutes = Math.floor(seconds / 60);
                var rest = Math.floor(seconds % 60);
                return minutes + ':' + (rest < 10 ? '0' : '') + rest;
            }

            function setPlaying(state) {
                var button = document.getElementById('btnToggle');
                if (!button) { return; }
                button.className = state ? 'ctl ctl-main is-playing' : 'ctl ctl-main';
                button.title = state ? 'Pausar' : 'Reproducir';
            }

            function playAt(index) {
                if (!rows.length) {
                    showToast('Todavía no hay canciones en la biblioteca.');
                    return;
                }

                if (index < 0) { index = rows.length - 1; }
                if (index >= rows.length) { index = 0; }

                current = index;
                var song = rows[index];

                audio.src = song.src;
                audio.volume = parseInt(document.getElementById('vol').value, 10) / 100;

                var promise = audio.play();

                if (promise && promise.catch) {
                    promise.catch(function () { setPlaying(false); });
                }

                for (var i = 0; i < rows.length; i++) {
                    rows[i].el.className = (i === index) ? 'row is-playing' : 'row';
                }

                document.getElementById('nowTitle').innerHTML = song.title;
                document.getElementById('nowArtist').innerHTML = song.artist;
                document.getElementById('barFill').style.width = '0%';
                document.getElementById('timeCur').innerHTML = '0:00';
                document.getElementById('timeDur').innerHTML = '0:00';

                setPlaying(true);
                countPlay(song.id);
            }

            function togglePlay() {
                if (!audio.src) {
                    playAt(0);
                    return;
                }

                if (audio.paused) {
                    audio.play();
                    setPlaying(true);
                } else {
                    audio.pause();
                    setPlaying(false);
                }
            }

            function nextSong() { playAt(current < 0 ? 0 : current + 1); }

            function prevSong() { playAt(current <= 0 ? 0 : current - 1); }

            function seek(event) {
                if (!audio.duration) { return; }

                var track = document.getElementById('barTrack');
                var rect = track.getBoundingClientRect();
                var ratio = (event.clientX - rect.left) / rect.width;

                if (ratio < 0) { ratio = 0; }
                if (ratio > 1) { ratio = 1; }

                audio.currentTime = ratio * audio.duration;
            }

            function setVolume(value) { audio.volume = parseInt(value, 10) / 100; }

            // Registra la reproduccion sin recargar la pagina (asi el audio no se corta)
            function countPlay(id) {
                var request = new XMLHttpRequest();

                request.onreadystatechange = function () {
                    if (request.readyState !== 4 || request.status !== 200) { return; }

                    var cell = document.getElementById('plays-' + id);

                    if (cell) {
                        var total = parseInt(cell.innerHTML, 10);
                        if (!isNaN(total)) {
                            cell.innerHTML = total + 1;
                            document.getElementById('nowPlays').innerHTML = cell.innerHTML;
                            document.getElementById('nowPlaysLabel').innerHTML = (total + 1) === 1 ? 'reproducción' : 'reproducciones';
                        }
                    }
                };

                request.open('GET', 'PlayCounter.ashx?id=' + encodeURIComponent(id) + '&t=' + new Date().getTime(), true);
                request.send(null);
            }

            function showToast(message) {
                var toast = document.getElementById('<%= pnlToast.ClientID %>');
                if (!toast) { return; }

                toast.innerHTML = message;
                toast.className = 'toast is-visible';

                window.setTimeout(function () { toast.className = 'toast'; }, 4200);
            }

            audio.addEventListener('timeupdate', function () {
                if (!audio.duration) { return; }

                document.getElementById('barFill').style.width = (audio.currentTime / audio.duration * 100) + '%';
                document.getElementById('timeCur').innerHTML = formatTime(audio.currentTime);
            });

            audio.addEventListener('loadedmetadata', function () {
                document.getElementById('timeDur').innerHTML = formatTime(audio.duration);
            });

            audio.addEventListener('ended', function () { nextSong(); });

            audio.addEventListener('error', function () {
                if (!audio.src) { return; }
                setPlaying(false);
                showToast('No se pudo cargar el audio de esta canción. Revisa la ruta del archivo.');
            });

            // El buscador se dispara con Enter
            document.getElementById('<%= txtSearch.ClientID %>').onkeydown = function (event) {
                var code = event.keyCode || event.which;
                if (code === 13) {
                    event.preventDefault();
                    document.getElementById('<%= btnSearch.ClientID %>').click();
                }
            };

            collectSongs();

            // Cerrar el modal al hacer clic fuera de la tarjeta o con la tecla Esc
            var backdrop = document.getElementById('<%= pnlForm.ClientID %>');

            if (backdrop) {
                backdrop.addEventListener('click', function (event) {
                    if (event.target === backdrop) {
                        document.getElementById('<%= btnCancel.ClientID %>').click();
                    }
                });
            }

            document.addEventListener('keydown', function (event) {
                var code = event.keyCode || event.which;

                if (code === 27 && backdrop && backdrop.className.indexOf('is-open') >= 0) {
                    document.getElementById('<%= btnCancel.ClientID %>').click();
                }
            });

            // Oculta el aviso que viene del servidor despues de unos segundos
            (function () {
                var toast = document.getElementById('<%= pnlToast.ClientID %>');
                if (toast && toast.className.indexOf('is-visible') >= 0) {
                    window.setTimeout(function () { toast.className = 'toast'; }, 4200);
                }
            })();
        </script>
    </form>
</body>
</html>
