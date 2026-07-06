## 2024-07-06 - [High] awk 커맨드 인젝션 취약점 수정
**Vulnerability:** Bash 스크립트(`extract-frames.sh`) 내에서 `awk` 명령어를 실행할 때, 외부에서 입력받은 변수(`$NUM_FRAMES`, `$DURATION`)를 직접 문자열 보간(string interpolation)으로 삽입하여 커맨드 인젝션(Command Injection) 취약점이 발생할 수 있었습니다.
**Learning:** `awk` 명령어 내에 Bash 변수를 큰따옴표 안에서 직접 참조하는 방식은 신뢰할 수 없는 입력이 주어졌을 때 의도치 않은 임의의 코드가 실행될 수 있는 보안 위협을 야기할 수 있다는 점을 확인했습니다.
**Prevention:** 쉘 스크립트에서 `awk`를 사용할 때는 외부 변수를 직접 삽입하지 않고, `-v` 옵션을 사용하여 안전하게 변수를 전달(`awk -v var="$VAR"`)하도록 작성해야 합니다.
