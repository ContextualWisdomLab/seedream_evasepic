## 2024-05-24 - ffprobe 메타데이터 추출 최적화
**Learning:** 여러 항목을 추출하기 위해 별도의 `ffprobe` 프로세스를 여러 번 띄우는 것은 I/O 및 프로세스 생성 오버헤드를 유발함 (예: `DURATION`, `RESOLUTION`, `FPS` 추출).
**Action:** `-show_entries`에 여러 키를 지정하여 (예: `-show_entries format=duration:stream=width,height,r_frame_rate`) 단 한 번의 `ffprobe` 호출로 모든 메타데이터를 일괄 추출(Batching)하고, `grep`과 `cut`으로 파싱하여 성능을 최적화함 (~66% 호출 감소).
