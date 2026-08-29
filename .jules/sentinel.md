## 2026-07-07 - Prevent Command Injection in awk via direct string interpolation
**Vulnerability:** Shell variables directly interpolated into an `awk` command string (e.g., `awk "BEGIN { print $VAR }"`) can lead to arbitrary command execution if the variable contains unescaped characters or quotes (e.g., `VAR='1; system("id");'`). This was found in `extract-frames.sh` where user-provided `NUM_FRAMES` was passed directly into `awk`.
**Learning:** This vulnerability existed because the script failed to validate the input structure before usage and improperly formed the `awk` command string using double quotes for interpolation.
**Prevention:** Always use the `-v` option (e.g., `awk -v var="$VAR"`) to pass variables safely into `awk` scripts. Furthermore, validate numeric inputs strictly using POSIX-compatible regex (e.g., `echo "$VAR" | grep -Eq '^[1-9][0-9]*$'`) before passing them to external commands or arithmetic evaluations.

## 2026-07-10 - yt-dlp 인자 주입(Argument Injection) 취약점 수정
**Vulnerability:** yt-dlp 실행 시 외부 입력 URL이 검증 없이 인자로 사용되어 악의적인 옵션 주입 가능
**Learning:** bash 스크립트에서 외부 입력을 명령어 인자로 넘길 때 하이픈(-)으로 시작하는 문자열이 옵션으로 오인될 수 있음
**Prevention:** 명령어와 인자 사이에 '--'를 명시하여 옵션의 끝을 알리고, 변수가 순수한 인자로만 처리되도록 방어해야 함

## 2026-07-11 - [CRITICAL] awk 명령어 문자열 보간(Command Injection) 취약점 수정
**Vulnerability:** `extract-frames.sh`의 `bc` 미설치 fallback 경로에서 `awk "BEGIN ... $NUM_FRAMES / $DURATION"` 형태로 셸 변수를 awk 프로그램 문자열에 직접 보간하여, 조작된 입력이 awk 코드로 해석될 수 있음.
**Learning:** awk 프로그램 본문은 고정된 작은따옴표 문자열로 유지하고, 동적 값은 `awk -v name="$value"`로 전달해야 코드와 데이터가 분리됨.
**Prevention:** `NUM_FRAMES`와 `DURATION`은 `-v nf="$NUM_FRAMES" -v dur="$DURATION"`로 전달하고, 회귀 테스트에서 직접 보간 패턴이 재등장하면 실패하도록 검사함.
## 2026-07-12 - [CRITICAL] Arithmetic injection via missing numeric validation
**Vulnerability:** The `extract-frames.sh` script does not validate the `NUM_FRAMES` argument, exposing arithmetic operations and `bc` to potential arithmetic or command injection via malformed input.
**Learning:** Numeric inputs passed from command line should be strictly validated before being passed to arithmetic evaluation or external tools.
**Prevention:** Validate numeric inputs strictly using POSIX-compatible regex like `echo "$VAR" | grep -Eq '^[1-9][0-9]*$'` prior to usage.

## 2026-07-11 - [CRITICAL] Whisper 모델 로딩 취약점 및 인자 주입 방지
**Vulnerability:** transcribe.sh에서 모델명(MODEL)을 검증 없이 사용해 임의의 로컬 PyTorch 모델(.pt)을 통한 Insecure Deserialization (Pickle RCE) 위험 및 CLI 인자 주입 취약점이 존재했습니다.
**Learning:** 외부 입력값을 모델명이나 파일 경로로 사용할 때는 화이트리스트 검증이 필수이며, 쉘 명령어에 변수를 넘길 때는 `--`를 사용해 옵션 파싱을 막아야 합니다.
**Prevention:** 허용된 모델명(tiny, base, small, medium, large)인지 확인하는 검증 로직을 추가하고, whisper 명령어의 인자 끝에 `--`를 적용했습니다.

