## 2024-07-09 - Consolidate multiple ffprobe calls
**Learning:** Making multiple separate calls to `ffprobe` to extract different metadata fields causes significant process startup overhead, which can be optimized by consolidating into a single query.
**Action:** When extracting multiple pieces of metadata with `ffprobe` or `ffmpeg`, consolidate the queries into a single invocation and parse the combined output (e.g., using `awk` with `nokey=0`) to minimize overhead.

## 2024-07-10 - Bash Native Loop Parsing
**Learning:** `ffprobe` 결과를 파싱할 때 `awk`를 여러 번 호출하면 서브쉘과 프로세스 생성 오버헤드가 발생하여 성능이 저하된다. Bash의 내장 기능인 `while read` 루프를 사용하면 이 오버헤드를 획기적으로 줄일 수 있다.
**Action:** 쉘 스크립트에서 단일 텍스트 블록의 다중 필드 파싱이 필요할 때는 외부 도구를 여러 번 호출하는 대신 Bash 네이티브 문자열 파싱(`while read`, `IFS`)을 우선적으로 고려한다.

## 2024-07-11 - Consolidate math operations
**Learning:** 스크립트 내에서 외부 명령어(bc, awk 등)를 여러 번 호출하여 계산하는 것은 서브쉘과 프로세스 생성 오버헤드를 유발합니다.
**Action:** 여러 번의 수학 연산이 필요한 경우, `awk`를 한 번만 호출하고 `read -r`를 사용하여 결과를 여러 변수에 한 번에 할당하여 프로세스 생성 오버헤드를 줄입니다.
## 2025-02-19 - [Bash 성능 개선] 배열 크기 계산 시 불필요한 서브셸 생성 방지
**Learning:** find | wc -l 방식은 불필요한 외부 프로세스(find, wc)를 생성하여 오버헤드가 발생합니다. 특히 파일이 적은 경우나 단순 디렉터리 내 파일 수 계산에서는 Bash 내장 기능인 배열을 활용하는 것이 프로세스 생성 비용이 들지 않아 성능이 더 좋습니다.
**Action:** 앞으로 셸 스크립트에서 파일의 갯수를 셀 때는 외부 도구(find | wc) 대신 shopt -s nullglob과 배열(frames=(...), ${#frames[@]})을 이용해 성능을 향상시킵니다.
## 2026-07-12 - 단일 ffmpeg 패스로 비디오 및 오디오 추출 최적화
**Learning:** 비디오에서 프레임과 오디오를 추출할 때, ffmpeg를 두 번 호출하여 각각 비디오와 오디오를 추출하면 파일 디코딩 및 프로세스 시작 오버헤드가 이중으로 발생합니다.
**Action:** ffprobe에서 추출한 오디오 스트림 존재 여부(`HAS_AUDIO`)를 확인하여, 오디오가 있는 경우 단일 ffmpeg 명령어에 멀티 매핑(`-map 0:v:0`, `-map 0:a:0`)을 사용하여 하나의 프로세스 내에서 동시에 두 가지 추출 작업을 병행해야 합니다. 이를 통해 I/O 및 디코딩 시간을 대폭 절약할 수 있습니다.
## 2025-02-19 - [Bash 성능 개선] 정규식 숫자 검증 오버헤드 최적화
**Learning:** 숫자 입력값 검증 시 `echo | grep -Eq` 방식을 사용하면 서브셸과 외부 프로세스(grep)가 생성되어 오버헤드가 발생합니다. Bash의 내장 기능인 `case` 패턴 매칭을 활용하면 프로세스 생성 없이 입력값을 엄격하게 검증할 수 있어 성능이 더 좋습니다.
**Action:** 앞으로 셸 스크립트에서 단순한 숫자 입력값을 검증할 때는 외부 도구(grep) 대신 POSIX 호환이 가능한 bash native `case` 패턴 매칭(`case "$VAR" in ''|*[!0-9]*|0*) ...`)을 우선적으로 사용합니다.
## 2025-06-25 - Optimize Python module availability check in Bash
**Learning:** Using `python3 -c "import module_name"` in a Bash script to check for a module's existence incurs significant overhead (e.g. ~3s for `whisper` which loads `torch`), even if we only need to know if it's installed.
**Action:** Use `python3 -c "import importlib.util, sys; sys.exit(0 if importlib.util.find_spec('module_name') else 1)"` instead to check module availability without actually importing the code.

## 2025-02-19 - [Bash 성능 개선] 외부 명령어(basename, dirname) 호출 오버헤드 방지
**Learning:** 스크립트 내에서 `basename`이나 `dirname`과 같은 외부 명령어를 서브셸로 호출하면 서브셸 생성 및 프로세스 포크 오버헤드가 발생하여 성능이 저하됩니다.
**Action:** 외부 도구(basename, dirname) 대신 Bash 내장 파라미터 확장(Parameter Expansion, 예: `"${VAR##*/}"`, `"${VAR%/*}"`)을 사용하여 순수 Bash 내장 기능만으로 문자열 조작함으로써 프로세스 생성 비용을 없애고 성능을 향상시킵니다.
## 2024-08-08 - 외부 명령어(tr) 호출 오버헤드 방지
**Learning:** 쉘 스크립트에서 단순한 문자열 공백 제거를 위해 외부 명령어인 `tr`을 파이프로 호출하면 서브쉘과 프로세스 생성 오버헤드가 발생하여 성능이 저하됩니다.
**Action:** 단순한 문자열 조작(공백 제거 등)이 필요한 경우 외부 명령어(tr, sed 등) 대신 Bash 내장 파라미터 확장(예: `"${VAR//[[:space:]]/}"`)을 사용하여 프로세스 생성 비용을 제거하고 성능을 최적화합니다.
## 2024-07-25 - [Bash 성능 개선] yt-dlp DASH/HLS 스트림 다운로드 병렬화 최적화
**Learning:** yt-dlp를 사용하여 DASH/HLS 스트림 비디오를 다운로드할 때 기본적으로 단일 스레드로 진행하여 네트워크 I/O 병목이 발생할 수 있습니다.
**Action:** yt-dlp 호출 시 `--concurrent-fragments N` (예: `--concurrent-fragments 4`) 플래그를 추가하여 프래그먼트들을 병렬로 다운로드하도록 최적화함으로써 다운로드 속도를 크게 향상시킵니다.
## 2024-11-21 - [Bash 성능 개선] 터미널 출력 제어 문자 중화 로직 최적화
**Learning:** Bash에서 C0, C1 제어 문자를 이스케이프하기 위해 `for` 루프 내에서 `printf -v` 서브셸을 반복 호출하는 방식은 CPU 오버헤드가 큽니다.
**Action:** 루프와 서브셸(printf) 대신 하드코딩된 Bash 네이티브 매개변수 확장(`value=${value//pattern/replacement}`)을 직렬로 나열하여 문자열 치환 성능을 약 3배(1.5초 -> 0.5초 / 1000회) 향상시킵니다.
