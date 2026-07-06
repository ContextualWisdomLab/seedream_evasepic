## 2026-07-06 - [ffprobe 메타데이터 추출 성능 최적화]
**Learning:** 비디오 메타데이터(지속 시간, 해상도, 프레임 레이트)를 추출할 때 여러 번의 `ffprobe` 호출은 I/O 및 프로세스 생성 오버헤드를 발생시킵니다.
**Action:** `ffprobe -show_entries format=duration:stream=width,height,r_frame_rate` 옵션을 사용하여 한 번의 호출로 메타데이터를 일괄 추출(batch)하여 스크립트 실행 시간을 크게 단축해야 합니다.
