# Setup Guide (macOS)

## 1) Requirements

- macOS
- Homebrew (`brew`)
- Xcode Command Line Tools

Install CLT if needed:
```bash
xcode-select --install
```

## 2) Install Dictation Stack

From project root:
```bash
cd /Users/facere/Fun/Tools
scripts/setup_local_dictation.sh medium
```

This will:
- ensure `ffmpeg` and `cmake` are installed
- clone/build `whisper.cpp`
- download `models/ggml-medium.bin`

## 3) Start the Launcher

Run directly:
```bash
"/Users/facere/Fun/Tools/Quick Dictation.command"
```

Optional alias:
```bash
alias dictation='"/Users/facere/Fun/Tools/Quick Dictation.command"'
```

Add that alias to `~/.zshrc` to keep it permanently.

## 4) Recording Flow

1. Start `dictation`
2. Select device (Enter defaults to `0`)
3. Set session name (optional)
4. Set timer in minutes:
- blank = manual mode (with controls)
- number = timed mode

Manual controls:
- `p` pause
- `r` resume
- `s` stop and transcribe

## 5) Duration Cap (Configurable)

- Default max recording length: `480` minutes (8 hours).
- Applies even in manual mode as a safety stop.
- Change per run:
```bash
DICTATION_MAX_MINUTES=360 dictation
```

## 6) Output Files

Each session creates:
- `sessions/<session-name>/raw.wav`
- `sessions/<session-name>/clean.wav`
- `sessions/<session-name>/clean.txt`
- `sessions/<session-name>/clean.vtt`

## 7) Language and Accent Guidance

- Mostly English: `--lang en` (default)
- Afrikaans-heavy: `--lang af`
- Mixed speech: `--lang auto`

For South African English/Afrikaans, `medium` model is recommended.

## 8) Sleep / Lid Behavior

- Launcher uses `caffeinate` during recording to help keep Mac awake with lid open.
- Closing the lid usually sleeps macOS and will interrupt/stop recording.
- For long meetings, keep lid open, plugged in.

## 9) Optional Local Summary

Install Ollama model (example):
```bash
ollama pull qwen2.5:7b
```

Then summarize:
```bash
scripts/dictation summarize --input sessions/<session>/clean.txt --ollama-model qwen2.5:7b
```

## 10) Tests

Run:
```bash
tests/test_dictation.sh
```

## 11) Troubleshooting

Homebrew permission issues:
- fix ownership/permissions for Homebrew paths, then rerun setup

No microphones listed:
- check Terminal mic permissions in macOS Privacy settings
- run `scripts/dictation list-devices`

No transcript produced:
- ensure model exists in `models/`
- ensure `vendor/whisper.cpp/build/bin/whisper-cli` exists

Poor quality:
- use external mic closer to speakers
- reduce room echo and cross-talk
- use `medium` model
