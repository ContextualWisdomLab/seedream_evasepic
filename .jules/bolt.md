## 2026-07-08 - [ffprobe 다중 호출 최적화]
**Learning:** ffprobe를 여러 번 호출하여 메타데이터(duration, resolution, fps)를 각각 추출할 경우 프로세스 생성 오버헤드가 발생한다.
**Action:** 단일 ffprobe 호출(-show_entries format=duration:stream=width,height,r_frame_rate)로 통합하고 bash 매개변수 확장을 통해 안전하게 파싱하여 I/O 비용과 실행 시간을 크게 단축시킨다.
