## 2026-07-10 - yt-dlp 인자 주입(Argument Injection) 취약점 수정
**Vulnerability:** yt-dlp 실행 시 외부 입력 URL이 검증 없이 인자로 사용되어 악의적인 옵션 주입 가능
**Learning:** bash 스크립트에서 외부 입력을 명령어 인자로 넘길 때 하이픈(-)으로 시작하는 문자열이 옵션으로 오인될 수 있음
**Prevention:** 명령어와 인자 사이에 '--'를 명시하여 옵션의 끝을 알리고, 변수가 순수한 인자로만 처리되도록 방어해야 함

## 2026-07-11 - [CRITICAL] awk 명령어 문자열 보간(Command Injection) 취약점 수정
**Vulnerability:** `extract-frames.sh`의 `bc` 미설치 fallback 경로에서 `awk "BEGIN ... $NUM_FRAMES / $DURATION"` 형태로 셸 변수를 awk 프로그램 문자열에 직접 보간하여, 조작된 입력이 awk 코드로 해석될 수 있음.
**Learning:** awk 프로그램 본문은 고정된 작은따옴표 문자열로 유지하고, 동적 값은 `awk -v name="$value"`로 전달해야 코드와 데이터가 분리됨.
**Prevention:** `NUM_FRAMES`와 `DURATION`은 `-v nf="$NUM_FRAMES" -v dur="$DURATION"`로 전달하고, 회귀 테스트에서 직접 보간 패턴이 재등장하면 실패하도록 검사함.
