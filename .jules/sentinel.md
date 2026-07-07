## 2024-07-07 - Command Injection in awk via String Interpolation
**Vulnerability:** Bash 스크립트(`extract-frames.sh`)에서 `bc` 명령어의 Fallback 로직으로 사용된 `awk` 명령어에 신뢰할 수 없는 변수(`NUM_FRAMES`)가 문자열 보간(`"..."`)을 통해 직접 주입되는 Command Injection 취약점이 존재했습니다. 이를 통해 사용자가 변수에 악의적인 awk 코드(예: `'1 }; BEGIN { system("id") } #'`)를 삽입하여 임의의 셸 명령어를 실행할 수 있었습니다.
**Learning:** `awk`나 `sed`와 같은 유틸리티를 호출할 때 쌍따옴표 안에 셸 변수를 직접 평가(expand)하도록 작성하면, 변수의 내용이 코드의 일부로 파싱되어 Injection 공격에 취약해집니다.
**Prevention:** `awk`에 외부 변수를 전달할 때는 절대로 셸의 문자열 보간을 사용하지 말고, 항상 `-v` 플래그(예: `awk -v var="$VAR"`)를 사용하여 안전하게 변수로 전달해야 합니다.
