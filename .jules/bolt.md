## 2024-07-02 - [Bash ffprobe 최적화]
**Learning:** Bash 스크립트에서 비디오 메타데이터를 추출하기 위해 여러 번 `ffprobe`를 호출하면 I/O 오버헤드와 서브프로세스 생성 지연이 크게 발생합니다.
**Action:** `ffprobe -show_entries`에 복수 개의 키(예: format=duration:stream=width,height,r_frame_rate)를 전달하여 한 번만 호출하고, `grep`과 `cut`을 이용해 결과를 파싱하는 방식으로 I/O 및 프로세스 횟수를 줄입니다.
## 2024-07-02 - [Bash ffprobe 추가 최적화]
**Learning:** 여러 번의 subprocess를 만드는 파이프라인(echo | grep | cut 등)은 ffprobe 단일 호출의 효과를 반감시킵니다.
**Action:** awk 등의 텍스트 처리 도구를 활용하여 단 한 번의 파싱(single pass parsing)으로 필요한 모든 변수를 한 번에 할당(batch assignment)하도록 하여 subprocess 오버헤드를 근본적으로 제거했습니다.
