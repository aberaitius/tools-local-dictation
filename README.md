# Tools Local Dictation

Local, no-cost meeting dictation for macOS with:
- Microphone selection (built-in or external)
- Background-noise cleanup
- Whisper transcription (English, Afrikaans)
- Optional local AI summaries

Everything runs locally on your machine.

## Quick Start

1. Run setup once:
```bash
scripts/setup_local_dictation.sh medium
```

2. Launch one-click recorder:
```bash
"/Users/facere/Fun/Tools/Quick Dictation.command"
```

3. In manual mode, controls are:
- `p` pause
- `r` resume
- `s` stop and transcribe

Outputs are saved in `sessions/<session-name>/`.

## Main Commands

List devices:
```bash
scripts/dictation list-devices
```

Record + transcribe (manual stop controls):
```bash
scripts/dictation meeting --device 0 --name client-meeting --lang en
```

Timed recording (seconds):
```bash
scripts/dictation meeting --device 0 --duration 3600 --name client-meeting --lang en
```

Transcribe existing file:
```bash
scripts/dictation transcribe --input sessions/client-meeting/clean.wav --lang en
```

Summarize locally (optional):
```bash
scripts/dictation summarize --input sessions/client-meeting/clean.txt --ollama-model qwen2.5:7b
```

## Accuracy Defaults

- Default language is English (`en`) for mostly-English meetings.
- If available, `models/ggml-medium.bin` is auto-selected (better accent/noise robustness).
- Audio is pre-processed with speech-focused denoise/compression/normalization.

For full installation and troubleshooting, see `SETUP.md`.
