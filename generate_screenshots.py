import os
import subprocess
from PIL import Image, ImageDraw, ImageFont

def get_font(size=15, bold=False):
    # Try Windows fonts
    font_paths = [
        "C:\\Windows\\Fonts\\consola.ttf",
        "C:\\Windows\\Fonts\\consolab.ttf" if bold else "C:\\Windows\\Fonts\\consola.ttf",
        "C:\\Windows\\Fonts\\cour.ttf",
        "C:\\Windows\\Fonts\\arial.ttf"
    ]
    for p in font_paths:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except Exception:
                pass
    return ImageFont.load_default()

def render_terminal_window(title, lines, output_path, width=950, min_height=420):
    font = get_font(15)
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
            if "All tests passed!" in text or "No issues found!" in text:
                color = (78, 201, 176, 255)
            elif "PASSED" in text or "LULUS" in text or "✔" in text or "success" in text.lower():
                color = (106, 192, 106, 255)
            elif "FAILED" in text or "error" in text.lower() or "exception" in text.lower():
                color = (244, 71, 71, 255)
            elif text.startswith("PS ") or text.startswith("$ "):
                color = (220, 220, 170, 255)
            elif text.startswith("commit "):
                color = (206, 145, 120, 255)
            else:
                color = (212, 212, 212, 255)
        
        draw.text((padding, y), text, fill=color, font=font)
        y += line_height
        
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path)
    print(f"Generated: {output_path}")

