#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DICTATION_SRC="${PROJECT_ROOT}/scripts/dictation"

TEST_ROOT="$(mktemp -d /tmp/dictation-tests.XXXXXX)"
trap 'rm -rf "${TEST_ROOT}"' EXIT

WORK_ROOT="${TEST_ROOT}/work"
BIN_DIR="${TEST_ROOT}/bin"
mkdir -p "${WORK_ROOT}/scripts" "${WORK_ROOT}/models" "${WORK_ROOT}/sessions" "${BIN_DIR}"
cp "${DICTATION_SRC}" "${WORK_ROOT}/scripts/dictation"
chmod +x "${WORK_ROOT}/scripts/dictation"

PASS_COUNT=0
FAIL_COUNT=0

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  echo "PASS: $1"
}

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  echo "FAIL: $1"
}

assert_file() {
  local f="$1"
  local msg="$2"
  if [ -f "${f}" ]; then
    pass "${msg}"
  else
    fail "${msg} (missing: ${f})"
  fi
}

assert_grep() {
  local pattern="$1"
  local file="$2"
  local msg="$3"
  if grep -qE -- "${pattern}" "${file}"; then
    pass "${msg}"
  else
    fail "${msg} (pattern: ${pattern})"
  fi
}

cat > "${BIN_DIR}/ffmpeg" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail

if [[ "$*" == *"-list_devices true"* ]]; then
  echo "[AVFoundation indev @ mock] AVFoundation audio devices:" >&2
  echo "[AVFoundation indev @ mock] [0] Built-in Mic" >&2
  echo "[AVFoundation indev @ mock] [1] USB Mic" >&2
  echo "Error opening input file ." >&2
  exit 1
fi

out="${@: -1}"
mkdir -p "$(dirname "${out}")"
# Put some bytes so downstream size checks pass.
printf 'audio' > "${out}"
exit 0
MOCK
chmod +x "${BIN_DIR}/ffmpeg"

cat > "${BIN_DIR}/whisper-cli" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail

if [ -n "${WHISPER_ARGS_LOG:-}" ]; then
  echo "$*" >> "${WHISPER_ARGS_LOG}"
fi

out_base=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    -of)
      out_base="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

if [ -z "${out_base}" ]; then
  echo "missing -of" >&2
  exit 2
fi

printf 'mock transcript\n' > "${out_base}.txt"
printf 'WEBVTT\n\n' > "${out_base}.vtt"
exit 0
MOCK
chmod +x "${BIN_DIR}/whisper-cli"

cat > "${BIN_DIR}/ollama" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" = "run" ]; then
  cat >/dev/null
  printf '# Summary\n\n- mock summary\n'
  exit 0
fi

exit 2
MOCK
chmod +x "${BIN_DIR}/ollama"

export PATH="${BIN_DIR}:$PATH"
export WHISPER_ARGS_LOG="${TEST_ROOT}/whisper_args.log"

# Prepare model files expected by script.
printf 'model-small' > "${WORK_ROOT}/models/ggml-small.bin"
printf 'model-medium' > "${WORK_ROOT}/models/ggml-medium.bin"

run_in_work() {
  (cd "${WORK_ROOT}" && "$@")
}

# 1) list-devices should succeed despite ffmpeg exiting 1 in list mode.
LIST_OUT="${TEST_ROOT}/list.txt"
if run_in_work scripts/dictation list-devices >"${LIST_OUT}" 2>&1; then
  pass "list-devices exits successfully"
else
  fail "list-devices exits successfully"
fi
assert_grep "\[0\] Built-in Mic" "${LIST_OUT}" "list-devices prints first device"
assert_grep "\[1\] USB Mic" "${LIST_OUT}" "list-devices prints second device"
if grep -q "Error opening" "${LIST_OUT}"; then
  fail "list-devices filters ffmpeg open-input noise"
else
  pass "list-devices filters ffmpeg open-input noise"
fi

# 2) timed meeting should create cleaned audio + transcript files.
if run_in_work scripts/dictation meeting --device 0 --duration 3 --name test-meeting --lang en; then
  pass "meeting timed run succeeds"
else
  fail "meeting timed run succeeds"
fi
assert_file "${WORK_ROOT}/sessions/test-meeting/raw.wav" "meeting writes raw audio"
assert_file "${WORK_ROOT}/sessions/test-meeting/clean.wav" "meeting writes cleaned audio"
assert_file "${WORK_ROOT}/sessions/test-meeting/clean.txt" "meeting writes transcript txt"
assert_file "${WORK_ROOT}/sessions/test-meeting/clean.vtt" "meeting writes transcript vtt"

# 3) default model preference should pick medium when present.
: > "${WHISPER_ARGS_LOG}"
if run_in_work scripts/dictation transcribe --input sessions/test-meeting/clean.wav --lang en; then
  pass "transcribe with defaults succeeds"
else
  fail "transcribe with defaults succeeds"
fi
assert_grep "-m ${WORK_ROOT}/models/ggml-medium.bin" "${WHISPER_ARGS_LOG}" "default model prefers medium"

# 4) fallback to small when medium missing.
rm -f "${WORK_ROOT}/models/ggml-medium.bin"
: > "${WHISPER_ARGS_LOG}"
if run_in_work scripts/dictation transcribe --input sessions/test-meeting/clean.wav --lang en; then
  pass "transcribe fallback succeeds"
else
  fail "transcribe fallback succeeds"
fi
assert_grep "-m ${WORK_ROOT}/models/ggml-small.bin" "${WHISPER_ARGS_LOG}" "default model falls back to small"

# 5) summarize should write markdown output.
if run_in_work scripts/dictation summarize --input sessions/test-meeting/clean.txt --ollama-model qwen2.5:7b; then
  pass "summarize succeeds"
else
  fail "summarize succeeds"
fi
assert_file "${WORK_ROOT}/sessions/test-meeting/clean.summary.md" "summarize writes summary markdown"


echo
if [ "${FAIL_COUNT}" -eq 0 ]; then
  echo "All tests passed (${PASS_COUNT} checks)."
  exit 0
else
  echo "Tests finished with failures: ${FAIL_COUNT} failed, ${PASS_COUNT} passed."
  exit 1
fi
