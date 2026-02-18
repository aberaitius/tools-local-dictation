# Local Dictation (macOS, fully local)

This project gives you a lightweight local dictation workflow with:
- Local recording from a selected input device (Mac mic or external mic)
- Local noise cleanup before transcription
- Local transcription with `whisper.cpp` (English + Afrikaans support)
- Optional local AI meeting summary with `ollama`

No API calls are required.

## 1) One-time setup

```bash
scripts/setup_local_dictation.sh small
```

Model options:
- `tiny` / `base` / `small` = lighter/faster
- `medium` = better for accents/noisy environments

If you need better South African accent robustness, use:

```bash
scripts/setup_local_dictation.sh medium
```

## 2) List microphones

```bash
scripts/dictation list-devices
```

Use the audio index shown by `ffmpeg`.

## 3) Record only

```bash
scripts/dictation record --device 0 --name client-meeting
```

Optional timed recording:

```bash
scripts/dictation record --device 0 --duration 3600 --name client-meeting
```

Output is saved under `sessions/<name>/`.

## 4) Transcribe a recording

```bash
scripts/dictation transcribe --input sessions/client-meeting/clean.wav --lang en
```

Force Afrikaans:

```bash
scripts/dictation transcribe --input sessions/client-meeting/clean.wav --lang af
```

Force English:

```bash
scripts/dictation transcribe --input sessions/client-meeting/clean.wav --lang en
```

## 5) End-to-end meeting run

Record + transcribe in one command:

```bash
scripts/dictation meeting --device 0 --name client-meeting --lang en
```

Record + transcribe + summarize (if `ollama` is installed):

```bash
scripts/dictation meeting --device 0 --name client-meeting --lang en --ollama-model qwen2.5:7b
```

## 6) Summarize an existing transcript

```bash
scripts/dictation summarize --input sessions/client-meeting/clean.txt --ollama-model qwen2.5:7b
```

## Notes on quality

- For long-form client meetings, `small` is a good default, `medium` is better accuracy.
- The script auto-prefers `models/ggml-medium.bin` when available (falls back to `small`).
- Noise cleanup uses stronger speech-focused filtering (denoise + compression + speech normalization).
- Default language is English (`en`) for better accuracy in mostly-English meetings. Use `--lang af` for Afrikaans or `--lang auto` for mixed speech.
- Everything runs locally on your machine; no recurring usage cost.
