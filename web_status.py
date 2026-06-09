#!/usr/bin/env python3
"""
MemoryGuard Web 状态服务 - 动态交互版
支持显示待确认药品列表，并提供确认链接，点击后更新数据库。
"""

import sqlite3
import os
import sys
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import parse_qs, urlparse
from datetime import datetime

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, 'db', 'memoryguard.db')
LOG_PATH = os.path.join(BASE_DIR, 'logs', 'memoryguard.log')


class MemoryGuardHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        # 屏蔽访问日志
        pass

    def do_GET(self):
        parsed = urlparse(self.path)
        # 处理确认请求
        if parsed.path == '/confirm':
            params = parse_qs(parsed.query)
            med = params.get('med', [None])[0]
            if not med:
                self.send_error(400, "缺少药品参数")
                return
            today = datetime.now().strftime('%Y-%m-%d')
            try:
                conn = sqlite3.connect(DB_PATH)
                cur = conn.cursor()
                cur.execute(
                    "UPDATE med_log SET status='taken', confirmed_at=datetime('now') "
                    "WHERE med_name=? AND taken_date=? AND status='pending'",
                    (med, today)
                )
                conn.commit()
                affected = cur.rowcount
                conn.close()
                if affected == 0:
                    msg = f"未找到待确认记录：{med} (可能已经确认或日期不匹配)"
                else:
                    msg = f"药品「{med}」已确认成功！"
                self.send_response(200)
                self.send_header('Content-type', 'text/html; charset=utf-8')
                self.end_headers()
                self.wfile.write(f"""
                    <html><head><meta charset="utf-8"><meta http-equiv="refresh" content="3;url=/"></head>
                    <body style="font-family:sans-serif;text-align:center;margin-top:50px">
                    <h2>✅ {msg}</h2>
                    <p>3秒后自动返回首页，或 <a href="/">点击这里</a></p>
                    </body></html>
                """.encode())
                return
            except Exception as e:
                self.send_error(500, f"数据库错误: {e}")
                return

        # 默认：动态生成监控页面
        # 读取最近报警
        alerts = "暂无"
        try:
            with open(LOG_PATH, 'r') as f:
                lines = f.readlines()
                recent = [l for l in lines[-20:] if any(k in l for k in ('ALERT', 'ERROR', 'WARN'))]
                alerts = ''.join(recent[-5:]) if recent else "暂无"
        except Exception:
            pass

        # 查询待确认用药
        pending_list = []
        try:
            conn = sqlite3.connect(DB_PATH)
            cur = conn.cursor()
            cur.execute(
                "SELECT med_name, taken_date FROM med_log WHERE status='pending' "
                "ORDER BY taken_date DESC LIMIT 5"
            )
            pending_list = cur.fetchall()
            conn.close()
        except Exception:
            pass

        # 生成待确认列表的 HTML（带确认链接）
        if pending_list:
            pending_html = "<ul>\n"
            for med_name, taken_date in pending_list:
                # 注意：药品名可能包含空格或特殊字符，需要 URL 编码
                import urllib.parse
                med_enc = urllib.parse.quote(med_name)
                pending_html += f'<li>📅 {taken_date} - <strong>{med_name}</strong> <a href="/confirm?med={med_enc}">✅ 确认已服用</a></li>\n'
            pending_html += "</ul>"
        else:
            pending_html = "<p>🎉 暂无待确认用药</p>"

        # 生成完整 HTML
        html = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta http-equiv="refresh" content="30">
            <title>MemoryGuard 通知中心</title>
            <style>
                body {{ font-family: sans-serif; margin: 20px; background: #f0f0f0; }}
                .container {{ max-width: 800px; margin: auto; background: white; padding: 20px; border-radius: 10px; }}
                .alert {{ color: red; }}
                pre {{ background: #f4f4f4; padding: 10px; border-radius: 5px; overflow-x: auto; }}
                a {{ color: #0066cc; text-decoration: none; }}
                a:hover {{ text-decoration: underline; }}
                li {{ margin: 8px 0; }}
            </style>
        </head>
        <body>
            <div class="container">
                <h1>🏠 MemoryGuard 通知中心</h1>
                <p><b>{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</b></p>
                <h2>🚨 最近报警</h2>
                <pre>{alerts}</pre>
                <h2>💊 待确认用药</h2>
                {pending_html}
                <p><i>v2.0 动态交互版 - 点击确认链接即可记录服药</i></p>
            </div>
        </body>
        </html>
        """
        self.send_response(200)
        self.send_header('Content-type', 'text/html; charset=utf-8')
        self.end_headers()
        self.wfile.write(html.encode())


def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    server = HTTPServer(('0.0.0.0', port), MemoryGuardHandler)
    print(f"MemoryGuard Web 服务已启动，端口 {port}")
    print(f"访问地址: http://localhost:{port}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n服务已停止")
        server.server_close()


if __name__ == '__main__':
    main()
