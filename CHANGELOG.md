# CHANGELOG

## [Unreleased]

### UX/접근성 개선 (UX & Accessibility)
- CLI 스크립트(`download-reference.sh`, `extract-frames.sh`, `transcribe.sh`)에 표준 도움말 옵션(`-h`, `--help`) 지원 추가.
- `extract-frames.sh`에서 의존성(ffmpeg) 체크보다 도움말 옵션 처리가 먼저 실행되도록 순서를 변경하여, 사용자가 의존성 설치 없이도 사용법을 확인할 수 있도록 개선.

### 보안 패치 (Security)
- **CRITICAL**: `transcribe.sh` 스크립트에서 발생하는 파이썬 코드 인젝션(Code Injection) 취약점 수정.
  - 기존에는 악의적인 파일명(예: 큰따옴표가 포함된 파일명)을 통해 임의의 파이썬 코드가 실행될 위험이 있었습니다.
  - Heredoc을 따옴표로 감싸고(`<<'PYEOF'`) 환경 변수(`os.environ.get`)를 통해 파일 경로를 안전하게 전달하도록 변경하여 취약점을 해결했습니다.