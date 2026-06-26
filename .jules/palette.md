## 2024-05-18 - CLI Dependency Blocking Help Menus
**Learning:** In bash CLI tools, parsing dependencies (like checking for ffmpeg) before argument evaluation creates a frustrating DX/UX issue where users cannot even read the `--help` manual unless they have fully installed the tool.
**Action:** Always parse `$1` for `-h` / `--help` at the absolute top of shell scripts before any system commands or dependency checks are evaluated.
