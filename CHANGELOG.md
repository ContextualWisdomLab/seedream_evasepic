# CHANGELOG

## [Unreleased]

### 보안 패치 (Security)
- **CRITICAL**: `transcribe.sh` 스크립트에서 발생하는 파이썬 코드 인젝션(Code Injection) 취약점 수정.
  - 기존에는 악의적인 파일명(예: 큰따옴표가 포함된 파일명)을 통해 임의의 파이썬 코드가 실행될 위험이 있었습니다.
  - Heredoc을 따옴표로 감싸고(`<<'PYEOF'`) 환경 변수(`os.environ.get`)를 통해 파일 경로를 안전하게 전달하도록 변경하여 취약점을 해결했습니다.
## [Unreleased]
### Added
- `download-reference.sh`, `extract-frames.sh`, `transcribe.sh` 스크립트에 `-h`와 `--help` 플래그를 추가하여 사용자가 쉽게 사용법을 확인할 수 있도록 개선.

### Changed
- `extract-frames.sh` 스크립트에서 `ffmpeg` 등 외부 의존성 체크를 인자 파싱 이후로 이동하여, 의존성이 없어도 도움말(`--help`)을 볼 수 있도록 UX 개선.
- 인자 누락 시 에러 출력과 도움말 출력의 종료 코드 분리 (도움말: `0`, 에러: `2`).
