#!/usr/bin/env python3
"""Generate Livia Panel's bilingual README illustrations with Python's standard library."""
from html import escape
from pathlib import Path

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "screenshots"
OUT.mkdir(parents=True, exist_ok=True)

BG0, BG1 = "#090E1C", "#171B39"
PANEL, CARD, STROKE = "#11192A", "#19243A", "#334662"
TEXT, MUTED, INDIGO, CYAN = "#F4F7FF", "#A4B5D0", "#7B82FF", "#35D4E8"
ACCENT = f'<linearGradient id="accent" x1="0" y1="0" x2="1" y2="1"><stop stop-color="{INDIGO}"/><stop offset="1" stop-color="{CYAN}"/></linearGradient>'

COPY = {
    "id": {
        "tag": "ROBLOX LUA • MOBILE-FIRST",
        "title": ("Satu panel.", "Lima kontrol."),
        "desc": "Speed, Jump, Fly, No Clip, dan Flashlight dalam UI ringkas yang dirancang untuk sentuhan.",
        "features": ["Kecepatan gerak", "Tinggi lompatan", "Gerak udara", "Nonaktifkan tabrakan", "Cahaya terarah"],
        "steps": [
            ("SALIN SCRIPT", "Buka file Lua dari repositori."),
            ("JALANKAN", "Gunakan lingkungan yang mengizinkan."),
            ("ATUR KONTROL", "Aktifkan toggle dan sesuaikan nilai."),
            ("BERSIHKAN", "Matikan fitur atau tutup panel."),
        ],
        "controls": [
            ("KETUK", "ON/OFF", "Ketuk tombol untuk mengganti status."),
            ("GESER", "PINDAHKAN", "Geser header untuk memindahkan panel."),
            ("MINIMIZE", "BUKA KEMBALI", "Panel diringkas menjadi tombol L."),
            ("TUTUP", "CLEANUP", "Hentikan fitur dan lepaskan koneksi."),
        ],
        "fly": ("Joystick menentukan arah gerak.", "Kemiringan kamera ikut memengaruhi gerak vertikal.", "Lepaskan joystick untuk berhenti."),
        "safe": [
            ("EFEK SISI KLIEN", "Perubahan lokal mungkin tidak direplikasi."),
            ("IZIN PENGALAMAN", "Gunakan hanya di lingkungan yang mengizinkan."),
            ("PEMULIHAN NILAI", "Speed/Jump kembali ke nilai tetap saat OFF."),
        ],
    },
    "en": {
        "tag": "ROBLOX LUA • MOBILE-FIRST",
        "title": ("One panel.", "Five controls."),
        "desc": "Speed, Jump, Fly, No Clip, and Flashlight in a compact interface designed for touch.",
        "features": ["Movement speed", "Jump height", "Air movement", "Disable collisions", "Directional light"],
        "steps": [
            ("COPY SCRIPT", "Open the Lua file from this repository."),
            ("RUN", "Use a supported, permitted environment."),
            ("SET CONTROLS", "Toggle features and adjust values."),
            ("CLEAN UP", "Disable features or close the panel."),
        ],
        "controls": [
            ("TAP", "ON/OFF", "Tap a button to change its state."),
            ("DRAG", "MOVE", "Drag the header to reposition the panel."),
            ("MINIMIZE", "REOPEN", "The panel collapses to an L button."),
            ("CLOSE", "CLEANUP", "Stop features and release connections."),
        ],
        "fly": ("The joystick sets movement direction.", "Camera pitch also influences vertical movement.", "Release the joystick to stop."),
        "safe": [
            ("CLIENT-SIDE EFFECTS", "Local changes may not replicate."),
            ("EXPERIENCE PERMISSION", "Use only where scripts are permitted."),
            ("RESET BEHAVIOR", "Speed/Jump return to fixed defaults when OFF."),
        ],
    },
}

def text(x, y, value, size=14, fill=TEXT, weight=650, anchor="start", extra=""):
    return (f'<text x="{x}" y="{y}" font-family="Inter,Segoe UI,Arial,sans-serif" '
            f'font-size="{size}" font-weight="{weight}" fill="{fill}" '
            f'text-anchor="{anchor}" {extra}>{escape(value)}</text>')

def shell(title, desc, body, height=360):
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="{height}" viewBox="0 0 1200 {height}" role="img" aria-labelledby="title desc">
<title id="title">{escape(title)}</title><desc id="desc">{escape(desc)}</desc>
<defs>
 <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop stop-color="{BG0}"/><stop offset=".56" stop-color="#111A2D"/><stop offset="1" stop-color="{BG1}"/></linearGradient>
 {ACCENT}
 <pattern id="dots" width="24" height="24" patternUnits="userSpaceOnUse"><circle cx="2" cy="2" r="1" fill="#91A7D7" fill-opacity=".13"/></pattern>
 <radialGradient id="glow"><stop stop-color="#7079FF" stop-opacity=".21"/><stop offset="1" stop-color="#7079FF" stop-opacity="0"/></radialGradient>
