## 2024-07-09 - [성능 개선] 메타데이터 추출 시 ffprobe 호출 횟수 단축
**Learning:** 비디오 메타데이터(duration, width, height, fps 등)를 추출할 때 여러 번 ffprobe를 호출하면 프로세스 생성 및 I/O 오버헤드가 발생한다.
**Action:** bash 스크립트 작성 시 여러 정보를 `-show_entries`로 한 번에 추출하고 bash 문자열 파싱을 통해 추출하도록 구현한다.
