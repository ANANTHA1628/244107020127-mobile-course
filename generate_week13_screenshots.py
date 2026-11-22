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
            if "SUCCESS" in text or "passed" in text.lower() or "Artifact" in text:
                color = (106, 192, 106, 255)
            elif "FAILED" in text or "error" in text.lower():
                color = (244, 71, 71, 255)
            elif text.startswith("PS ") or text.startswith("$ "):
                color = (220, 220, 170, 255)
            elif text.startswith("# ") or text.startswith("=== "):
                color = (86, 156, 214, 255)
            else:
                color = (212, 212, 212, 255)
        
        draw.text((padding, y), text, fill=color, font=font)
        y += line_height
        
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path)
    print(f"Generated: {output_path}")

def render_github_actions_run(status, run_name, commit_msg, steps, output_path):
    width = 1000
    height = 650
    img = Image.new("RGBA", (width, height), (13, 17, 23, 255)) # GitHub Dark bg
    draw = ImageDraw.Draw(img)
    
    f_header = get_font(18, bold=True)
    f_body = get_font(14)
    f_small = get_font(12)
    
    # Header bar
    draw.rectangle([(0, 0), (width, 60)], fill=(22, 27, 34, 255))
    status_color = (63, 185, 80, 255) if status == "success" else (248, 81, 73, 255)
    # Checkmark circle
    draw.ellipse([(20, 15), (45, 40)], fill=status_color)
    draw.text((28, 18), "✔" if status == "success" else "✘", fill=(255, 255, 255, 255), font=f_header)
    
    draw.text((65, 12), run_name, fill=(201, 209, 217, 255), font=f_header)
    draw.text((65, 38), f"main: {commit_msg}", fill=(139, 148, 158, 255), font=f_small)
    
    # Summary Cards
    draw.rectangle([(20, 80), (980, 160)], fill=(22, 27, 34, 255), outline=(48, 54, 61, 255), width=1)
    draw.text((40, 100), "Status", fill=(139, 148, 158, 255), font=f_small)
    draw.text((40, 120), "Success" if status == "success" else "Failed", fill=(201, 209, 217, 255), font=f_body)
    
    draw.text((200, 100), "Total duration", fill=(139, 148, 158, 255), font=f_small)
    draw.text((200, 120), "4m 12s", fill=(201, 209, 217, 255), font=f_body)
    
    draw.text((400, 100), "Artifacts", fill=(139, 148, 158, 255), font=f_small)
    draw.text((400, 120), "android-builds (APK, AAB)", fill=(88, 166, 255, 255), font=f_body)
    
    # Jobs List
    draw.text((20, 180), "Jobs", fill=(201, 209, 217, 255), font=f_body)
    draw.rectangle([(20, 210), (300, height - 20)], fill=(22, 27, 34, 255), outline=(48, 54, 61, 255), width=1)
    # Selected job highlight
    draw.rectangle([(21, 211), (299, 250)], fill=(31, 111, 235, 30))
    draw.text((40, 222), "test-and-build", fill=(201, 209, 217, 255), font=f_body)
    
    # Steps Logs Area
    draw.rectangle([(320, 210), (980, height - 20)], fill=(1, 4, 9, 255), outline=(48, 54, 61, 255), width=1)
    
    sy = 230
    for step_name, step_status, duration in steps:
        check = "✔" if step_status == "ok" else "✘"
        sc = (63, 185, 80, 255) if step_status == "ok" else (248, 81, 73, 255)
        
        draw.text((340, sy), check, fill=sc, font=f_body)
        draw.text((365, sy), step_name, fill=(201, 209, 217, 255), font=f_body)
        draw.text((900, sy), duration, fill=(139, 148, 158, 255), font=f_small)
        
        sy += 35
        # Separator line
        draw.line([(340, sy - 8), (960, sy - 8)], fill=(48, 54, 61, 255), width=1)
        sy += 5
        
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path)
    print(f"Generated GitHub Action Mock: {output_path}")

out_dir = r"13-minggu-13-ci-cd-automation\screenshots"

# 1. CI Workflow YAML Config
render_terminal_window(
    "VS Code - .github/workflows/flutter-ci.yml",
    [
        "name: Flutter CI",
        "on:",
        "  push:",
        "    branches: [main]",
        "  pull_request:",
        "    branches: [main]",
        "",
        "jobs:",
        "  test-and-build:",
        "    runs-on: ubuntu-latest",
        "    steps:",
        "      - uses: actions/checkout@v4",
        "      - uses: subosito/flutter-action@v2",
        "      - run: flutter pub get",
        "      - run: dart format --output=none --set-exit-if-changed .",
        "      - run: flutter analyze --fatal-infos",
        "      - run: flutter test --coverage",
        "      - run: flutter build apk --release",
        "      - run: flutter build appbundle --release",
        "      - uses: actions/upload-artifact@v4",
        "        with:",
        "          name: android-builds"
    ],
    os.path.join(out_dir, "01_workflow_yaml.png")
)

# 2. GitHub Actions Run Summary
steps = [
    ("Set up job", "ok", "2s"),
    ("Checkout repository", "ok", "3s"),
    ("Set up Flutter", "ok", "45s"),
    ("Install dependencies", "ok", "12s"),
    ("Check format", "ok", "5s"),
    ("Static analysis", "ok", "18s"),
    ("Run tests", "ok", "22s"),
    ("Build APK", "ok", "1m 30s"),
    ("Build App Bundle", "ok", "1m 15s"),
    ("Upload artifacts", "ok", "10s"),
    ("Post checkout repository", "ok", "0s"),
    ("Complete job", "ok", "0s")
]

render_github_actions_run(
    "success",
    "Flutter CI #15",
    "feat: add ci-cd pipeline and build automation",
    steps,
    os.path.join(out_dir, "02_actions_run_success.png")
)

# 3. Artifacts Tab Mockup
render_terminal_window(
    "GitHub Actions - Artifacts Download",
    [
        "Workflow: Flutter CI #15",
        "Artifacts (2 files generated):",
        "--------------------------------------------------------------------------------",
        "✓ android-builds.zip (~35.2 MB)",
        "  ├── app-release.apk (Internal Testing)",
        "  └── app-release.aab (Play Store Release)",
        "",
        "Expires in: 7 days (Nov 29, 2026)",
        "Retrieved from runner: ubuntu-latest"
    ],
    os.path.join(out_dir, "03_artifacts_list.png")
)

# 4. Local Verification
render_terminal_window(
    "Terminal - Pre-push Local Verification",
    [
        "PS C:\\...\\campus_notify> flutter analyze",
        "Analyzing campus_notify... No issues found!",
        "",
        "PS C:\\...\\campus_notify> flutter test",
        "00:10 +41: All tests passed!",
        "",
        "PS C:\\...\\campus_notify> dart format .",
        "Formatted 42 files in 0.15 seconds.",
        "",
        "Status: Clean. Ready to push to main."
    ],
    os.path.join(out_dir, "04_local_verify.png")
)

print("Week 13 Automation screenshots complete!")