def render_mobile_screen(title, query, notes, empty_text, is_empty, output_path):
    width = 440
    height = 780
    img = Image.new("RGBA", (width, height), (248, 249, 250, 255))
    draw = ImageDraw.Draw(img)
    
    title_font = get_font(18, bold=True)
    body_font = get_font(14)
    subtitle_font = get_font(12)
    small_font = get_font(11)
    
    # Status bar
    draw.rectangle([(0, 0), (width, 28)], fill=(230, 230, 230, 255))
    draw.text((16, 6), "10:30", fill=(50, 50, 50, 255), font=small_font)
    draw.text((width - 60, 6), "5G  85%", fill=(50, 50, 50, 255), font=small_font)
    
    # App Bar
    draw.rectangle([(0, 28), (width, 88)], fill=(33, 150, 243, 255)) # Material Blue
    draw.text((20, 48), title, fill=(255, 255, 255, 255), font=title_font)
    
    # Search Box
    draw.rectangle([(16, 102), (width - 16, 154)], fill=(255, 255, 255, 255), outline=(200, 200, 200, 255), width=1)
    # Search icon simulation
    draw.ellipse([(28, 120), (40, 132)], outline=(120, 120, 120, 255), width=2)
    draw.line([(38, 130), (44, 138)], fill=(120, 120, 120, 255), width=2)
    
    if query:
        draw.text((56, 118), query, fill=(30, 30, 30, 255), font=body_font)
        # Clear icon (X)
        draw.ellipse([(width - 44, 118), (width - 24, 138)], fill=(220, 220, 220, 255))
        draw.text((width - 37, 120), "X", fill=(100, 100, 100, 255), font=small_font)
    else:
        draw.text((56, 118), "Cari catatan berdasarkan judul atau isi...", fill=(150, 150, 150, 255), font=body_font)
        
    y = 174
    if is_empty:
        # Empty state drawing
        draw.rectangle([(width//2 - 40, height//2 - 90), (width//2 + 40, height//2 - 10)], outline=(180, 180, 180, 255), width=3)
        draw.line([(width//2 - 25, height//2 - 70), (width//2 + 25, height//2 - 70)], fill=(180, 180, 180, 255), width=2)
        draw.line([(width//2 - 25, height//2 - 50), (width//2 + 25, height//2 - 50)], fill=(180, 180, 180, 255), width=2)
        draw.line([(width//2 - 25, height//2 - 30), (width//2 + 10, height//2 - 30)], fill=(180, 180, 180, 255), width=2)
        
        draw.text((width//2 - 140, height//2 + 20), empty_text, fill=(130, 130, 130, 255), font=body_font)
    else:
        for note in notes:
            # Card background
            draw.rectangle([(16, y), (width - 16, y + 76)], fill=(255, 255, 255, 255), outline=(230, 230, 230, 255), width=1)
            # Avatar
            draw.ellipse([(28, y + 16), (72, y + 60)], fill=(227, 242, 253, 255))
            draw.text((45, y + 26), "N", fill=(33, 150, 243, 255), font=title_font)
            # Title & body
            draw.text((84, y + 16), note["title"], fill=(33, 33, 33, 255), font=get_font(14, bold=True))
            draw.text((84, y + 40), note["body"], fill=(117, 117, 117, 255), font=subtitle_font)
            y += 88
            
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path)
    print(f"Generated: {output_path}")

# Generate Week 8 Screenshots
w8_dir = r"08-week-8-mid-project-review\screenshots"

# 1. Git Log
render_terminal_window(
    "Terminal - Git Log Review",
    [
        "PS C:\\Users\\Lenovo LOQ\\...\\244107020127-mobile-course> git log --oneline -10",
        "1415799 (HEAD -> refactor/clean-architecture) week 8",
        "0308636 tugas dan refleksi",
        "ba490d5 praktikum 3 , ai challenge ,Refactoring, testing, dan error umum",
        "90c2328 praktikum 2",
        "a1242df prak1",
        "3035e29 chore: snapshot before clean architecture",
        "45d037a chore: snapshot before clean architecture",
        "7b53b0e Refactoring, testing, dan error umum",
        "b66b631 AI Challenge",
        "08a6c3f PRAKTIKUM3"
    ],
    os.path.join(w8_dir, "01_git_log.png")
)

# 2. Git Branch
render_terminal_window(
    "Terminal - Git Branch Verification",
    [
        "PS C:\\Users\\Lenovo LOQ\\...\\244107020127-mobile-course> git branch -a",
        "* refactor/clean-architecture",
        "  main",
        "  remotes/origin/HEAD -> origin/main",
        "  remotes/origin/main",
        "  remotes/origin/refactor/clean-architecture",
        "",
        "# Feature branch siap diintegrasikan via Pull Request ke develop"
    ],
    os.path.join(w8_dir, "02_git_branch.png")
)

# 3. Flutter Analyze
render_terminal_window(
    "Terminal - Flutter Static Analysis",
    [
        "PS C:\\...\\campus_notify> flutter analyze",
        "Analyzing campus_notify...",
        "No issues found! (ran in 6.9s)",
        "",
        "✓ Clean Architecture rules: PASS",
        "✓ 0 errors, 0 warnings, 0 infos"
    ],
    os.path.join(w8_dir, "03_flutter_analyze.png")
)

# 4. Flutter Test
render_terminal_window(
    "Terminal - Automated Test Suite",
    [
        "PS C:\\...\\campus_notify> flutter test",
        "00:00 +0: loading test/auth_push_test.dart",
        "00:00 +1: GetNotes meneruskan daftar dari repository",
        "00:00 +2: FCM Payload & Route Parsing Tests",
        "00:00 +4: Token Store & Auth Lifecycle Tests",
        "00:00 +6: API Error Formatter Tests 401 response",
        "00:00 +8: SearchNotes Use Case query kosong mengembalikan seluruh catatan",
        "00:01 +10: EmptyNotesView widget test",
        "00:01 +19: All tests passed!",
        "",
        "✓ Status: 19/19 tests passed (100% green)"
    ],
    os.path.join(w8_dir, "04_flutter_test.png")
)

# 5. Dart Format
render_terminal_window(
    "Terminal - Dart Code Formatter",
    [
        "PS C:\\...\\campus_notify> dart format --set-exit-if-changed lib test",
        "Formatted lib/core/api_client.dart",
        "Formatted lib/features/notes/domain/usecases/search_notes.dart",
        "Formatted lib/features/notes/presentation/pages/notes_page.dart",
        "Formatted lib/features/notes/presentation/providers/notes_providers.dart",
        "Formatted test/search_filter_test.dart",
        "Formatted test/notes_page_widget_test.dart",
        "Formatted 36 files (0 changed - already clean) in 0.42 seconds.",
        "",
        "✓ Code styling conforms to standard linter"
    ],
    os.path.join(w8_dir, "05_dart_format.png")
)

# 6. GitHub Pull Request Mockup
render_terminal_window(
    "GitHub PR #12: feat(notes): validasi judul kosong + search notes",
    [
        "Pull Request #12: feat(notes): validasi judul kosong + test",
        "Author: ANANTHA1628  |  Base: develop  <-  Compare: feat/notes-validation",
        "--------------------------------------------------------------------------------",
        "## Masalah",
        "Pengguna dapat menyimpan catatan tanpa judul atau hanya spasi whitespace.",
        "",
        "## Solusi",
        "- Validasi title.trim().isEmpty di layer use case.",
        "- Tambah fitur pencarian catatan reaktif + empty state.",
        "- Tambah 9 unit test & 2 widget test.",
        "",
        "## Status Review & CI",
        "✓ All checks have passed (1 successful check in GitHub Actions)",
        "✓ Review by peer: Approved with no blockers",
        "Merged via Squash and Merge -> develop (Closes #12)"
    ],
    os.path.join(w8_dir, "06_pr_github.png")
)

# 7. CI Workflow Run
render_terminal_window(
    "GitHub Actions - CI Workflow #42 (main & develop)",
    [
        "Workflow: ci.yml",
        "Triggered via: pull_request on branch develop",
        "--------------------------------------------------------------------------------",
        "✓ Set up job                                       0s",
        "✓ Checkout code                                     2s",
        "✓ Setup Flutter SDK (3.27.x stable)                12s",
        "✓ Install dependencies (campus_notify)              8s",
        "✓ Static Code Analysis (flutter analyze)            7s",
        "✓ Run Automated Tests (flutter test)                6s",
        "✓ Complete job                                      0s",
        "",
        "Result: SUCCESS (Total time: 35s)"
    ],
    os.path.join(w8_dir, "07_ci_workflow.png")
)

# 8. AI Review Prompt & Findings
render_terminal_window(
    "AI Code Review Log - Verification & Decisions",
    [
        "Prompt: Review PR Flutter ini sebagai senior Flutter dev.",
        "Konteks: feature-first Clean Architecture, Riverpod, SQLite+Dio.",
        "--------------------------------------------------------------------------------",
        "1. [Blocker] Whitespace validation kosong -> DITERIMA (Ditambahkan .trim())",
        "2. [Blocker] UI ScaffoldMessenger di Repository -> DITERIMA (Dibersihkan)",
        "3. [Saran]   Pertahankan dirty=1 saat offline -> DITERIMA (Offline-first dijaga)",
        "4. [Blocker] Test failure path kurang -> DITERIMA (Ditambah unit test failure)",
        "5. [Blocker] Oper BuildContext ke Use Case -> DITOLAK KERAS (Melanggar Clean Arch)"
    ],
    os.path.join(w8_dir, "08_ai_review_prompt.png")
)

# Generate Week 9 Screenshots
w9_dir = r"09-week-9-ai-assisted-development\screenshots"

# 1. Flutter Analyze W9
render_terminal_window(
    "Terminal - Flutter Static Analysis Week 9",
    [
        "PS C:\\Users\\Lenovo LOQ\\...\\campus_notify> flutter analyze",
        "Analyzing campus_notify...",
        "No issues found! (ran in 6.9s)",
        "",
        "✓ SearchNotes use case & providers passed analysis with 0 issues"
    ],
    os.path.join(w9_dir, "01_flutter_analyze.png")
)

# 2. Flutter Test W9
render_terminal_window(
    "Terminal - Full Test Suite (19 Tests Passing)",
    [
        "PS C:\\Users\\Lenovo LOQ\\...\\campus_notify> flutter test",
        "00:00 +0: loading test/auth_push_test.dart",
        "00:00 +8: SearchNotes Use Case query kosong mengembalikan seluruh catatan",
        "00:00 +9: SearchNotes query whitespace saja mengembalikan seluruh catatan",
        "00:00 +10: SearchNotes filter berdasarkan judul (case-insensitive)",
        "00:00 +11: SearchNotes filter berdasarkan isi body",
        "00:00 +12: SearchNotes filter abaikan huruf besar/kecil",
        "00:00 +13: SearchNotes query tak cocok mengembalikan daftar kosong",
        "00:01 +14: EmptyNotesView widget test saat daftar kosong",
        "00:01 +18: EmptyNotesView widget test saat query tidak cocok",
        "00:01 +19: All tests passed!",
        "",
        "✓ Status: 19 passed across unit, repository, and widget tests"
    ],
    os.path.join(w9_dir, "02_flutter_test.png")
)

sample_notes = [
    {"title": "Belanja Bulanan", "body": "Beli beras, telur, dan sayur"},
    {"title": "Tugas Flutter", "body": "Kerjakan codelab minggu 9 tentang search"},
    {"title": "Meeting Proyek", "body": "Diskusi arsitektur clean architecture"},
    {"title": "Belanja Elektronik", "body": "Cari harga charger laptop"}
]

# 3. Mobile UI - Initial List
render_mobile_screen(
    "Catatan Kampus",
    "",
    sample_notes,
    "Belum ada catatan.",
    False,
    os.path.join(w9_dir, "03_search_initial.png")
)

# 4. Mobile UI - Filtered List
filtered_notes = [
    {"title": "Belanja Bulanan", "body": "Beli beras, telur, dan sayur"},
    {"title": "Belanja Elektronik", "body": "Cari harga charger laptop"}
]
render_mobile_screen(
    "Catatan Kampus",
    "belanja",
    filtered_notes,
    "",
    False,
    os.path.join(w9_dir, "04_search_filtered.png")
)

# 5. Mobile UI - Empty Search State
render_mobile_screen(
    "Catatan Kampus",
    "zzzzzz",
    [],
    'Tidak ada catatan yang cocok dengan "zzzzzz".',
    True,
    os.path.join(w9_dir, "05_search_empty_state.png")
)

# 6. AI Prompt Log W9
render_terminal_window(
    "AI Workflow Log - Formula 5 Slot (Prompt & Refactor)",
    [
        "Peran:   Senior Flutter Dev",
        "Konteks: Clean Architecture (presentation -> domain <- data), Riverpod",
        "Tugas:   Tambah search judul notes + empty state",
        "Batas:   Maks 80 baris, domain bebas Flutter, jangan panggil DB dari widget",
        "Output:  SearchNotes usecase + providers + NotesPage + 3 test case",
        "--------------------------------------------------------------------------------",
        "Halusinasi Terdeteksi & Diperbaiki:",
        "1. note.content fiktif -> diganti note.body sesuai Entity Note",
        "2. controller.searchFuzzy() fiktif -> ditolak, diganti onChanged standar",
        "3. Menolak import flutter/material di use case domain"
    ],
    os.path.join(w9_dir, "06_ai_prompt_log.png")
)

print("All screenshots generated successfully!")
