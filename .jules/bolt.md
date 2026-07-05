## 2024-05-27 - 단일 ffprobe 호출로 메타데이터 추출 최적화
**Learning:** bash 스크립트에서 비디오 메타데이터(시간, 해상도, 프레임 레이트)를 추출할 때 여러 번의 `ffprobe` 호출은 프로세스 생성 오버헤드와 중복 I/O를 발생시킨다. `-show_entries format=duration:stream=width,height,r_frame_rate`를 통해 한 번의 호출로 통합하는 것이 성능에 유리하다.
**Action:** 여러 번의 메타데이터 조회 대신 단일 `ffprobe` 호출 후 bash의 native text processing(grep, parameter expansion)을 통해 파싱하도록 최적화한다.
