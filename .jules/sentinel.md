## 2025-07-02 - Fix Command and Option Injection in Analysis Scripts
**Vulnerability:**
1. `NUM_FRAMES` argument in `extract-frames.sh` lacked numeric validation before being evaluated and was interpolated into awk scripts directly.
2. `URL` argument in `download-reference.sh` was passed to `yt-dlp` without `--`, enabling option injection.

**Learning:**
External CLI arguments (like `$URL` or `$NUM_FRAMES`) mapped to shell scripts can introduce injection vectors if not structurally isolated or regex-validated before hitting downstream interpreters (like `bc`, `awk`, or `yt-dlp`).

**Prevention:**
1. Validate numeric inputs strictly against regex (`^[1-9][0-9]*$`).
2. Map bash variables into awk using the `-v` flag to separate code from data.
3. Always use `--` in wrappers around CLI tools to cleanly separate options from operands.
