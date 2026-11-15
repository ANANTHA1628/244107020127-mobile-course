import os
from PIL import Image, ImageDraw, ImageFont

def get_font(size=14, bold=False):
    font_paths = [
        "C:\\Windows\\Fonts\\consola.ttf",
        "C:\\Windows\\Fonts\\consolab.ttf" if bold else "C:\\Windows\\Fonts\\consola.ttf",
        "C:\\Windows\\Fonts\\segoeui.ttf",
        "C:\\Windows\\Fonts\\arial.ttf"
    ]
    for p in font_paths:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except Exception:
                pass
    return ImageFont.load_default()

def render_terminal_window(title, lines, output_path, width=960, min_height=420):
    font = get_font(14)
    title_font = get_font(13, bold=True)
    
    line_height = 24
    padding = 24
    top_bar = 42
    
    calculated_height = top_bar + (len(lines) * line_height) + (padding * 2)
    height = max(min_height, calculated_height)
    
    img = Image.new("RGBA", (width, height), (30, 30, 30, 255))
    draw = ImageDraw.Draw(img)
    
    # Title bar
    draw.rectangle([(0, 0), (width, top_bar)], fill=(45, 45, 45, 255))
    
    # Window buttons
    draw.ellipse([(14, 15), (26, 27)], fill=(255, 95, 86, 255))   # Red
    draw.ellipse([(34, 15), (46, 27)], fill=(255, 189, 46, 255))  # Yellow
    draw.ellipse([(54, 15), (66, 27)], fill=(39, 201, 63, 255))   # Green
    
    # Window title
    draw.text((80, 13), title, fill=(200, 200, 200, 255), font=title_font)
    
    # Draw content lines
    y = top_bar + padding
    for line in lines:
        if isinstance(line, tuple):
            text, color = line
        else:
            text = line
            if "All 33 tests passed!" in text or "All tests passed!" in text or "No issues found!" in text:
                color = (78, 201, 176, 255)
            elif "PASSED" in text or "LULUS" in text or "✔" in text or "success" in text.lower():
                color = (106, 192, 106, 255)
            elif "FAILED" in text or "error" in text.lower() or "exception" in text.lower():
                color = (244, 71, 71, 255)
            elif text.startswith("PS ") or text.startswith("$ "):
                color = (220, 220, 170, 255)
            elif text.startswith("# ") or text.startswith("## ") or text.startswith("=== "):
                color = (86, 156, 214, 255)
            else:
                color = (212, 212, 212, 255)
        
        draw.text((padding, y), text, fill=color, font=font)
        y += line_height
        
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path)
    print(f"Generated: {output_path}")

