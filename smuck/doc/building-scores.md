# Building scores

SMucK scores are built from a hierarchy: **ezNote** → **ezMeasure** → **ezPart** → **ezScore**. How you construct a score depends on your use case: quick notation with SMucKish strings, programmatic generation from notes, or importing from MIDI. This page covers the first two; for MIDI, see [MIDI import](./midi-import.html).

# The hierarchy

```
ezScore
  ezPart
    ezMeasure
      ezNote (and optionally ezCC)
```

A score contains one or more parts (e.g. melody, bass, drums). Each part contains measures. Each measure contains notes and optionally CC (control change) events. Onsets and durations are in beats (not absolute time).

# Top-down: SMucKish strings

The simplest approach is to pass SMucKish strings directly to constructors. This works well when you're writing music by hand or have pre-formatted notation. See the [SMucKish Rosetta Stone](./smuckish.html) for the full syntax.

### Single-part score

For a single line of music, the `ezScore` constructor accepts a SMucKish string directly. This creates one part with one measure.

```
ezScore score("a b c d e f g a");
```

### Multi-part score

For multiple concurrent parts, create `ezPart` objects and add them to the score. Each part gets its own instrument during playback.

```
ezPart part1("a b c d");
ezPart part2("e f g a");
ezScore score;
score.add([part1, part2]);
```

### Multi-measure part

When a part includes multiple measures, you can create multiple `ezMeasure` objects and `add()` them to the part.

```
ezMeasure m1("a b c d");
ezMeasure m2("e f g a");
ezPart part;
part.add([m1, m2]);
ezScore score;
score.add(part);
```

You can also pass an array of SMucKish strings to the `ezPart` constructor:

```
ezPart part(["a b c d", "e f g a", "g a b c"]);
```

# Bottom-up: Notes and measures

When you're generating music programmatically—e.g. from algorithms, randomness, or external data—build from `ezNote` objects. Each note has onset (beats from measure start), duration (beats), pitch (MIDI number), and velocity (0.0–1.0).

### From ezNote objects

```
ezNote n1(0.0, 1.0, 60, 0.8);  // onset, beats, pitch, velocity
ezNote n2(1.0, 1.0, 64, 0.7);
ezMeasure m;
m.add([n1, n2]);
ezPart part;
part.add(m);
ezScore score;
score.add(part);
```

### From ezMeasure(ezNote[])

The `ezMeasure` constructor accepts an array of `ezNote` objects, which can be convenient when you've already built the note array.

```
ezNote n1(0.0, 1.0, 60, 0.8);
ezNote n2(1.0, 1.0, 64, 0.7);
ezMeasure m([n1, n2]);
ezPart part;
part.add(m);
ezScore score;
score.add(part);
```

### Adding CCs to measures

Measures can also hold CC (control change) events—volume, modulation, pan, etc. Add them with `measure.add(ezCC)` or `measure.add(ezCC[])`. CCs are routed to instruments during playback via the `cc(ezCC)` override. See [ezcc-basic.ck](../examples/basic/ezcc-basic.ck) and the [MIDI import](./midi-import.html) page.

```
ezMeasure m("c4 e g c5");
ezCC.volume(0, 64, 0.0) @=> ezCC volStart;
ezCC.volume(0, 127, 2.0) @=> ezCC volEnd;
m.add([volStart, volEnd]);
```

# Choosing an approach


| Approach                  | Best for                                                      |
| ------------------------- | ------------------------------------------------------------- |
| **SMucKish constructors** | Writing scores by hand in ChucK, quick simple sketches        |
| **Bottom-up (ezNote)**    | Algorithmic composition, generative music, data-driven scores |
| **MIDI import**           | Existing MIDI files, DAW exports                              |


You can mix approaches: e.g. build a part from SMucKish, then insert or replace individual measures built from notes.
