## 2024-07-09 - Consolidate multiple ffprobe calls
**Learning:** Making multiple separate calls to `ffprobe` to extract different metadata fields causes significant process startup overhead, which can be optimized by consolidating into a single query.
**Action:** When extracting multiple pieces of metadata with `ffprobe` or `ffmpeg`, consolidate the queries into a single invocation and parse the combined output (e.g., using `awk` with `nokey=0`) to minimize overhead.

## 2024-07-10 - Bash Native Loop Parsing
**Learning:** `ffprobe` 결과를 파싱할 때 `awk`를 여러 번 호출하면 서브쉘과 프로세스 생성 오버헤드가 발생하여 성능이 저하된다. Bash의 내장 기능인 `while read` 루프를 사용하면 이 오버헤드를 획기적으로 줄일 수 있다.
**Action:** 쉘 스크립트에서 단일 텍스트 블록의 다중 필드 파싱이 필요할 때는 외부 도구를 여러 번 호출하는 대신 Bash 네이티브 문자열 파싱(`while read`, `IFS`)을 우선적으로 고려한다.

## 2024-07-11 - Consolidate math operations
**Learning:** 스크립트 내에서 외부 명령어(bc, awk 등)를 여러 번 호출하여 계산하는 것은 서브쉘과 프로세스 생성 오버헤드를 유발합니다.
**Action:** 여러 번의 수학 연산이 필요한 경우, `awk`를 한 번만 호출하고 `read -r`를 사용하여 결과를 여러 변수에 한 번에 할당하여 프로세스 생성 오버헤드를 줄입니다.
