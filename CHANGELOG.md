# CHANGELOG

## [Unreleased]

### 사용자 경험 개선 (UX)
- CLI 스크립트에서 도움말 플래그(`-h`, `--help`)를 순회하며 파싱하도록 수정하여, 도움말 플래그가 첫 번째 인자가 아니더라도 정상 작동하도록 개선했습니다.
- 다양한 셸 환경에서의 호환성 문제를 방지하기 위해 `echo -e` 대신 `printf "%b\n"`을 사용하도록 변경했습니다.

### 보안 패치 (Security)
- **CRITICAL**: `transcribe.sh` 스크립트에서 발생하는 파이썬 코드 인젝션(Code Injection) 취약점 수정.
  - 기존에는 악의적인 파일명(예: 큰따옴표가 포함된 파일명)을 통해 임의의 파이썬 코드가 실행될 위험이 있었습니다.
  - Heredoc을 따옴표로 감싸고(`<<'PYEOF'`) 환경 변수(`os.environ.get`)를 통해 파일 경로를 안전하게 전달하도록 변경하여 취약점을 해결했습니다.
## [Unreleased]
### Added
- [CLI UX] `download-reference.sh` 스크립트에서 에러 메시지와 우회 방법(Fallback options)의 출력 색상을 시각적으로 분리하여 사용자 인지 부하 감소 (Cyan 색상 적용)
