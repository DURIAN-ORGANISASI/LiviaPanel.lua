#!/usr/bin/env python3
"""Generate the bilingual Livia Panel README illustrations as dependency-free SVG."""
from html import escape
from pathlib import Path

OUT = Path(__file__).resolve().parent / "images"
OUT.mkdir(parents=True, exist_ok=True)
PANEL, CARD, STROKE = "#151b2e", "#1c2540", "#374461"
ACCENT, CYAN, TEXT, MUTED, ON, OFF = "#777cff", "#48c9e8", "#f5f7ff", "#a8b2d0", "#2dcc94", "#424d69"

STR = {
 "id": {"banner":"Panel Lua Roblox yang modern dan ramah sentuhan","desc":"Satu panel ringkas untuk gerakan dan pencahayaan.","ready":"PANEL SIAP","features":["Speed","Jump","Fly","No Clip","Flashlight"],"subs":["Kecepatan lari","Tinggi lompatan","Gerak di udara","Nonaktifkan tabrakan","Cahaya terarah"],"featTitle":"FITUR INTI","preview":"TAMPILAN BARU","workflow":["Salin skrip","Jalankan","Ketuk ON","Sesuaikan nilai"],"controls":["Ketuk","Geser","Minimize","Tutup"],"fly":"Joystick menentukan arah; kamera membantu gerak vertikal.","safety":["Efek sisi klien","Fisika server","Gunakan dengan izin"],"safetySub":["Perubahan lokal mungkin tidak direplikasi","Server dapat mengoreksi gerakan","Ikuti aturan pengalaman Roblox"]},
 "en": {"banner":"A modern, touch-friendly Roblox Lua panel","desc":"One compact panel for movement and lighting.","ready":"PANEL READY","features":["Speed","Jump","Fly","No Clip","Flashlight"],"subs":["Movement speed","Jump height","Air movement","Disable collisions","Directional light"],"featTitle":"CORE FEATURES","preview":"REFRESHED INTERFACE","workflow":["Copy the script","Run it","Tap ON","Adjust values"],"controls":["Tap","Drag","Minimize","Close"],"fly":"The joystick sets direction; camera pitch influences vertical movement.","safety":["Client-side effects","Server physics","Use with permission"],"safetySub":["Local changes may not replicate","The server may correct movement","Follow experience rules"]}
}
def t(x, y, text, size=16, color=TEXT, weight=700, anchor="start"):
    return f'<text x="{x}" y="{y}" font-family="Inter,Segoe UI,Arial,sans-serif" font-size="{size}" font-weight="{weight}" fill="{color}" text-anchor="{anchor}">{escape(text)}</text>'
def shell(w, h, title, body):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}" role="img" aria-label="{escape(title)}">'
            f'<title>{escape(title)}</title><defs><linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#0b1020"/><stop offset="1" stop-color="#25265b"/></linearGradient>'
            f'<linearGradient id="accent"><stop stop-color="{ACCENT}"/><stop offset="1" stop-color="{CYAN}"/></linearGradient></defs>'
            f'<rect width="{w}" height="{h}" fill="url(#bg)"/><circle cx="{int(w*.84)}" cy="{int(h*.18)}" r="{int(min(w,h)*.43)}" fill="{ACCENT}" opacity=".10"/>{body}</svg>')
def panel(lang, x, y, scale=1):
    d = STR[lang]
    b = [f'<g transform="translate({x} {y}) scale({scale * 0.877:.3f} {scale * 0.836:.3f})"><rect width="326" height="390" rx="20" fill="{PANEL}" stroke="{STROKE}"/>',
         '<path d="M0 20Q0 0 20 0H306Q326 0 326 20V62H0Z" fill="#202844"/>',
         f'<rect x="12" y="13" width="36" height="36" rx="11" fill="url(#accent)"/>', t(30,38,"L",21,"#fff",900,"middle"),
         t(59,29,"LIVIA PANEL",16,TEXT,900), t(60,46,"MOBILE UTILITY • V2.0",8,MUTED,700),
         f'<rect y="61" width="326" height="2" fill="url(#accent)"/>']
    vals = ["50", "100", "60", "", ""]
    for i, name in enumerate(d["features"]):
        yy = 72 + i*56
        b.append(f'<rect x="10" y="{yy}" width="306" height="49" rx="12" fill="{CARD}" stroke="{STROKE}"/>')
        b.append(t(22, yy+21, name.upper(), 11, TEXT, 900))
        b.append(t(22, yy+36, d["subs"][i], 8, MUTED, 500))
        if i < 3:
            b.append(f'<rect x="175" y="{yy+9}" width="54" height="30" rx="8" fill="#26314f"/>')
            b.append(t(202, yy+29, vals[i], 12, TEXT, 700, "middle"))
        on = i >= 3
        b.append(f'<rect x="244" y="{yy+9}" width="62" height="30" rx="9" fill="{ON if on else OFF}"/>')
        b.append(t(275, yy+28, "ON" if on else "OFF", 10, "#fff", 900, "middle"))
    b.extend([t(14,373,d["ready"],9,MUTED,700), f'<circle cx="307" cy="369" r="4" fill="{ON}"/>', '</g>'])
    return "".join(b)
