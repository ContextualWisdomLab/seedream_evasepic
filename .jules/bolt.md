## 2024-11-23 - 단일 ffprobe 호출을 통한 비디오 메타데이터 추출 최적화
**Learning:** bash 스크립트에서 비디오 처리 시, 메타데이터(duration, resolution, fps 등)를 추출하기 위해 여러 번의 `ffprobe` 호출을 수행하는 것은 프로세스 생성 및 파일 I/O 오버헤드로 인해 성능 저하를 일으킨다.
**Action:** 비디오 처리 스크립트 작성 시 메타데이터 추출은 `-show_entries format=...:stream=...` 옵션을 사용하여 단일 `ffprobe` 호출로 통합(batch)하고, 반환된 결과를 변수에 저장하여 파싱하도록 구현한다. 이를 통해 실행 시간을 단축할 수 있다.