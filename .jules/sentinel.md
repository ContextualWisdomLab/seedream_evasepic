## 2024-05-18 - [Awk Command Injection]
**Vulnerability:** `awk` 명령어 내에서 외부 입력값을 셸 문자열 보간(string interpolation)을 사용하여 직접 주입하는 패턴이 발견되었습니다. (예: `awk "BEGIN { print $VAR }"`)
**Learning:** 신뢰할 수 없는 환경 변수나 입력값이 그대로 포함될 경우 커맨드 인젝션 취약점으로 이어질 수 있습니다. 특히 bash 스크립트에서 보안 위험이 큽니다.
**Prevention:** 셸 문자열 보간을 피하고 반드시 `awk`의 `-v` 플래그를 사용하여 변수를 안전하게 전달해야 합니다. (예: `awk -v var="$VAR" 'BEGIN { print var }'`)
