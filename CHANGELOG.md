# CHANGELOG

## [Unreleased]

### 문서·라이선스 경계
- Root README를 ContextualWisdomLab fork의 제품 가치·사용 경로·검증·upstream 권위가 바로 보이도록 정리하고, fork에서 별도로 검증되지 않은 release/deployment 상태를 주장하지 않도록 했습니다.
- Upstream README와 marketplace metadata는 MIT를 선언하지만 upstream root LICENSE/완전한 저작권·허가 고지가 없다는 provenance blocker를 명시했습니다. ContextualWisdomLab이 새 저작권자나 완전한 MIT grant를 임의로 만들어내지 않습니다.
- `awesome-seedance-2-prompts`에서 가져오거나 변형했다고 저장소 자체가 밝힌 curated prompt 자료에 대해 CC BY 4.0의 상업 이용 가능성과 attribution/license-link/change-indication 의무를 `THIRD_PARTY_NOTICES.md`에 기록했습니다.
- `arcads-claude-code`는 MIT source reference/inspiration으로 별도 식별하고, 실제 파일 복제/파생 여부는 file-level provenance evidence 없이 단정하지 않습니다.

### 사용자 경험 개선 (UX)
- 참조 영상 다운로드 대상이 이미 존재하는 0바이트 초과 일반 파일이면 `yt-dlp` 설치 확인과 네트워크 호출 전에 안전하게 종료하여 기존 아티팩트를 보존합니다. 0바이트 파일과 누락 경로는 계속 다운로드하며, 캐시 적중·미스 분기를 실행 가능한 CLI 테스트로 검증합니다.
- 참조 영상 분석 전에 `ffprobe` 실행 가능 여부를 `ffmpeg`와 별도로 검증합니다. 도구가 없으면 출력 디렉터리 생성이나 메타데이터 처리 전에 고정된 오류 원인과 설치 명령을 stderr에 표시하고 종료합니다.
- CLI 스크립트에서 도움말 플래그(`-h`, `--help`)를 순회하며 파싱하도록 수정하여, 도움말 플래그가 첫 번째 인자가 아니더라도 정상 작동하도록 개선했습니다.
- 다양한 셸 환경에서의 호환성 문제를 방지하기 위해 `echo -e` 대신 `printf "%b\n"`을 사용하도록 변경했습니다.

### 보안 패치 (Security)
- **CRITICAL**: `transcribe.sh` 스크립트에서 발생하는 파이썬 코드 인젝션(Code Injection) 취약점 수정.
  - 기존에는 악의적인 파일명(예: 큰따옴표가 포함된 파일명)을 통해 임의의 파이썬 코드가 실행될 위험이 있었습니다.
  - Heredoc을 따옴표로 감싸고(`<<'PYEOF'`) 환경 변수(`os.environ.get`)를 통해 파일 경로를 안전하게 전달하도록 변경하여 취약점을 해결했습니다.
- 사용자 제공 URL·파일 경로·출력 경로·모델 인자를 터미널에 표시하기 전에 공통 neutralizer로 처리합니다. 실제 ESC/C0/C1 바이트, CR/LF, Unicode line separator 및 bidirectional control을 가시적인 escape 표기로 변환하고, trusted ANSI 색상만 control byte를 생성하도록 제한했습니다.
- literal `\033` 문자열이 아니라 실제 control byte를 사용하는 CLI 회귀 테스트와 정적 `%b` sink 검사를 추가했습니다.
- CLI 출력의 `Example:` 구문에 있는 예시 명령어 부분에 시각적 구분 효과를 주는 색상(Cyan)을 추가하여 가독성과 사용자 실행 유도성을 높였습니다.

### Performance
- `yt-dlp` 호출 시 `--concurrent-fragments 4` 플래그를 추가하여 DASH/HLS 스트림의 다운로드 속도를 최적화했습니다. 단일 스레드로 인한 네트워크 병목을 해소합니다.