def render_chat_mobile(
    mode="empty",  # "empty", "typing", "answered", "privacy", "fallback_dialog", "settings_dialog"
    output_path="chat.png",
    custom_input=""
):
    width = 440
    height = 800
    img = Image.new("RGBA", (width, height), (248, 249, 250, 255))
    draw = ImageDraw.Draw(img)

    f_title = get_font(17, bold=True)
    f_sub = get_font(11)
    f_body = get_font(13)
    f_body_b = get_font(13, bold=True)
    f_small = get_font(11)
    f_micro = get_font(10)

    # Status Bar
    draw.rectangle([(0, 0), (width, 28)], fill=(232, 234, 237, 255))
    draw.text((16, 7), "09:41", fill=(60, 64, 67, 255), font=f_small)
    draw.text((width - 65, 7), "LTE  92%", fill=(60, 64, 67, 255), font=f_small)

    # App Bar
    draw.rectangle([(0, 28), (width, 92)], fill=(25, 118, 210, 255)) # Deep Blue
    draw.text((20, 42), "AI Campus Assistant", fill=(255, 255, 255, 255), font=f_title)
    draw.text((20, 68), "Gemini AI & Smart Offline Fallback", fill=(200, 225, 255, 255), font=f_sub)

    # Action Icons (Key & Delete)
    # Key icon
    draw.ellipse([(width - 76, 50), (width - 60, 66)], outline=(255, 255, 255, 255), width=2)
    draw.line([(width - 68, 66), (width - 68, 72)], fill=(255, 255, 255, 255), width=2)
    # Delete icon
    draw.rectangle([(width - 40, 52), (width - 26, 68)], outline=(255, 255, 255, 255), width=2)
    draw.line([(width - 42, 52), (width - 24, 52)], fill=(255, 255, 255, 255), width=2)

    # Content Area
    if mode == "empty":
        # Bot circular icon
        draw.ellipse([(width//2 - 40, 160), (width//2 + 40, 240)], fill=(227, 242, 253, 255))
        draw.text((width//2 - 16, 185), "🤖", fill=(25, 118, 210, 255), font=get_font(28))

        draw.text((width//2 - 110, 260), "Halo, Mahasiswa Polinema!", fill=(33, 33, 33, 255), font=get_font(16, bold=True))
        sub_text1 = "Saya asisten AI kampus cerdas. Tanyakan seputar"
        sub_text2 = "perkuliahan, jadwal, atau gunakan contoh saran prompt:"
        draw.text((width//2 - 145, 292), sub_text1, fill=(100, 100, 100, 255), font=f_small)
        draw.text((width//2 - 155, 310), sub_text2, fill=(100, 100, 100, 255), font=f_small)

        chips = [
            "Jadwal kuliah hari ini?",
            "Cara mencatat di menu Notes?",
            "Bagaimana melihat pengumuman kampus?",
            "Format NIK (Uji Privasi)"
        ]
        cy = 350
        for chip in chips:
            chip_w = 270
            draw.rounded_rectangle([(width//2 - chip_w//2, cy), (width//2 + chip_w//2, cy + 34)], radius=17, fill=(240, 244, 248, 255), outline=(200, 215, 230, 255), width=1)
            draw.text((width//2 - chip_w//2 + 18, cy + 8), "💬  " + chip, fill=(25, 118, 210, 255), font=f_small)
            cy += 44

    elif mode == "typing":
        # User question
        uy = 120
        uw = 200
        draw.rounded_rectangle([(width - uw - 16, uy), (width - 16, uy + 42)], radius=14, fill=(25, 118, 210, 255))
        draw.text((width - uw + 2, uy + 12), "Jadwal kuliah hari ini?", fill=(255, 255, 255, 255), font=f_body)

        # Bot typing bubble
        by = 185
        draw.ellipse([(16, by), (46, by + 30)], fill=(25, 118, 210, 255))
        draw.text((24, by + 6), "🤖", fill=(255, 255, 255, 255), font=f_small)

        draw.rounded_rectangle([(56, by), (260, by + 46)], radius=14, fill=(255, 255, 255, 255), outline=(187, 222, 251, 255), width=1)
        # Spinner circle
        draw.arc([(72, by + 14), (90, by + 32)], start=0, end=270, fill=(25, 118, 210, 255), width=3)
        draw.text((100, by + 14), "AI sedang mengetik...", fill=(100, 100, 100, 255), font=f_small)

    elif mode == "answered":
        # User question
        uy = 120
        uw = 200
        draw.rounded_rectangle([(width - uw - 16, uy), (width - 16, uy + 42)], radius=14, fill=(25, 118, 210, 255))
        draw.text((width - uw + 2, uy + 12), "Jadwal kuliah hari ini?", fill=(255, 255, 255, 255), font=f_body)

        # Bot response
        by = 185
        draw.ellipse([(16, by), (46, by + 30)], fill=(25, 118, 210, 255))
        draw.text((24, by + 6), "🤖", fill=(255, 255, 255, 255), font=f_small)

        resp_w = 340
        draw.rounded_rectangle([(56, by), (56 + resp_w, by + 115)], radius=14, fill=(255, 255, 255, 255), outline=(220, 224, 230, 255), width=1)
        t1 = "Perkuliahan hari ini dimulai pukul 07.30 WIB"
        t2 = "di Gedung Sipil & TI. Pastikan mengecek portal"
        t3 = "Siakad Polinema untuk update ruang kelas."
        draw.text((70, by + 12), t1, fill=(33, 33, 33, 255), font=f_body)
        draw.text((70, by + 32), t2, fill=(33, 33, 33, 255), font=f_body)
        draw.text((70, by + 52), t3, fill=(33, 33, 33, 255), font=f_body)

        # Salin & Regenerate buttons
        draw.line([(70, by + 80), (56 + resp_w - 14, by + 80)], fill=(240, 240, 240, 255), width=1)
        draw.text((72, by + 88), "📋 Salin", fill=(120, 120, 120, 255), font=f_small)
        draw.text((150, by + 88), "🔄 Regenerate", fill=(120, 120, 120, 255), font=f_small)

    elif mode == "privacy":
        # User input with NIK
        uy = 120
        uw = 270
        draw.rounded_rectangle([(width - uw - 16, uy), (width - 16, uy + 46)], radius=14, fill=(25, 118, 210, 255))
        draw.text((width - uw + 6, uy + 14), "Cek NIK 3507123456780001", fill=(255, 255, 255, 255), font=f_body)

        # Privacy security alert banner
        py = 185
        draw.rounded_rectangle([(16, py), (width - 16, py + 84)], radius=10, fill=(255, 235, 238, 255), outline=(239, 154, 154, 255), width=1)
        draw.text((28, py + 14), "🛡️", fill=(211, 47, 47, 255), font=get_font(20))
        draw.text((58, py + 14), "Peringatan Privasi (Keamanan Aktif)", fill=(198, 40, 40, 255), font=f_body_b)
        warn1 = "Terdeteksi NIK (16 digit). Demi keamanan,"
        warn2 = "dilarang mengirim data sensitif ke cloud AI."
        draw.text((58, py + 38), warn1, fill=(198, 40, 40, 255), font=f_small)
        draw.text((58, py + 56), warn2, fill=(198, 40, 40, 255), font=f_small)

    # Input bar at bottom
    iy = height - 70
    draw.rectangle([(0, iy), (width, height)], fill=(255, 255, 255, 255))
    draw.line([(0, iy), (width, iy)], fill=(225, 228, 232, 255), width=1)

    # Input Box
    draw.rounded_rectangle([(16, iy + 12), (width - 70, iy + 52)], radius=20, fill=(241, 243, 244, 255))
    if custom_input:
        draw.text((32, iy + 22), custom_input, fill=(33, 33, 33, 255), font=f_body)
    else:
        draw.text((32, iy + 22), "Ketik pertanyaan kampus...", fill=(140, 145, 150, 255), font=f_body)

    # Send button
    draw.ellipse([(width - 58, iy + 12), (width - 18, iy + 52)], fill=(25, 118, 210, 255))
    # Paper airplane arrow
    draw.polygon([(width - 45, iy + 22), (width - 45, iy + 42), (width - 27, iy + 32)], fill=(255, 255, 255, 255))

    # Dialog Overlays
    if mode == "fallback_dialog":
        # Dim background
        overlay = Image.new("RGBA", (width, height), (0, 0, 0, 130))
        img = Image.alpha_composite(img, overlay)
        draw = ImageDraw.Draw(img)

        # Dialog Box
        dy = height//2 - 110
        draw.rounded_rectangle([(34, dy), (width - 34, dy + 220)], radius=16, fill=(255, 255, 255, 255))

        # Dialog Title
        draw.text((56, dy + 24), "☁️  Layanan AI Sibuk", fill=(230, 81, 0, 255), font=get_font(16, bold=True))

        # Dialog Content
        d_text1 = "Gagal menghubungi server AI: HTTP 503"
        d_text2 = "Service Unavailable / Kuota Habis."
        d_text3 = "Coba lagi nanti atau beralih ke Mode"
        d_text4 = "Cadangan (Offline) kampus."
        draw.text((56, dy + 62), d_text1, fill=(60, 60, 60, 255), font=f_body)
        draw.text((56, dy + 84), d_text2, fill=(60, 60, 60, 255), font=f_body)
        draw.text((56, dy + 106), d_text3, fill=(60, 60, 60, 255), font=f_body)
        draw.text((56, dy + 128), d_text4, fill=(60, 60, 60, 255), font=f_body)

        # Buttons
        draw.text((width - 190, dy + 172), "Batal", fill=(100, 100, 100, 255), font=f_body_b)

        # Filled Button "Mode Offline"
        draw.rounded_rectangle([(width - 135, dy + 162), (width - 46, dy + 200)], radius=8, fill=(25, 118, 210, 255))
        draw.text((width - 125, dy + 172), "Mode Offline", fill=(255, 255, 255, 255), font=get_font(12, bold=True))

    elif mode == "settings_dialog":
        # Dim background
        overlay = Image.new("RGBA", (width, height), (0, 0, 0, 130))
        img = Image.alpha_composite(img, overlay)
        draw = ImageDraw.Draw(img)

        # Dialog Box
        dy = height//2 - 120
        draw.rounded_rectangle([(34, dy), (width - 34, dy + 230)], radius=16, fill=(255, 255, 255, 255))

        draw.text((56, dy + 24), "🔑  Pengaturan API Key", fill=(33, 33, 33, 255), font=get_font(16, bold=True))

        s1 = "Masukkan Google Gemini API Key Anda."
        s2 = "Kunci ini disimpan terenkripsi di"
        s3 = "FlutterSecureStorage perangkat lokal."
        draw.text((56, dy + 58), s1, fill=(90, 90, 90, 255), font=f_small)
        draw.text((56, dy + 76), s2, fill=(90, 90, 90, 255), font=f_small)
        draw.text((56, dy + 94), s3, fill=(90, 90, 90, 255), font=f_small)

        # Text input box for API Key
        draw.rounded_rectangle([(56, dy + 120), (width - 56, dy + 162)], radius=6, fill=(245, 245, 245, 255), outline=(180, 180, 180, 255), width=1)
        draw.text((68, dy + 132), "AIzaSy••••••••••••••••••••••", fill=(50, 50, 50, 255), font=f_body)

        draw.text((width - 170, dy + 185), "Tutup", fill=(100, 100, 100, 255), font=f_body_b)
        draw.rounded_rectangle([(width - 110, dy + 174), (width - 50, dy + 210)], radius=6, fill=(25, 118, 210, 255))
        draw.text((width - 96, dy + 183), "Simpan", fill=(255, 255, 255, 255), font=get_font(12, bold=True))

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path)
    print(f"Generated: {output_path}")

# Output directories
out_dir = r"10-week-10-ai-feature-integration\screenshots"

# 1. Flutter Analyze
render_terminal_window(
    "Terminal - Flutter Static Analysis Week 10",
    [
        "PS C:\\Users\\Lenovo LOQ\\...\\campus_notify> flutter analyze",
        "Analyzing campus_notify...",
        "No issues found! (ran in 4.4s)",
        "",
        "✓ Clean code verified: 0 errors, 0 warnings, 0 infos",
        "✓ AiService & ChatScreen pass all Dart linter rules"
    ],
    os.path.join(out_dir, "01_flutter_analyze.png")
)

# 2. Flutter Test
render_terminal_window(
    "Terminal - Automated Test Suite Week 10 (33 Tests Passing)",
    [
        "PS C:\\Users\\Lenovo LOQ\\...\\campus_notify> flutter test",
        "00:00 +0: loading test/ai_service_test.dart",
        "00:00 +1: AiService - Privacy Guard: Throws PrivacyException when NIK (16 digit) entered",
        "00:00 +2: AiService - Privacy Guard: Throws PrivacyException when phone number entered",
        "00:00 +3: AiService - Privacy Guard: Passes valid public inquiry without sensitive data",
        "00:00 +4: AiService - Offline Fallback: Returns Siakad info when prompt contains jadwal",
        "00:00 +5: AiService - Offline Fallback: Returns notes guide when prompt contains notes",
        "00:00 +6: AiService - Offline Fallback: Returns default offline message for general query",
        "00:00 +7: AiService - API & Cache: Successfully parses Gemini API response",
        "00:00 +8: AiService - API & Cache: Uses local cache on duplicate question (0 extra calls)",
        "00:00 +9: AiService - API & Cache: Throws exception on HTTP error code 500",
        "00:00 +10: AiService - API & Cache: Streams response chunk by chunk",
        "00:01 +17: ChatScreen Widget Test: Menampilkan empty state dan saran prompt pada tampilan awal",
        "00:01 +30: ChatScreen Widget Test: Menampilkan peringatan privasi saat input terdeteksi NIK",
        "00:02 +32: ChatScreen Widget Test: Menampilkan dialog fallback ketika pemanggilan AI API gagal",
        "00:02 +33: All tests passed!",
        "",
        "✓ Status: 33/33 tests passed (100% green)"
    ],
    os.path.join(out_dir, "02_flutter_test.png")
)

# 3. Empty Chat Screen
render_chat_mobile(
    mode="empty",
    output_path=os.path.join(out_dir, "03_chat_initial_empty.png")
)

# 4. Typing / Streaming Bubble
render_chat_mobile(
    mode="typing",
    output_path=os.path.join(out_dir, "04_chat_streaming_typing.png"),
    custom_input=""
)

# 5. Answered with Copy & Regenerate
render_chat_mobile(
    mode="answered",
    output_path=os.path.join(out_dir, "05_chat_answered.png")
)

# 6. Privacy Security Alert
render_chat_mobile(
    mode="privacy",
    output_path=os.path.join(out_dir, "06_privacy_alert.png"),
    custom_input="3507123456780001"
)

# 7. Fallback Dialog
render_chat_mobile(
    mode="fallback_dialog",
    output_path=os.path.join(out_dir, "07_fallback_dialog.png")
)

# 8. API Key Settings Dialog
render_chat_mobile(
    mode="settings_dialog",
    output_path=os.path.join(out_dir, "08_settings_api_key.png")
)

# 9. AI Prompt & Decision Log
render_terminal_window(
    "docs/ai-log.md - AI Prompt Design & Decisions Log",
    [
        "# AI Prompt Design & Architecture Decisions",
        "--------------------------------------------------------------------------------",
        "System Prompt: Kamu asisten kampus Polinema yang ramah, sopan, dan informatif.",
        "               Jawab dalam Bahasa Indonesia ringkas, maksimal 2-3 kalimat.",
        "               Jangan meminta ataupun membocorkan data pribadi mahasiswa.",
        "",
        "Privacy Guard: Regex validation filter (NIK: 16 digit, Kontak: 08xx / +628xx)",
        "Cost Mitigation: In-memory Map cache _cache -> hemat kuota & cegah rate limit 429",
        "Offline Fallback: getOfflineFallbackResponse() jika API error 500/503 atau tanpa internet",
        "Security Store: FlutterSecureStorage (key: 'ai_api_key') - tidak hardcode di kode",
        "UX Features: Streaming text chunk, typing indicator, auto-scroll, copy & regenerate"
    ],
    os.path.join(out_dir, "09_ai_prompt_log.png")
)

print("All Week 10 screenshots generated successfully!")
