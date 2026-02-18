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

What this does:
- Ensures `ffmpeg` and `cmake` are installed
- Clones/builds `whisper.cpp`
- Downloads model to `models/ggml-medium.bin`

## 3) One-Click Launcher

Run directly:
```bash
"/Users/facere/Fun/Tools/Quick Dictation.command"
```

Optional alias:
```bash
alias dictation='"/Users/facere/Fun/Tools/Quick Dictation.command"'
```

Persist alias in `~/.zshrc` if you want.

## 4) First Recording

1. Start launcher (`dictation` or double-click file)
2. Choose device index (Enter defaults to `0`)
3. Set session name or press Enter
4. Timer in minutes:
- blank = manual mode
- number = timed auto-stop

Manual mode controls:
- `p` pause
- `r` resume
- `s` stop and continue to transcription

## 5) Output Files

Saved in:
- `sessions/<session-name>/raw.wav`
- `sessions/<session-name>/clean.wav`
- `sessions/<session-name>/clean.txt`
- `sessions/<session-name>/clean.vtt`

## 6) Language and Accent Guidance

- Mostly English meetings: `--lang en` (default)
- Afrikaans meetings: `--lang af`
- Mixed speech: `--lang auto`

`medium` model is recommended for South African English/Afrikaans accents.

## 7) Optional Local Summary

Install Ollama and model (example):
```bash
ollama pull qwen2.5:7b
```

Then summarize transcript:
```bash
scripts/dictation summarize --input sessions/<session>/clean.txt --ollama-model qwen2.5:7b
```

## 8) Troubleshooting

Homebrew permission errors:
- Fix ownership/permissions for Homebrew directories, then rerun setup.

No microphones listed:
- Check macOS mic permissions for Terminal.
- Re-run: `scripts/dictation list-devices`

Recording stops but no transcript:
- Confirm `models/ggml-medium.bin` or `models/ggml-small.bin` exists.
- Confirm `vendor/whisper.cpp/build/bin/whisper-cli` exists.

Poor transcription quality:
- Use external mic closer to speakers
- Reduce room echo
- Keep cross-talk minimal
- Prefer `medium` model
