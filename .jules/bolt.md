## 2024-07-09 - Consolidate multiple ffprobe calls
**Learning:** Making multiple separate calls to `ffprobe` to extract different metadata fields causes significant process startup overhead, which can be optimized by consolidating into a single query.
**Action:** When extracting multiple pieces of metadata with `ffprobe` or `ffmpeg`, consolidate the queries into a single invocation and parse the combined output (e.g., using `awk` with `nokey=0`) to minimize overhead.
## 2024-05-24 - [순수 Bash를 활용한 외부 명령어 프로세스 스포닝 감소]
**Learning:** Bash 스크립트에서 파이프라인(awk, grep 등)이나 서브쉘 호출이 반복되면 프로세스 스포닝 오버헤드가 발생한다.
**Action:** 단순 문자열 파싱과 파일 개수 계산은 순수 Bash 내장 기능(while read, 매개변수 확장, nullglob과 배열 등)으로 대체하여 스크립트 성능을 높인다.
