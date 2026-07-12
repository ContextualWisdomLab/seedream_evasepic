## 2024-07-09 - Consolidate multiple ffprobe calls
**Learning:** Making multiple separate calls to `ffprobe` to extract different metadata fields causes significant process startup overhead, which can be optimized by consolidating into a single query.
**Action:** When extracting multiple pieces of metadata with `ffprobe` or `ffmpeg`, consolidate the queries into a single invocation and parse the combined output (e.g., using `awk` with `nokey=0`) to minimize overhead.

## 2024-07-10 - Bash Native Loop Parsing
**Learning:** `ffprobe` 결과를 파싱할 때 `awk`를 여러 번 호출하면 서브쉘과 프로세스 생성 오버헤드가 발생하여 성능이 저하된다. Bash의 내장 기능인 `while read` 루프를 사용하면 이 오버헤드를 획기적으로 줄일 수 있다.
**Action:** 쉘 스크립트에서 단일 텍스트 블록의 다중 필드 파싱이 필요할 때는 외부 도구를 여러 번 호출하는 대신 Bash 네이티브 문자열 파싱(`while read`, `IFS`)을 우선적으로 고려한다.

## 2024-07-11 - Consolidate math operations
**Learning:** 스크립트 내에서 외부 명령어(bc, awk 등)를 여러 번 호출하여 계산하는 것은 서브쉘과 프로세스 생성 오버헤드를 유발합니다.
**Action:** 여러 번의 수학 연산이 필요한 경우, `awk`를 한 번만 호출하고 `read -r`를 사용하여 결과를 여러 변수에 한 번에 할당하여 프로세스 생성 오버헤드를 줄입니다.
## 2025-02-19 - [Bash 성능 개선] 배열 크기 계산 시 불필요한 서브셸 생성 방지
**Learning:** find | wc -l 방식은 불필요한 외부 프로세스(find, wc)를 생성하여 오버헤드가 발생합니다. 특히 파일이 적은 경우나 단순 디렉터리 내 파일 수 계산에서는 Bash 내장 기능인 배열을 활용하는 것이 프로세스 생성 비용이 들지 않아 성능이 더 좋습니다.
**Action:** 앞으로 셸 스크립트에서 파일의 갯수를 셀 때는 외부 도구(find | wc) 대신 shopt -s nullglob과 배열(frames=(...), ${#frames[@]})을 이용해 성능을 향상시킵니다.
## 2025-02-19 - [Bash 성능 개선] 정규식 숫자 검증 오버헤드 최적화
**Learning:** 숫자 입력값 검증 시 `echo | grep -Eq` 방식을 사용하면 서브셸과 외부 프로세스(grep)가 생성되어 오버헤드가 발생합니다. Bash의 내장 기능인 `case` 패턴 매칭을 활용하면 프로세스 생성 없이 입력값을 엄격하게 검증할 수 있어 성능이 더 좋습니다.
**Action:** 앞으로 셸 스크립트에서 단순한 숫자 입력값을 검증할 때는 외부 도구(grep) 대신 POSIX 호환이 가능한 bash native `case` 패턴 매칭(`case "$VAR" in ''|*[!0-9]*|0*) ...`)을 우선적으로 사용합니다.
