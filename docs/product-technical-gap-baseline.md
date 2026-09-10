# Product–technical gap baseline

## Terminal output neutralization

`terminal_safe_text()`는 untrusted CLI 문자열의 C0/C1 및 일부 Unicode line/bidirectional/invisible control을 printable escape로 바꾸는 보안 경계다. PR #424는 C0/C1 문자에 대한 동적 `printf -v` 생성 루프를 정적 Bash parameter expansion으로 펼치는 성능 후보 변경이다. 이 변경의 우선 계약은 출력 의미의 완전한 동등성이다.

현재 diff만으로 실행 속도가 현저히 향상되거나 GC/heap 효과가 있다고 주장하지 않는다. Bash parameter expansion도 각 치환에서 입력을 탐색하므로, 실제 이득은 입력 길이·control 분포·Bash 버전·locale에 따라 측정해야 한다. 일반적인 'loop unrolling이 항상 더 빠르다'는 repository doctrine으로 승격하지 않는다.

### Acceptance

- protected comparator와 current head가 printable ASCII, 빈 문자열, 각 C0(가능한 0x01–0x1f), DEL, U+0080–U+009F, U+200B/U+200C/U+200D/U+200E/U+200F, U+2028/U+2029/U+202A–U+202E, U+2060/U+2066–U+2069, U+061C, U+FEFF 및 혼합 문자열에서 byte-for-byte 동일한 출력 계약을 만족한다.
- untrusted input이 trusted ANSI prefix/suffix의 terminal semantics를 변경하지 못한다.
- representative/right-cleared 실제 CLI 값의 길이와 control-character 분포를 보존한 workload에서 동일 Bash/runtime/CPU/locale로 protected comparator와 current head를 반복 측정하고 median·p95와 CPU를 기록한다.
- synthetic microbenchmark만으로 buyer-visible 개선을 선언하지 않는다. 통계적으로/실무적으로 의미 있는 이득이 없으면 production churn을 되돌린다.
- shell syntax, ShellCheck, terminal sanitizer regression, Security/SAST/CodeQL이 동일 exact head에서 GREEN이어야 한다.

### Traceability

- Code: `plugins/seedream-evasepic/skills/analyze-reference-video/scripts/terminal-output.sh`.
- Change: PR #424, base `develop@06e3efc20d7d5ffa3f284188af0d181ce8403132`.
