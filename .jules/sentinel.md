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
## 2026-08-15 - [CRITICAL] 심볼릭 링크를 통한 임의 파일 덮어쓰기 취약점 수정
**Vulnerability:** 출력 경로($OUTPUT)를 검증 없이 디렉토리 생성 및 파일 저장에 사용하여 TOCTOU(Time-of-check to time-of-use) / 심볼릭 링크 공격을 통한 임의 파일 덮어쓰기가 가능함.
**Learning:** 심볼릭 링크 방어를 위해 [ -L ]을 사용할 때, 파일의 최종 경로만 확인하는 것은 불충분함. 부모 디렉토리 중 하나라도 심볼릭 링크라면 취약점이 발생할 수 있으므로, 재귀적으로 부모 디렉토리를 순회하며 검증해야 함.
**Prevention:** 출력 경로와 그 부모 디렉토리들을 루트나 현재 디렉토리에 도달할 때까지 역추적하여, 하나라도 심볼릭 링크인 경우 즉시 에러와 함께 종료하도록 검증 로직 추가.
## 2026-08-16 - [CRITICAL] 캐시 확인 전 심볼릭 링크 명시적 검사를 통한 임의 파일 덮어쓰기 방지
**Vulnerability:** 파일 캐시 확인 로직(`[ -f "$OUTPUT" ] && [ -s "$OUTPUT" ]`)에서 대상을 심볼릭 링크로 지정할 경우, 캐시 미스로 처리된 후 `yt-dlp` 등에 의해 심볼릭 링크 타겟 경로의 임의 파일이 덮어쓰여지는 TOCTOU 취약점이 발생할 수 있음.
**Learning:** `[ -f ]` 및 `[ -s ]` 검사는 심볼릭 링크를 해석하므로, 이를 우회하여 악의적인 덮어쓰기가 가능함. 심볼릭 링크 취약점을 완화할 때 `&& [ ! -L "$OUTPUT" ]`을 단순히 추가하면 심볼릭 링크를 캐시 미스로 간주하여 계속 실행되므로 임의 파일 덮어쓰기 취약점이 발생함. 부모 경로까지 검사하면 정상적인 시스템 심볼릭 링크(`\tmp` 등)까지 차단하여 기능 장애(Regression)가 발생할 수 있음.
**Prevention:** 캐시 존재 여부를 확인하기 전에, 출력 대상 경로 자체를 명시적으로 확인하고 심볼릭 링크인 경우 즉시 중단(`if [ -L "$OUTPUT" ]; then exit 1; fi`)하도록 구현하여야 함.
