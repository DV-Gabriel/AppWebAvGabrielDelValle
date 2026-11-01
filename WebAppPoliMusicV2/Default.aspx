<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="WebAppPoliMusicV2.Default" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>PoliMusic</title>
    <style type="text/css">
        * { box-sizing: border-box; }

        html, body {
            height: 100%;
            margin: 0;
        }

        body {
            display: flex;
            align-items: center;
            justify-content: center;
            background: #04070d;
            color: #ffffff;
            font-family: "Segoe UI", Tahoma, Arial, sans-serif;
        }

        .splash {
            text-align: center;
        }

        .mark {
            width: 62px;
            height: 62px;
            margin: 0 auto 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            background: linear-gradient(135deg, #1e90ff, #0a5bd3);
            box-shadow: 0 10px 30px rgba(30, 144, 255, .45);
        }

        .mark svg { width: 32px; height: 32px; }

        h1 {
            margin: 0 0 6px;
            font-size: 22px;
            letter-spacing: 1px;
        }

        p {
            margin: 0;
            color: #9aa7b8;
            font-size: 13px;
        }

        a {
            color: #1e90ff;
            text-decoration: none;
        }

        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <form id="formDefault" runat="server">
        <div class="splash">
            <div class="mark">
                <svg viewBox="0 0 24 24" fill="none" stroke="#ffffff" stroke-width="2" stroke-linecap="round">
                    <path d="M4 14v-2a8 8 0 0 1 16 0v2" />
                    <path d="M4 14h2v5H4zM18 14h2v5h-2z" />
                </svg>
            </div>
            <h1>PoliMusic</h1>
            <p>Cargando tu biblioteca... <a href="Login.aspx">continuar</a></p>
        </div>
    </form>
</body>
</html>
