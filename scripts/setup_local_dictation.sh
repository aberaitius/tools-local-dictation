#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDOR_DIR="${ROOT_DIR}/vendor"
WHISPER_DIR="${VENDOR_DIR}/whisper.cpp"
MODELS_DIR="${ROOT_DIR}/models"
MODEL_NAME="${1:-small}"

mkdir -p "${VENDOR_DIR}" "${MODELS_DIR}"

if ! command -v ffmpeg >/dev/null 2>&1 || ! command -v cmake >/dev/null 2>&1; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "Missing ffmpeg/cmake and Homebrew is not installed. Install from https://brew.sh" >&2
    exit 1
  fi

  brew install ffmpeg cmake
fi

if [ ! -d "${WHISPER_DIR}" ]; then
  git clone https://github.com/ggml-org/whisper.cpp "${WHISPER_DIR}"
else
  git -C "${WHISPER_DIR}" pull --ff-only
fi

cmake -S "${WHISPER_DIR}" -B "${WHISPER_DIR}/build"
cmake --build "${WHISPER_DIR}/build" -j

if [ ! -f "${MODELS_DIR}/ggml-${MODEL_NAME}.bin" ]; then
  bash "${WHISPER_DIR}/models/download-ggml-model.sh" "${MODEL_NAME}"
  cp "${WHISPER_DIR}/models/ggml-${MODEL_NAME}.bin" "${MODELS_DIR}/"
fi

echo "Setup complete."
echo "Whisper binary: ${WHISPER_DIR}/build/bin/whisper-cli"
echo "Model: ${MODELS_DIR}/ggml-${MODEL_NAME}.bin"
