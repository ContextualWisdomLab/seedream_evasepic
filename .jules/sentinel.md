## 2024-07-05 - [High] awk 명령어 Command Injection 방어
**Vulnerability:** Bash 스크립트(`extract-frames.sh`)에서 `awk` 명령어를 사용할 때 `$NUM_FRAMES` 및 `$DURATION` 변수를 문자열 보간(`"BEGIN { printf ... }"`)으로 직접 주입하는 패턴이 존재했습니다. 사용자가 제어할 수 있는 입력이 주입될 경우 임의의 코드(예: `system()`)가 실행될 수 있는 위험이 있었습니다.
**Learning:** `awk` 명령어 내부에서 쉘 변수를 사용할 때 문자열 보간을 사용하면 쉘의 매개변수 확장이 `awk` 실행 전에 이루어지므로 Command Injection 취약점이 발생하기 쉽습니다. 특히 외부에서 입력받는 값이 `awk` 스크립트 문자열로 직접 삽입되는 경우 치명적입니다.
**Prevention:** 쉘 변수를 `awk` 스크립트 내부에 직접 보간하는 대신, `-v` 플래그를 사용하여 변수를 전달(`awk -v n="$NUM_FRAMES"`)해야 합니다. 이를 통해 변수는 안전하게 처리되며 `awk` 문법 내에서 코드로 해석되지 않습니다.
