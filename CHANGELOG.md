# CHANGELOG

## [Unreleased]

### 보안 패치 (Security)
- **CRITICAL**: `extract-frames.sh` 스크립트에서 `awk` 연산 처리 중 발생하는 명령어 삽입(Command Injection) 취약점 수정.
  - 쉘의 문자열 보간(string interpolation) 대신 `-v` 플래그를 사용하여 변수를 명시적으로 전달하도록 변경하여 악의적인 명령어 실행을 방지했습니다.
- **CRITICAL**: `transcribe.sh` 스크립트에서 발생하는 파이썬 코드 인젝션(Code Injection) 취약점 수정.
  - 기존에는 악의적인 파일명(예: 큰따옴표가 포함된 파일명)을 통해 임의의 파이썬 코드가 실행될 위험이 있었습니다.
  - Heredoc을 따옴표로 감싸고(`<<'PYEOF'`) 환경 변수(`os.environ.get`)를 통해 파일 경로를 안전하게 전달하도록 변경하여 취약점을 해결했습니다.