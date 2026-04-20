# SMucK Documentation

Guides and reference for building, editing, and playing symbolic music in ChucK. Start with [Basic Playback](./walkthru.html) if you're new; use the links below to jump to specific topics.

---

## Getting started

**[Basic Playback](./walkthru.html)** — Minimal overview: create a score, attach instruments, play. Start here if you're new to SMucK.

---

## Score creation

**[SMucKish Rosetta Stone](./smuckish.html)** — The input syntax for pitches, rhythms, dynamics, chords, and more. Use this when writing music as strings.

**[Building scores](./building-scores.html)** — How to assemble scores from measures, parts, and SMucKish. Covers constructors, `add()`, and the score hierarchy.

**[Editing scores](./editing-scores.html)** — Mutating existing scores: `add`, `insert`, `replace`, `erase`, `duplicate`, `copy`, `split`, `meter`.

---

## Import and I/O

**[MIDI import](./midi-import.html)** — Reading MIDI files with `read()`, CC/aftertouch import, and using `meter()` for playback performance.

**[Score I/O](./score-io.html)** — Saving and loading scores as JSON with `smIO`.

---

## Playback

**[ezInstrument design](./ezinstrument.html)** — Designing custom instruments: synth patterns, SndBuf repitching, FluidSynth, and more. *(In progress)*

---

## Reference

**[Chord/Scale Dictionary](./dictionary.html)** — Scale and chord input rules, definitions, and supported symbols.

**[API Reference](../api/)** — Class and method reference (ezNote, ezMeasure, ezPart, ezScore, ezInstrument, etc.).
