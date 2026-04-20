# MIDI import

SMucK can read MIDI files into an `ezScore`. Notes, CC (control change), aftertouch, channel pressure, and pitch bend are imported. Each MIDI track becomes one `ezPart`. Import is useful when you have existing MIDI from a DAW, notation software, or other sources, and want to play it back through ChucK instruments or process it symbolically.

<br>

# Basic import

Use `read()` with a file path. Set BPM before or after import as needed; SMucK does not use MIDI tempo meta-events, so you control the playback tempo.

```
ezScore score;
score.bpm(120);
score.read(me.dir() + "/path/to/file.mid");
```

Or use the constructor when the input is a MIDI file (string ending in `.mid`):

```
ezScore score("path/to/file.mid");
```

<br>

# Performance: use meter() for large files

By default, each MIDI track is imported as a single measure. For a long piece, that means one very long measure per part. During playback, the `ezScorePlayer` scans measures to find notes and CCs at the current playhead position. Long measures require more work per tick, which can cause audio glitches or high CPU usage.

**Call `meter()` after import** to split long measures into shorter bars. This reduces the amount of data scanned per tick and improves playback performance.

```
ezScore score;
score.read("large_file.mid");
score.meter(4.0);   // split into 4-beat bars
```

You can use a fixed bar length (e.g. `4.0`), a time signature string (e.g. `"3/4"`), or an array of bar lengths for mixed meter. See [Editing scores](./editing-scores.html) for the full `meter()` API.

Example: [meter-midi.ck](../examples/advanced/meter-midi.ck)

<br>

# What gets imported

- **Notes** — pitch, velocity, onset (in beats), duration. Rests are represented as notes with `isRest() == true`.
- **CC (control change)** — e.g. volume (CC7), modulation (CC1), pan (CC10). Stored as `ezCC` objects in measures.
- **Aftertouch** — polyphonic key pressure.
- **Channel pressure** — monophonic pressure.
- **Pitch bend** — 14-bit value.

CC and related events are routed to instruments during playback. The base `ezInstrument.cc(ezCC)` does nothing; override it in your custom instrument to respond to volume, modulation, etc. See [ezcc-basic.ck](../examples/basic/ezcc-basic.ck) for an example that modulates gain from volume CC.

<br>

# Multi-track MIDI

Each MIDI track becomes one `ezPart`. Parts are ordered by track index. When you set instruments on the `ezScorePlayer`, part 0 gets the first instrument, part 1 gets the second, and so on.

If your MIDI file has multiple tracks with different start times, each track's notes are placed at the correct absolute time within that part. SMucK does not add leading silence to align tracks; the onset of each note is preserved.

<br>

# Creating CC manually

You can also add CC events to measures without importing MIDI. Use the `ezCC` factory methods (`volume()`, `modulation()`, `pan()`, `expression()`, `pitchBend()`, etc.) and `measure.add(ezCC)`. This is useful for adding expression curves, fades, or modulation to SMucKish-generated scores. See [ezcc-basic.ck](../examples/basic/ezcc-basic.ck).
