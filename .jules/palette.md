## 2023-11-20 - [CLI UX Enhancement] ANSI Color Codes for Bash Scripts
**Learning:** CLI 플러그인(특히 Bash 스크립트 기반)에서 시각적 피드백이 부족하면 사용자가 에러나 진행 상황을 파악하기 어렵다는 점을 배웠습니다. 에러 메시지는 빨간색, 성공은 초록색, 중요한 정보나 진행 상황은 청록색이나 노란색으로 시각적 구분을 주어 터미널 환경에서도 직관적인 UX를 제공하는 것이 중요합니다.
**Action:** `download-reference.sh`, `extract-frames.sh`, `transcribe.sh` 스크립트의 출력 메시지에 일관된 ANSI 색상 코드(RED, GREEN, YELLOW, CYAN, NC 등)를 추가하여 터미널 내 가독성과 정보 인지 속도를 개선합니다. 향후 새로운 스크립트 작성 시에도 기본으로 컬러 피드백을 적용할 것입니다.
## 2024-10-18 - Help Output Before Dependencies
**Learning:** CLI tools should provide help flags (`-h`, `--help`) without requiring system dependencies to be installed first. Users may need documentation to understand what dependencies are even needed, so help output should be the very first step in script execution.
**Action:** Always parse argument flags like `-h` and `--help` immediately after variable initialization and before checking for required system tools like `ffmpeg` or `yt-dlp`.
## 2024-10-19 - Consistent CLI Examples and Error Context
**Learning:** Users often struggle with CLI syntax when error messages only provide abstract usage formats (e.g., `<audio_path> [model]`). Additionally, runtime errors (like 'file not found') frequently lack the recovery context needed to help the user correct their command.
**Action:** Always include concrete, executable `Example:` lines in both `--help` outputs and validation error messages. Furthermore, ensure that the full usage block is printed not just for missing arguments, but also for runtime input validation failures like missing files.
## 2025-02-28 - 의존성 누락 오류 메시지 개선
**Learning:** CLI 환경에서 오류 원인(Red)과 실행 가능한 해결책(Cyan)의 색상을 분리하면 사용자의 인지 부하가 감소하고 문제 해결이 빨라진다는 것을 확인함.
**Action:** 앞으로 오류 메시지를 작성할 때는 항상 문제 상태와 조치 사항을 분리하여 다른 색상으로 명확하게 안내할 것.
## 2025-02-28 - Examples in CLI Output Should Be Actionable and Noticeable
**Learning:** Usage examples (like `Example: ./script arg1 arg2`) can easily get lost in text-heavy CLI output. When users encounter an error and just want to quickly see how to run the command correctly, they scan for executable strings.
**Action:** Always apply syntax highlighting (e.g., using CYAN color) to the concrete command part of usage examples to make them stand out visually as copy-pasteable strings.
## 2026-08-11 - [CLI UX Enhancement] 의존성 자동 설치 후 PATH 재확인 안내 추가
**Learning:** CLI 스크립트에서 누락된 의존성을 자동 설치하더라도, 설치 경로가 사용자의 시스템 환경 변수($PATH)에 포함되어 있지 않으면 이후 실행 단계에서 계속 실패하게 됩니다. 이는 사용자에게 큰 혼란을 줍니다.
**Action:** 자동 설치 시도 직후에 해당 실행 파일이 `$PATH`에서 접근 가능한지 즉시 재확인하는 로직을 추가했습니다. 만약 접근이 불가하다면, 사용자에게 `$PATH` 환경 변수 설정이나 수동 설치가 필요하다는 명확하고 구체적인 오류 안내 메시지를 제공하여 문제 해결을 돕도록 해야 합니다.

## 2025-02-28 - Explicit and Targeted Error Messages for Missing Arguments
**Learning:** Generic error messages like "Missing required argument(s)" are less helpful than pointing out the exact missing argument (e.g., `<url>`). Also, when implementing CLI argument parsing, required arguments must be validated before optional arguments. Otherwise, the script might error out on an invalid optional argument even when the fundamental required argument is missing, confusing the user.
**Action:** Replaced generic missing argument errors with specific targeting (e.g., `Error: Missing required argument: <url>`) using explicit `if/elif` blocks in `download-reference.sh` and `extract-frames.sh`. Reordered validation in `transcribe.sh` to check for `<audio_path>` before verifying the optional `[model]`.
