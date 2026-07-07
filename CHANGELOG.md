# CHANGELOG

## [Unreleased]

### 보안 패치 (Security)
- **CRITICAL**: `transcribe.sh` 스크립트에서 발생하는 파이썬 코드 인젝션(Code Injection) 취약점 수정.
  - 기존에는 악의적인 파일명(예: 큰따옴표가 포함된 파일명)을 통해 임의의 파이썬 코드가 실행될 위험이 있었습니다.
  - Heredoc을 따옴표로 감싸고(`<<'PYEOF'`) 환경 변수(`os.environ.get`)를 통해 파일 경로를 안전하게 전달하도록 변경하여 취약점을 해결했습니다.
- `download-reference.sh`가 URL을 `yt-dlp`에 전달할 때 `--` 옵션 구분자를 사용하도록 해 URL이 옵션처럼 해석되는 입력을 차단했습니다.
- `extract-frames.sh`의 `num_frames` 값을 양의 정수로 제한하고, `awk` 계산에는 `-v` 인자 전달을 사용해 문자열 보간 기반 명령 주입 가능성을 줄였습니다.

### 성능 개선 (Performance)
- `extract-frames.sh`에서 duration, 해상도, FPS를 얻기 위해 `ffprobe`를 세 번 호출하던 흐름을 한 번의 `ffprobe` 호출과 한 번의 `awk` 파싱으로 통합했습니다.

### UX 개선 (User Experience)
- `download-reference.sh`, `extract-frames.sh`, `transcribe.sh`에서 `-h`/`--help`를 먼저 처리해 필수 의존성이 없어도 사용법을 확인할 수 있도록 했습니다.
- CLI 출력은 `echo -e` 대신 `printf "%b\n"`로 표준화해 셸별 출력 차이를 줄였습니다.