## 2026-07-07 to 2026-07-13 - [Command and Option Injection in Bash Scripts]
**Vulnerability:** [Unvalidated arithmetic expressions in `bc`, direct `awk` program interpolation, and option injection in `yt-dlp` argument parsing]
**Learning:** [Keep arithmetic inputs strictly validated, keep the `awk` program fixed while passing values with `-v`, and use `--` before dynamic `yt-dlp` arguments; direct arbitrary command execution applies to the interpolated `awk` program case]
**Prevention:** [Validate positive-integer CLI inputs such as `NUM_FRAMES` with the shell-native `case` pattern used by `extract-frames.sh` (or an equivalent integer check), preserve valid positive-decimal `DURATION` values from `ffprobe`, use `-v` flag in `awk` for variables, and use `--` to signify end of options before dynamic arguments]
## 2024-07-13 - [Option Injection in Bash Utilities]
**Vulnerability:** User-controlled file paths were passed directly to bash utilities (dirname, mkdir, ls, basename) without the end-of-options separator (--), allowing for option injection if a path begins with a hyphen.
**Learning:** By default, utilities parse arguments starting with `-` as options. Using these without `--` before dynamic variables is a common command injection vector.
**Prevention:** Always use the `--` flag separator before passing user-controlled variables to standard CLI tools like `dirname`, `mkdir`, `basename`, and `ls`.

## 2024-05-24 - ANSI Escape Sequence Injection via Bash `printf "%b"`
**Vulnerability:** Bash scripts used `printf "%b"` to format strings with color codes, but directly interpolated untrusted user inputs (like URL or filename paths) into the format string or as arguments to `%b`.
**Learning:** If user input contains valid ANSI escape sequences (e.g., `\033[0;31mPWNED\033[0m`), `printf "%b"` will evaluate them, leading to Terminal output spoofing/injection.
**Prevention:** Separate the format string. Use `%b` exclusively for trusted ANSI color codes and `%s` for printing untrusted user inputs (e.g., `printf "%b%s%b\n" "${CYAN}Label: " "$VAR" "${NC}").

## 2026-08-05 - Actual terminal control bytes require output neutralization
**Vulnerability:** Moving an untrusted value from `%b` to `%s` prevents backslash text such as `\033` from being decoded, but it does not neutralize an actual ESC byte, C0/C1 control, CR/LF, Unicode line separator, or bidirectional override already present in the value. A terminal can still interpret those bytes, forge lines, move the cursor, clear output, or visually reorder a path.
**Learning:** Format-string separation and output neutralization are distinct controls. `%s` is necessary but not sufficient when the downstream component is an interactive terminal. Trusted color sequences may use `%b`; every untrusted value must first pass a centralized terminal renderer that converts control and format characters into visible escape notation.
**Prevention:** Route URL, path, model, and external-result values through `terminal_safe_text`/`terminal_print_value`; omit untrusted paths from the Python fallback; test with actual ESC, CR, LF, BEL, Unicode C1 CSI, line-separator, and right-to-left-override characters rather than only literal backslash sequences. Keep the regression suite failing if raw user-controlled control bytes reach any terminal sink.
## 2024-08-29 - [CRITICAL] 메타데이터 출력 시 터미널 이스케이프 주입 취약점 수정
**Vulnerability:** ffprobe에서 추출한 메타데이터(DURATION, RESOLUTION, FPS)를 직접 `%b` 포맷으로 터미널에 출력하여 터미널 이스케이프 시퀀스 주입 취약점이 존재했습니다.
**Learning:** 신뢰할 수 없는 외부 툴(ffprobe 등)에서 추출한 메타데이터도 사용자가 조작 가능한 입력으로 간주해야 하며, 반드시 `terminal_safe_text`로 무효화한 후 터미널의 가시성을 위해 `%s`를 통해 출력해야 함을 깨달았습니다.
**Prevention:** 향후 CLI 툴 개발 시 모든 외부 입력은 예외 없이 터미널 출력 전에 `terminal_safe_text`로 무효화하고 정적 테스트용 정규식에 포함시켜 검증해야 합니다.
