# CHANGELOG

## [Unreleased]

### 보안 패치 (Security)
- **CRITICAL**: `transcribe.sh` 스크립트에서 발생하는 파이썬 코드 인젝션(Code Injection) 취약점 수정.
  - 기존에는 악의적인 파일명(예: 큰따옴표가 포함된 파일명)을 통해 임의의 파이썬 코드가 실행될 위험이 있었습니다.
  - Heredoc을 따옴표로 감싸고(`<<'PYEOF'`) 환경 변수(`os.environ.get`)를 통해 파일 경로를 안전하게 전달하도록 변경하여 취약점을 해결했습니다.
## [Unreleased]
### 성능 개선 (Performance)
- `extract-frames.sh` 스크립트에서 비디오 메타데이터 추출 시 `ffprobe`를 3번 호출하던 것을 단일 호출로 일괄 처리(Batching)하여 프로세스 생성 오버헤드 감소
