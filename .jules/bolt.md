## 2026-06-29 - [Optimize ffprobe metadata extraction]
**Learning:** Bash script에서 여러 개의 메타데이터(duration, width, height, fps 등)를 추출하기 위해 여러 번의 `ffprobe` 호출을 하면 중복된 프로세스 생성 및 I/O 오버헤드로 인해 성능 저하가 발생합니다. (특히 크기가 큰 비디오 파일의 경우 심각함) 파이프라인(예: `grep` 파이프 `cut`)을 통해 결과를 처리할 때는 `||`가 0을 반환할 수 있으므로, bash 파라미터 확장 문법(`fallback`)을 통해 기본값을 안정적으로 세팅해야 합니다.
**Action:** 항상 `-show_entries`와 `noprint_wrappers=1:nokey=0` 같은 옵션을 활용해 필요한 메타데이터들을 한 번의 호출로 일괄 추출하고, 내장된 `grep`, `cut` 및 파라미터 확장을 이용해 파싱하는 방식으로 최적화하여 오버헤드와 외부 의존성을 줄여야 합니다.