</defs>
<rect width="1200" height="{height}" rx="22" fill="url(#bg)"/><rect width="1200" height="{height}" rx="22" fill="url(#dots)"/>
<ellipse cx="1020" cy="70" rx="370" ry="290" fill="url(#glow)"/><rect x="1" y="1" width="1198" height="{height-2}" rx="21" fill="none" stroke="#2B3C59"/>
{body}
</svg>'''

def logo():
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128" role="img" aria-labelledby="t d">
<title id="t">Livia Panel</title><desc id="d">L-shaped Livia Panel monogram in an indigo and cyan gradient.</desc>
<defs>{ACCENT}<filter id="s" x="-20%" y="-20%" width="140%" height="140%"><feDropShadow dx="0" dy="8" stdDeviation="7" flood-color="#030716" flood-opacity=".34"/></filter></defs>
<rect x="5" y="5" width="118" height="118" rx="34" fill="#0A1020" stroke="#283B5B"/>
<rect x="13" y="13" width="102" height="102" rx="29" fill="url(#accent)" filter="url(#s)"/>
<path d="M48 34V91H83" fill="none" stroke="#081321" stroke-width="10" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M75 77L91 91L75 105" fill="none" stroke="#EAFBFF" stroke-width="5" stroke-linecap="round" stroke-linejoin="round" opacity=".95"/>
</svg>'''

def panel(lang, x, y, scale=1.0, compact=False):
    d = COPY[lang]
    w = 385
    h = 410 if compact else 465
    row_h = 55 if compact else 65
    start = 91 if compact else 94
    out = [f'<g transform="translate({x} {y}) scale({scale})"><rect width="{w}" height="{h}" rx="22" fill="{PANEL}" stroke="#354765" stroke-width="1.4"/>',
           f'<path d="M0 22Q0 0 22 0H{w-22}Q{w} 0 {w} 22V75H0Z" fill="#1D2942"/><path d="M0 74H{w}" stroke="#3C4D6C"/>',
           '<rect x="17" y="17" width="43" height="43" rx="14" fill="url(#accent)"/>',
           '<path d="M33 27V48H46" fill="none" stroke="#091321" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>',
           text(75, 35, "LIVIA PANEL", 15, TEXT, 900), text(75, 54, "MOVEMENT & UTILITY", 8, "#99A9C6", 750),
           f'<rect x="{w-102}" y="22" width="83" height="28" rx="14" fill="#14372F" stroke="#246553"/><circle cx="{w-86}" cy="36" r="3.5" fill="#48DBB1"/>',
           text(w-76, 40, "READY", 9, "#AEF9DB", 850)]
    names = ["SPEED", "JUMP", "FLY", "NO CLIP", "FLASHLIGHT"]
    values = ["50", "100", "60", "", ""]
    for i, name in enumerate(names):
        yy = start + i * row_h
        out.append(f'<rect x="15" y="{yy}" width="{w-30}" height="{row_h-8}" rx="12" fill="{CARD}" stroke="#30415E"/>')
        out.append(f'<rect x="27" y="{yy+11}" width="34" height="34" rx="10" fill="#263052"/>')
        out.append(text(44, yy+33, ["↗", "↑", "➤", "◇", "✦"][i], 16, "#AAB4FF" if i < 3 else "#63DEED", 850, "middle"))
        out.append(text(74, yy+24, name, 10, TEXT, 850))
        if values[i]:
            out.append(text(74, yy+40, "VALUE  " + values[i], 8, "#8FA2C2", 650))
        out.append(f'<rect x="{w-91}" y="{yy+13}" width="66" height="27" rx="9" fill="#313E58" stroke="#495A78"/>')
        out.append(text(w-58, yy+31, "OFF", 9, "#C0CAE0", 850, "middle"))
    out.extend([f'<path d="M15 {h-27}H{w-15}" stroke="#293B58"/>', text(18, h-10, "READY TO USE" if lang == "en" else "SIAP DIGUNAKAN", 8, "#8396B7", 800),
                f'<circle cx="{w-25}" cy="{h-21}" r="4" fill="#43D8B0"/>', '</g>'])
    return "".join(out)

