## 2024-07-04 - ffprobe 프로세스 통합을 통한 오버헤드 감소
**Learning:** Bash 스크립트에서 여러 메타데이터(duration, width/height, fps 등)를 추출하기 위해 `ffprobe` 같은 외부 도구를 여러 번 호출하는 것은 각각의 프로세스 시작 오버헤드 때문에 비효율적이다.
**Action:** `ffprobe` (또는 `ffmpeg`) 호출을 통합하여 한 번의 실행으로 필요한 모든 데이터를 `-of default=noprint_wrappers=1:nokey=0` 옵션과 함께 출력하게 하고, 이를 `awk` 로 파싱(e.g., `awk -F=`)하여 변수에 할당하도록 한다. 이를 통해 성능을 측정 가능하게 최적화한다.
