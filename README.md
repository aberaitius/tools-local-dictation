# Tools Local Dictation

Local, no-cost meeting dictation for macOS with:
- Microphone selection (built-in or external)
- Background-noise cleanup
- Whisper transcription (English, Afrikaans)
- Manual controls (`p` pause, `r` resume, `s` stop)
- Optional local AI summaries

Everything runs locally on your machine.

## Quick Start

1. Install once:
```bash
scripts/setup_local_dictation.sh medium
```

2. Launch recorder:
```bash
"/Quick Dictation.command"
```

3. Choose:
- device index (Enter defaults to `0`)
- session name (Enter auto-generates)
- optional timer in minutes

If timer is blank, recording is manual with `p/r/s` controls.

Outputs go to `sessions/<session-name>/`.

## Recording Limits

- Launcher has a safety cap of `480` minutes (8 hours).
- This cap applies to manual and timed runs.
- Override per run:
```bash
DICTATION_MAX_MINUTES=360 dictation
```

## Main Commands

List devices:
```bash
scripts/dictation list-devices
```

Record + transcribe:
```bash
scripts/dictation meeting --device 0 --name client-meeting --lang en
```

Timed run:
```bash
scripts/dictation meeting --device 0 --duration 3600 --name client-meeting --lang en
```

Transcribe existing audio:
```bash
scripts/dictation transcribe --input sessions/client-meeting/clean.wav --lang en
```

Summarize locally (optional):
```bash
scripts/dictation summarize --input sessions/client-meeting/clean.txt --ollama-model qwen2.5:7b
```

## Accuracy Defaults

- Default language is English (`en`) for mostly-English meetings.
- `models/ggml-medium.bin` is auto-selected when present; otherwise `small`.
- Audio is preprocessed with denoise, compression, and speech normalization.

## Sleep / Lid Behavior

- Launcher runs recording through `caffeinate` to reduce sleep interruptions while lid is open.
- Closing laptop lid usually sleeps macOS and stops recording.
- For long sessions, keep lid open (or use proper clamshell setup with power + external display).

## Tests

Run local CLI tests (mocked dependencies):

```bash
tests/test_dictation.sh
```

For full install/troubleshooting: `SETUP.md`.
