## 2026-07-04 - [CRITICAL] awk 명령어 인젝션 취약점 수정
**Vulnerability:** `extract-frames.sh` 스크립트에서 `awk` 명령어 실행 시 문자열 보간을 통해 변수(`$NUM_FRAMES`, `$DURATION`)를 직접 전달하여 임의의 명령어 실행(Command Injection)이 가능한 취약점이 발견되었습니다.
**Learning:** Bash 스크립트에서 사용자 입력 또는 외부 데이터가 포함될 수 있는 변수를 `awk` 내부의 문자열로 직접 삽입하면, 악의적인 값이 입력될 경우 명령어 실행 구조가 변경될 수 있습니다.
**Prevention:** `awk` 명령어 사용 시 문자열 보간(String interpolation) 대신 `-v` 플래그를 사용하여 변수를 안전하게 전달(예: `awk -v nf="$NUM_FRAMES" 'BEGIN { ... }'`)해야 합니다.
