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
## 2024-03-05 - CLI Example Highlighting
**Learning:** CLI 도움말이나 에러 메시지에 포함된 `Example:` 명령어 예시가 텍스트와 섞여 구분이 안 될 경우, 사용자가 복사 및 붙여넣기 하거나 시각적으로 명령어를 식별하기 어렵습니다. 청록색(Cyan) 등의 색상을 예시 명령어 부분에만 적용하면 예시라는 점이 시각적으로 명확해집니다.
**Action:** `download-reference.sh`, `extract-frames.sh`, `transcribe.sh` 스크립트에서 사용법(Usage) 출력 시 `Example:` 뒤의 실제 실행 명령어 문자열에 `CYAN` 색상을 적용하도록 개선했습니다. 이를 통해 사용자가 명령어를 더 직관적으로 파악할 수 있도록 돕습니다.
## 2024-03-06 - Input Validation and Path Traversal
**Learning:** Adding validation rules like `validate_safe_path` (which uses `realpath`/`readlink -f` to restrict I/O to safe directories like `/tmp`) effectively mitigates arbitrary file read/write vulnerabilities. However, when retrofitting validation into existing bash scripts, we must carefully consider how the script is invoked. If arguments are passed dynamically or derived, ensure the validation occurs early enough to block dangerous operations but doesn't break legitimate use cases or existing tests.
**Action:** When creating CLI tools that accept file paths as arguments, always add strict path validation. Ensure test scripts are updated to use safe paths (e.g., prefixing dummy filenames with `/tmp/`) to pass validation and avoid test failures.
