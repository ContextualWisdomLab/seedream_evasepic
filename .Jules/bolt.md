## 2024-07-01 - [Batch ffprobe calls]
**Learning:** bash 스크립트에서 메타데이터를 추출하기 위해 여러 번의 `ffprobe` 명령을 실행하면 상당한 프로세스 생성 및 I/O 오버헤드가 발생합니다. `-show_entries format=duration:stream=width,height,r_frame_rate`를 사용하여 단일 `ffprobe` 호출로 메타데이터 추출을 일괄 처리하면 성능이 크게 향상됩니다.
**Action:** 외부 도구나 여러 번의 `ffprobe` 실행에 의존하지 않고, 단일 일괄 `ffprobe` 호출과 bash의 네이티브 문자열 조작(`grep` 및 `cut`)을 사용하여 메타데이터를 파싱합니다.
