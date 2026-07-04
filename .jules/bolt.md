## 2026-07-04 - [bash 스크립트 I/O 최적화] ffprobe 메타데이터 추출 통합
**Learning:** 비디오 처리를 위한 bash 스크립트에서 `ffprobe`를 여러 번 호출하여 각각의 메타데이터(duration, resolution, fps 등)를 추출하는 것은 불필요한 프로세스 생성 및 I/O 오버헤드를 발생시킴.
**Action:** 여러 개의 메타데이터가 필요할 경우, `-show_entries` 옵션을 사용하여 한 번의 `ffprobe` 호출로 필요한 모든 정보를 추출한 후, bash 내부 문자열 처리(grep, cut, 매개변수 확장 등)를 통해 변수에 할당하여 성능을 최적화할 것.
