#!/usr/bin/env python3
"""Sinh trang web tĩnh (HTML) từ privacy-policy.md, terms-of-use.md, support.md.

Dùng:  python docs/legal/build_web.py          (chạy từ thư mục gốc app hoặc bất kỳ đâu)
Kết quả: docs/legal/web/privacy-policy.html, terms-of-use.html, support.html
Chỉ lấy phần SAU dòng '---' đầu tiên (phần trước là ghi chú nội bộ, không đăng).
Mỗi file md có 2 phần cách nhau bằng '---': tiếng Việt rồi tiếng Anh.
Chỗ cần điền ([ĐIỀN: ...] / [FILL: ...]) được tô nổi bật; script in danh sách các chỗ còn trống.
Không cần thư viện ngoài. Trang HTML tự chứa (CSS nội tuyến), hỗ trợ chế độ tối, vừa màn hình điện thoại.
"""
import html
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT = HERE / "web"

PAGES = [
    ("privacy-policy", "Privacy Policy · Chính sách quyền riêng tư", "Orbiday"),
    ("terms-of-use", "Terms of Use · Điều khoản sử dụng", "Orbiday"),
    ("support", "Support · Hỗ trợ", "Orbiday"),
]

CSS = """
:root{--bg:#fff;--fg:#1d2227;--muted:#59636e;--line:#d8dee4;--accent:#0b5cad;--mark:#fff1b8;--markfg:#5b4300}
@media (prefers-color-scheme:dark){:root{--bg:#14181d;--fg:#e6eaee;--muted:#a3adb8;--line:#2d343c;--accent:#7fb7f0;--mark:#4a3b00;--markfg:#ffe9a3}}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--fg);font:16px/1.6 system-ui,-apple-system,"Segoe UI",Roboto,sans-serif}
main{max-width:46rem;margin:0 auto;padding:1.25rem 16px 3rem}
h1{font-size:1.6rem;line-height:1.25;margin:.2rem 0 .4rem}
h2{font-size:1.3rem;margin:2.2rem 0 .3rem;padding-top:1rem;border-top:1px solid var(--line)}
h3{font-size:1.05rem;margin:1.5rem 0 .3rem}
p,li{margin:.5rem 0}
ul{padding-left:1.3rem}
a{color:var(--accent)}
nav.lang{display:flex;gap:.75rem;margin:.5rem 0 1rem;font-size:.95rem}
nav.lang a{padding:.35rem .7rem;border:1px solid var(--line);border-radius:999px;text-decoration:none;min-height:44px;display:inline-flex;align-items:center}
mark{background:var(--mark);color:var(--markfg);padding:0 .2em;border-radius:3px}
code{font-family:ui-monospace,Menlo,Consolas,monospace;font-size:.92em;background:rgba(127,127,127,.15);padding:0 .25em;border-radius:3px}
footer{margin-top:3rem;color:var(--muted);font-size:.85rem}
"""


def inline(text: str) -> str:
    t = html.escape(text, quote=False)
    t = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", t)
    t = re.sub(r"`([^`]+)`", r"<code>\1</code>", t)
    t = re.sub(r"\[(ĐIỀN|FILL):([^\]]*)\]", r"<mark>[\1:\2]</mark>", t)
    return t


def render(md: str) -> str:
    out, in_list = [], False
    for raw in md.strip("\n").split("\n"):
        line = raw.rstrip()
        if line.startswith("- "):
            if not in_list:
                out.append("<ul>")
                in_list = True
            out.append("<li>%s</li>" % inline(line[2:]))
            continue
        if in_list:
            out.append("</ul>")
            in_list = False
        if not line:
            continue
        m = re.match(r"^(#{2,3}) (.*)$", line)
        if m:
            level = len(m.group(1))
            out.append("<h%d>%s</h%d>" % (level, inline(m.group(2)), level))
        else:
            out.append("<p>%s</p>" % inline(line))
    if in_list:
        out.append("</ul>")
    return "\n".join(out)


def main() -> int:
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    OUT.mkdir(exist_ok=True)
    open_slots = []
    for slug, title, brand in PAGES:
        src = HERE / (slug + ".md")
        parts = re.split(r"\n---\n", src.read_text(encoding="utf-8"))
        if len(parts) < 3:
            print("LỖI: %s phải có phần ghi chú, phần tiếng Việt, phần tiếng Anh cách nhau bằng ---" % src.name)
            return 1
        vi, en = parts[1], parts[2]
        # '## Tiếng Việt' / '## English' -> tiêu đề ngôn ngữ, bỏ khỏi thân bài
        vi = re.sub(r"^\s*## Tiếng Việt\s*\n", "", vi)
        en = re.sub(r"^\s*## English\s*\n", "", en)
        # h3 đầu tiên của mỗi phần thành h1
        vi_html = render(vi).replace("<h3>", "<h1>", 1).replace("</h3>", "</h1>", 1)
        en_html = render(en).replace("<h3>", "<h1>", 1).replace("</h3>", "</h1>", 1)
        for lang, body in (("vi", vi), ("en", en)):
            for m in re.finditer(r"\[(?:ĐIỀN|FILL):[^\]]*\]", body):
                open_slots.append("%s [%s]: %s" % (slug, lang, m.group(0)))
        page = f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="index,follow">
<title>{html.escape(brand)} — {html.escape(title)}</title>
<style>{CSS}</style>
</head>
<body>
<!-- Sinh bởi docs/legal/build_web.py từ {slug}.md — sửa file .md rồi chạy lại script, không sửa tay file này.
     Còn chỗ chưa điền (phần tô vàng) thì KHÔNG đăng. -->
<main>
<nav class="lang" aria-label="Language"><a href="#vi">Tiếng Việt</a><a href="#en">English</a></nav>
<section id="vi" lang="vi">
{vi_html}
</section>
<section id="en" lang="en">
{en_html}
</section>
<footer>{html.escape(brand)} · <a href="privacy-policy.html">Privacy / Quyền riêng tư</a> · <a href="support.html">Support / Hỗ trợ</a> · <a href="terms-of-use.html">Terms / Điều khoản</a></footer>
</main>
</body>
</html>
"""
        (OUT / (slug + ".html")).write_text(page, encoding="utf-8")
        print("đã sinh", OUT / (slug + ".html"))
    print("\nChỗ còn phải điền trước khi đăng (%d):" % len(open_slots))
    for s in open_slots:
        print(" -", s)
    return 0


if __name__ == "__main__":
    sys.exit(main())
