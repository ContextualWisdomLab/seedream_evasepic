## 2025-02-19 - [Bash 성능 개선] 정규식 숫자 검증 오버헤드 최적화
**Learning:** 숫자 입력값 검증 시 `echo | grep -Eq` 방식을 사용하면 서브셸과 외부 프로세스(grep)가 생성되어 오버헤드가 발생합니다. Bash의 내장 기능인 `case` 패턴 매칭을 활용하면 프로세스 생성 없이 입력값을 엄격하게 검증할 수 있어 성능이 더 좋습니다.
**Action:** 앞으로 셸 스크립트에서 단순한 숫자 입력값을 검증할 때는 외부 도구(grep) 대신 POSIX 호환이 가능한 bash native `case` 패턴 매칭(`case "$VAR" in ''|*[!0-9]*|0*) ...`)을 우선적으로 사용합니다.

## 2025-06-25 - Optimize Python module availability check in Bash
**Learning:** Using `python3 -c "import module_name"` in a Bash script to check for a module's existence incurs significant overhead (e.g. ~3s for `whisper` which loads `torch`), even if we only need to know if it's installed.
**Action:** Use `python3 -c "import importlib.util, sys; sys.exit(0 if importlib.util.find_spec('module_name') else 1)"` instead to check module availability without actually importing the code.

## 2025-02-19 - [Bash 성능 개선] 외부 명령어(basename, dirname) 호출 오버헤드 방지
**Learning:** 스크립트 내에서 `basename`이나 `dirname`과 같은 외부 명령어를 서브셸로 호출하면 서브셸 생성 및 프로세스 포크 오버헤드가 발생하여 성능이 저하됩니다.
**Action:** 외부 도구(basename, dirname) 대신 Bash 내장 파라미터 확장(Parameter Expansion, 예: `"${VAR##*/}"`, `"${VAR%/*}"`)을 사용하여 순수 Bash 내장 기능만으로 문자열 조작함으로써 프로세스 생성 비용을 없애고 성능을 향상시킵니다.

## 2024-08-08 - 외부 명령어(tr) 호출 오버헤드 방지
**Learning:** 쉘 스크립트에서 단순한 문자열 공백 제거를 위해 외부 명령어인 `tr`을 파이프로 호출하면 서브쉘과 프로세스 생성 오버헤드가 발생하여 성능이 저하됩니다.
**Action:** 단순한 문자열 조작(공백 제거 등)이 필요한 경우 외부 명령어(tr, sed 등) 대신 Bash 내장 파라미터 확장(예: `"${VAR//[[:space:]]/}"`)을 사용하여 프로세스 생성 비용을 제거하고 성능을 최적화합니다.

## 2024-07-25 - [Bash 성능 개선] yt-dlp DASH/HLS 스트림 다운로드 병렬화 최적화
**Learning:** yt-dlp를 사용하여 DASH/HLS 스트림 비디오를 다운로드할 때 기본적으로 단일 스레드로 진행하여 네트워크 I/O 병목이 발생할 수 있습니다.
**Action:** yt-dlp 호출 시 `--concurrent-fragments N` (예: `--concurrent-fragments 4`) 플래그를 추가하여 프래그먼트들을 병렬로 다운로드하도록 최적화함으로써 다운로드 속도를 크게 향상시킵니다.