def render(lang, kind):
    d = COPY[lang]
    if kind == "banner":
        body = '<g transform="translate(42 34)"><rect width="45" height="45" rx="14" fill="url(#accent)"/><path d="M58 12V32H75" transform="translate(-42 0)" fill="none" stroke="#0B1422" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>'
        body += text(60, 29, "Livia Panel", 23, TEXT, 900)
        body += f'<rect x="245" y="5" width="205" height="27" rx="13.5" fill="#1A2841" stroke="#354A6C"/>' + text(347, 23, d["tag"], 9, "#AABAFD", 850, "middle") + '</g>'
        body += text(50, 143, d["title"][0], 48, TEXT, 900, extra='letter-spacing="-1.8"')
        body += text(50, 197, d["title"][1], 48, "url(#accent)", 900, extra='letter-spacing="-1.8"')
        body += text(52, 238, d["desc"], 15, "#B0BED6", 500)
        body += text(52, 263, "Single-file Lua • no external UI library" if lang == "en" else "Skrip Lua satu file • tanpa library UI eksternal", 11, "#8D9FBF", 600)
        body += f'<rect x="52" y="294" width="182" height="38" rx="11" fill="url(#accent)"/>' + text(143, 318, "READ THE GUIDE" if lang == "en" else "BACA PETUNJUK", 10, "#081321", 900, "middle")
        body += f'<rect x="246" y="294" width="170" height="38" rx="11" fill="#172239" stroke="#344762"/>' + text(331, 318, "MIT LICENSE", 10, "#DAE7F8", 800, "middle")
        body += f'<rect x="692" y="28" width="468" height="336" rx="24" fill="#11192A" stroke="#344766"/>' + text(718, 56, "PANEL PREVIEW" if lang == "en" else "PRATINJAU PANEL", 10, "#AAB7D3", 850)
        # Scale the compact panel to fit fully inside the 336px-high frame.
        body += panel(lang, 780, 69, .72, True)
        body += text(52, 365, "INTERFACE ILLUSTRATION" if lang == "en" else "ILUSTRASI ANTARMUKA", 9, "#7588AA", 800)
        return shell("Livia Panel — " + d["tag"], d["desc"], body, 390)

    if kind == "preview":
        body = text(48, 54, "PANEL PREVIEW" if lang == "en" else "PRATINJAU PANEL", 25, TEXT, 900)
        body += text(49, 80, d["desc"], 13, MUTED, 500) + panel(lang, 56, 111, 1.02, False)
        x = 520
        body += f'<rect x="{x}" y="111" width="624" height="465" rx="22" fill="#131D30" stroke="#334866"/>' + text(x+28, 151, "WORKSPACE / CONTROL MAP", 10, "#A9B7D3", 850)
        cards = [
            ("01", "FIVE CONTROLS" if lang == "en" else "LIMA FITUR", "One compact panel." if lang == "en" else "Satu panel ringkas."),
            ("02", "TOUCH-FIRST", "Tap controls; drag from the header." if lang == "en" else "Ketuk kontrol; geser dari header."),
            ("03", "QUICK CLEANUP", "Close the panel to clean up." if lang == "en" else "Tutup panel untuk cleanup."),
            ("04", "NO UI DEPENDENCIES", "Single script; no external UI library." if lang == "en" else "Satu skrip tanpa library UI eksternal."),
        ]
        for i, c in enumerate(cards):
            yy = 180 + i*95
            body += f'<rect x="{x+24}" y="{yy}" width="576" height="78" rx="13" fill="#1A2740" stroke="#30435F"/><rect x="{x+38}" y="{yy+17}" width="39" height="39" rx="11" fill="#173548"/>'
            body += text(x+57.5, yy+41, c[0], 10, CYAN, 900, "middle") + text(x+91, yy+29, c[1], 12, TEXT, 850) + text(x+91, yy+51, c[2], 11, "#9AADC9", 500)
        return shell("Livia Panel preview", d["desc"], body, 650)

    if kind == "features":
        body = text(42, 53, "CORE FEATURES" if lang == "en" else "FITUR UTAMA", 25, TEXT, 900)
        body += text(43, 79, "Five controls in one compact panel." if lang == "en" else "Lima fungsi dalam satu panel kecil.", 13, MUTED, 500)
        items = [("01","SPEED",d["features"][0],"50"),("02","JUMP",d["features"][1],"100"),("03","FLY",d["features"][2],"60"),("04","NO CLIP",d["features"][3],"ON/OFF"),("05","FLASHLIGHT",d["features"][4],"ON/OFF")]
        for i, item in enumerate(items):
            x = 35 + i*234
            body += f'<rect x="{x}" y="112" width="214" height="205" rx="17" fill="#151F33" stroke="#334662"/><rect x="{x+16}" y="128" width="42" height="42" rx="12" fill="url(#accent)"/>'
            body += text(x+37, 155, item[0], 10, "#071321", 900, "middle") + text(x+16, 201, item[1], 15, TEXT, 900) + text(x+16, 224, item[2], 10, "#9EAFCA", 550)
            body += f'<path d="M{x+16} 242H{x+198}" stroke="#2B3D59"/>' + text(x+16, 271, "CONTROL" if lang == "en" else "KONTROL", 8, "#7F93B3", 850) + text(x+16, 297, item[3], 16, "#A9B3FF" if item[3] != "ON/OFF" else CYAN, 900)
        body += text(43, 350, "Defaults match the current LiviaPanel.lua configuration." if lang == "en" else "Nilai awal mengikuti konfigurasi LiviaPanel.lua saat ini.", 10, "#8094B4", 600)
        return shell("Livia Panel features", "Overview of Speed, Jump, Fly, No Clip and Flashlight.", body, 380)

    if kind == "workflow":
        body = text(44, 52, "GET STARTED IN FOUR STEPS" if lang == "en" else "MULAI DALAM EMPAT LANGKAH", 24, TEXT, 900)
        body += text(45, 77, "From script to cleanup." if lang == "en" else "Dari skrip sampai cleanup.", 13, MUTED, 500)
        for i, step in enumerate(d["steps"]):
            x = 36 + i*294
            body += f'<rect x="{x}" y="112" width="270" height="154" rx="16" fill="#151F33" stroke="#334662"/><circle cx="{x+29}" cy="143" r="16" fill="url(#accent)"/>'
            body += text(x+29, 147, str(i+1).zfill(2), 9, "#071321", 900, "middle") + text(x+20, 189, step[0], 12, TEXT, 900) + text(x+20, 217, step[1], 10, "#9EAFCA", 550)
            body += f'<path d="M{x+20} 238H{x+250}" stroke="#293C58"/>' + text(x+20, 255, ("STEP " if lang == "en" else "LANGKAH ") + str(i+1), 8, "#7F93B3", 850)
            if i < 3:
                body += f'<path d="M{x+275} 184h11m-4-4 4 4-4 4" fill="none" stroke="#5DD8E9" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>'
        return shell("Livia Panel workflow", "Four usage steps.", body, 300)

    if kind == "controls":
        body = text(42, 52, "PANEL CONTROLS" if lang == "en" else "KONTROL PANEL", 24, TEXT, 900)
        body += text(43, 77, "A touch-friendly interaction model." if lang == "en" else "Interaksi yang ramah sentuhan.", 13, MUTED, 500)
        symbols = ["●", "↔", "−", "×"]
        for i, item in enumerate(d["controls"]):
            x = 36 + i*294
            body += f'<rect x="{x}" y="112" width="270" height="150" rx="16" fill="#151F33" stroke="#334662"/><rect x="{x+18}" y="132" width="42" height="42" rx="12" fill="#1B3450"/>'
            body += text(x+39, 159, symbols[i], 19, "#FFA7B9" if i == 3 else CYAN, 900, "middle") + text(x+18, 201, item[0], 12, TEXT, 900) + text(x+18, 222, item[1], 9, "#A7B7D0", 800) + text(x+18, 244, item[2], 9, "#8297B7", 550)
        body += text(42, 289, "Close runs cleanup for features managed by the script." if lang == "en" else "Tombol X menjalankan cleanup fitur yang dikelola skrip.", 10, "#8094B4", 600)
        return shell("Livia Panel controls", "Panel interaction guide.", body, 320)

    if kind == "fly":
        body = text(42, 52, "FLY GUIDE" if lang == "en" else "PANDUAN FLY", 24, TEXT, 900)
        body += text(43, 77, "Joystick and camera pitch work together." if lang == "en" else "Arah joystick dan kemiringan kamera bekerja bersama.", 13, MUTED, 500)
        body += '<rect x="38" y="108" width="1124" height="155" rx="18" fill="#151F33" stroke="#334662"/>'
        body += '<circle cx="155" cy="182" r="49" fill="#10192A" stroke="#495B7B" stroke-width="2"/><circle cx="155" cy="182" r="30" fill="#202F4C" stroke="#5D6F92"/><circle cx="155" cy="182" r="13" fill="url(#accent)"/><path d="M155 140v15M155 209v15M113 182h15M182 182h15" stroke="#8B9BBC" stroke-width="2" stroke-linecap="round"/>'
        body += text(235, 151, "JOYSTICK", 12, CYAN, 900) + text(235, 176, d["fly"][0], 11, "#CBD6E8", 550) + text(235, 200, d["fly"][1], 10, "#879CB9", 500)
        body += '<rect x="610" y="129" width="118" height="104" rx="13" fill="#202C45" stroke="#3A4E70"/><path d="M634 184h70M669 151v66" stroke="#465B7D" stroke-width="1.3" stroke-dasharray="4 4"/><path d="M643 177l26-18 26 18" fill="none" stroke="#8B91FF" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/><circle cx="669" cy="185" r="7" fill="url(#accent)"/>'
        body += text(760, 151, "CAMERA PITCH", 12, CYAN, 900) + text(760, 176, d["fly"][1], 11, "#CBD6E8", 550) + text(760, 200, d["fly"][2], 10, "#879CB9", 500)
        body += f'<rect x="985" y="144" width="148" height="43" rx="10" fill="#303B55" stroke="#45597A"/>' + text(1059, 171, "RELEASE" if lang == "en" else "LEPAS", 11, TEXT, 900, "middle")
        body += text(986, 212, "Stop movement" if lang == "en" else "Berhenti bergerak", 10, "#879CB9", 600)
        body += text(42, 292, "Flight may vary by experience and can be corrected by server-authoritative physics." if lang == "en" else "Perilaku terbang dapat berbeda antar-game dan dapat dikoreksi server.", 10, "#8094B4", 600)
        return shell("Livia Panel Fly guide", "Joystick and camera movement diagram.", body, 320)

    if kind == "safety":
        body = text(42, 52, "USAGE NOTES" if lang == "en" else "CATATAN PENGGUNAAN", 24, TEXT, 900)
        body += text(43, 78, "Understand the limits before running a third-party script." if lang == "en" else "Pahami batasan sebelum menjalankan skrip pihak ketiga.", 13, MUTED, 500)
        for i, item in enumerate(d["safe"]):
            x = 36 + i*378
            body += f'<rect x="{x}" y="113" width="354" height="170" rx="17" fill="#151F33" stroke="#334662"/><rect x="{x+18}" y="132" width="40" height="40" rx="12" fill="#173447"/>'
            body += text(x+38, 158, str(i+1).zfill(2), 10, CYAN, 900, "middle") + text(x+18, 202, item[0], 13, TEXT, 900) + text(x+18, 231, item[1], 10, "#A1B2CC", 550)
            body += f'<path d="M{x+18} 253H{x+336}" stroke="#2A3B56"/>'
        body += text(42, 311, "Use only where client-side scripts are permitted." if lang == "en" else "Gunakan hanya pada lingkungan yang mengizinkan skrip sisi klien.", 10, "#8094B4", 600)
        return shell("Livia Panel safety notes", "Usage limitations and safety notes.", body, 340)

    raise ValueError(f"Unknown illustration type: {kind}")

