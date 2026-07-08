## 2026-07-08 - [CRITICAL] awk 명령어 문자열 보간법(Command Injection) 취약점 수정
**Vulnerability:** `awk` 명령어 사용 시 쉘 변수(`$NUM_FRAMES`, `$DURATION`)를 문자열에 직접 삽입(interpolation)하여 커맨드 인젝션(Command Injection) 공격에 노출될 위험이 존재함.
**Learning:** `awk` 쿼리 문자열 안에 신뢰할 수 없는 환경 변수나 쉘 변수를 직접 삽입하면, 악의적인 입력값이 전달될 경우 임의의 코드 실행으로 이어질 수 있음.
**Prevention:** `awk` 명령어 실행 시 변수는 `-v` 플래그(예: `awk -v nf="$NUM_FRAMES"`)를 통해 안전하게 전달하고, 쿼리 문자열은 작은따옴표로 감싸서(`'...'`) 쉘이 먼저 확장하지 않도록 보호해야 함.
