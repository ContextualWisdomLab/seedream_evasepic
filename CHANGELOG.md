# CHANGELOG

## [Unreleased]

### 사용자 경험 개선 (UX)
- 참조 영상 분석 전에 `ffprobe` 실행 가능 여부를 `ffmpeg`와 별도로 검증합니다. 도구가 없으면 출력 디렉터리 생성이나 메타데이터 처리 전에 고정된 오류 원인과 설치 명령을 stderr에 표시하고 종료합니다.
- CLI 스크립트에서 도움말 플래그(`-h`, `--help`)를 순회하며 파싱하도록 수정하여, 도움말 플래그가 첫 번째 인자가 아니더라도 정상 작동하도록 개선했습니다.
- 다양한 셸 환경에서의 호환성 문제를 방지하기 위해 `echo -e` 대신 `printf "%b\n"`을 사용하도록 변경했습니다.

### 보안 패치 (Security)
- **CRITICAL**: `transcribe.sh` 스크립트에서 발생하는 파이썬 코드 인젝션(Code Injection) 취약점 수정.
  - 기존에는 악의적인 파일명(예: 큰따옴표가 포함된 파일명)을 통해 임의의 파이썬 코드가 실행될 위험이 있었습니다.
  - Heredoc을 따옴표로 감싸고(`<<'PYEOF'`) 환경 변수(`os.environ.get`)를 통해 파일 경로를 안전하게 전달하도록 변경하여 취약점을 해결했습니다.
- 사용자 제공 URL·파일 경로·출력 경로·모델 인자를 터미널에 표시하기 전에 공통 neutralizer로 처리합니다. 실제 ESC/C0/C1 바이트, CR/LF, Unicode line separator 및 bidirectional control을 가시적인 escape 표기로 변환하고, trusted ANSI 색상만 control byte를 생성하도록 제한했습니다.
- literal `\033` 문자열이 아니라 실제 control byte를 사용하는 CLI 회귀 테스트와 정적 `%b` sink 검사를 추가했습니다.

### 성능 최적화 (Performance)
- `yt-dlp` 명령어에 `--concurrent-fragments 4` 옵션을 추가하여 DASH/HLS 스트림의 프래그먼트 병렬 다운로드를 활성화함으로써 네트워크 I/O 병목을 줄이고 다운로드 속도를 개선했습니다.