def social_preview():
    body = text(58, 86, "LIVIA PANEL", 13, CYAN, 900)
    body += text(58, 159, "A cleaner way", 52, TEXT, 900, extra='letter-spacing="-1.8"')
    body += text(58, 219, "to control.", 52, "url(#accent)", 900, extra='letter-spacing="-1.8"')
    body += text(62, 263, "SPEED / JUMP / FLY / NO CLIP / FLASHLIGHT", 13, "#B2C1D8", 750)
    body += f'<rect x="58" y="302" width="210" height="40" rx="12" fill="url(#accent)"/>' + text(163, 327, "SINGLE-FILE LUA UI", 10, "#081321", 900, "middle")
    body += panel("en", 750, 65, .9, True)
    return shell("Livia Panel social preview", "A modern touch-first Roblox Lua utility panel.", body, 640)

if __name__ == "__main__":
    (ROOT / "brand.svg").write_text(logo(), encoding="utf-8")
    generated_count = 0
    for lang in ("id", "en"):
        for kind in ("banner", "preview", "features", "workflow", "controls", "fly", "safety"):
            artwork = render(lang, kind)
            if artwork.count("<text") < 8:
                raise RuntimeError("Generated illustration " + kind + "." + lang + ".svg appears incomplete.")
            (OUT / (kind + "." + lang + ".svg")).write_text(artwork, encoding="utf-8")
            generated_count += 1
            if kind == "fly":
                # A fresh filename avoids stale README image caches after an asset fix.
                (OUT / ("fly-guide." + lang + ".svg")).write_text(artwork, encoding="utf-8")
                generated_count += 1
    (OUT / "social-preview.svg").write_text(social_preview(), encoding="utf-8")
    generated_count += 1
    print("Generated " + str(generated_count) + " screenshot illustrations and one brand logo.")