def render(kind, lang):
    d = STR[lang]
    if kind == "banner":
        body = (f'<rect x="58" y="55" width="260" height="36" rx="18" fill="#fff" fill-opacity=".08"/>'
                + t(188,78,"LUA • ROBLOX • MOBILE",12,CYAN,900,"middle")
                + t(58,160,"LIVIA PANEL",54,TEXT,900)
                + f'<rect x="58" y="181" width="112" height="5" rx="2.5" fill="url(#accent)"/>'
                + t(58,225,d["banner"],24,TEXT,700) + t(58,263,d["desc"],16,MUTED,500)
                + t(58,323,"SPEED / JUMP / FLY / NO CLIP / FLASHLIGHT",13,TEXT,900)
                + panel(lang, 835, 18, .92))
        return shell(1280,420,d["banner"],body)
    if kind == "preview":
        body = t(54,59,d["preview"],28,TEXT,900) + panel(lang,62,100,1)
        for i in range(3):
            y = 155+i*95
            body += t(455,y,d["features"][i*2 if i<2 else 3],20,TEXT,900)
            body += t(455,y+28,d["subs"][i*2 if i<2 else 3],13,MUTED,500)
        return shell(1280,520,d["preview"],body)
    if kind == "features":
        body = t(48,55,d["featTitle"],27,TEXT,900)
        for i, name in enumerate(d["features"]):
            x = 40+i*248
            body += f'<rect x="{x}" y="108" width="224" height="238" rx="18" fill="{CARD}" stroke="{STROKE}"/><rect x="{x+20}" y="128" width="52" height="52" rx="15" fill="#283250"/>'
            body += t(x+20,218,name,17,TEXT,900) + t(x+20,246,d["subs"][i],11,MUTED,500)
            body += f'<rect x="{x+20}" y="292" width="126" height="30" rx="15" fill="#fff" fill-opacity=".07"/>'
            body += t(x+83,311,"VALUE" if i<3 else "ON / OFF",10,CYAN,900,"middle")
        return shell(1280,380,d["featTitle"],body)
    if kind in ("workflow","controls"):
        names = d["workflow"] if kind=="workflow" else d["controls"]
        title = ("GET STARTED" if lang=="en" else "MULAI") if kind=="workflow" else ("PANEL CONTROLS" if lang=="en" else "KONTROL PANEL")
        body = t(48,58,title,26,TEXT,900)
        for i, name in enumerate(names):
            x=42+i*302
            body += f'<rect x="{x}" y="116" width="278" height="154" rx="18" fill="{CARD}" stroke="{STROKE}"/><circle cx="{x+35}" cy="151" r="17" fill="url(#accent)"/>'
            body += t(x+35,156,str(i+1).zfill(2),10,"#fff",900,"middle") + t(x+22,201,name,17,TEXT,900)
            details = d["subs"][i] if kind=="workflow" else (d["safetySub"][i] if i < len(d["safetySub"]) else ("Tap to activate" if lang=="en" else "Ketuk untuk aktif"))
            body += t(x+22,232,details,10,MUTED,500)
        return shell(1280,320,title,body)
    if kind == "fly":
        title="FLY GUIDE" if lang=="en" else "PANDUAN FLY"
        body=t(48,59,title,27,TEXT,900)+t(48,100,d["fly"],14,MUTED,500)
        body += f'<rect x="48" y="126" width="1184" height="126" rx="20" fill="{CARD}" stroke="{STROKE}"/>'
        body += t(90,185,"JOYSTICK",16,CYAN,900)+t(90,216,"MOVE",11,MUTED,700)
        body += t(425,185,"CAMERA PITCH",16,CYAN,900)+t(425,216,"UP / DOWN",11,MUTED,700)
        body += t(850,185,"RELEASE",16,CYAN,900)+t(850,216,"STOP MOVEMENT",11,MUTED,700)
        return shell(1280,290,title,body)
    title = "USAGE NOTES" if lang=="en" else "CATATAN PENGGUNAAN"
    body=t(48,55,title,27,TEXT,900)
    for i,name in enumerate(d["safety"]):
        x=46+i*405
        body+=f'<rect x="{x}" y="108" width="374" height="170" rx="18" fill="{CARD}" stroke="{STROKE}"/>'
        body+=t(x+22,153,name,16,TEXT,900)+t(x+22,205,d["safetySub"][i],12,MUTED,500)
    return shell(1280,320,title,body)
if __name__ == "__main__":
    for language in ("id","en"):
        for kind in ("banner","preview","features","workflow","controls","fly","safety"):
            (OUT / f"{kind}.{language}.svg").write_text(render(kind,language), encoding="utf-8")
    social = (t(70,140,"LIVIA PANEL",54,TEXT,900)
              +t(70,190,"A modern, touch-friendly Roblox Lua panel",21,MUTED,600)
              +t(70,242,"SPEED / JUMP / FLY / NO CLIP / FLASHLIGHT",14,CYAN,900)
              +panel("en",820,108,1.08))
    (OUT / "social-preview.svg").write_text(shell(1280,640,"Livia Panel",social), encoding="utf-8")
    print("Generated 15 SVG illustration assets in docs/images/")
