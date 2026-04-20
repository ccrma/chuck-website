# Editing scores

Once you have a score, you can mutate it: add, insert, replace, erase, or duplicate measures; add or replace notes and CCs; split long measures; or copy sections without modifying the original. Editing is useful after MIDI import (to fix layout or split long measures), for algorithmic composition (repeating phrases, varying sections), or when reusing fragments across scores.

<br>

# Part-level editing (ezPart)

### add

Append measures to the end of a part. Use this when extending a score or building incrementally.

```
part.add(measure);
part.add([m1, m2, m3]);
```

<br>

### insert

Insert one or more measures at a given index. Use negative indices to count from the end: `-1` is the last measure, `-2` is second-to-last, etc.

```
part.insert(2, measure);      // insert at index 2
part.insert(-1, measure);     // insert before the last measure
part.insert(0, [m1, m2]);     // insert at the beginning
```

<br>

### replace

Replace one measure or a range of measures. The replacement can have a different number of measures than the original range.

```
part.replace(0, newMeasure);              // replace measure at index 0
part.replace(1, 3, [m1, m2, m3]);         // replace 3 measures starting at index 1
part.replace(2, 2, [shortM, longM]);      // replace 2 measures with 2 different ones
```

<br>

### erase

Remove measures. Useful for trimming intros/outros or removing sections.

```
part.erase(2);           // erase measure at index 2
part.erase(1, 3);        // erase 3 measures starting at index 1
```

<br>

### duplicate

Repeat a range of measures a given number of times. The duplicated measures are inserted immediately after the range. Use this for repeated choruses, verses, or ostinatos.

```
part.duplicate(0, 2, 3);   // duplicate measures 0–1, insert 3 copies after
part.duplicate(-1, 1);     // duplicate the last measure once
```

<br>

# Measure-level editing (ezMeasure)

### add

Add notes or CCs to an existing measure. Notes and CCs should have onsets within the measure's time span. Call `sort()` after adding if onsets might be out of order.

```
measure.add(note);
measure.add([n1, n2]);
measure.add(ezCC.volume(0, 64, 0.0));
measure.sort();   // sort by onset if needed
```

<br>

### notes / ccs getters and setters

Replace all notes or CCs in a measure. Setting replaces the existing array.

```
measure.notes([n1, n2, n3]);
measure.ccs([cc1, cc2]);
```

<br>

# Copying

Use `copy()` when you want to duplicate a measure, part, or excerpt without mutating the original. This is useful for creating variations (edit the copy) or for passing a subset to another score.

```
part.copy() @=> ezPart part2;
part.copy(1, 4) @=> ezPart excerpt;   // copy measures 1–4 into a new part
measure.copy() @=> ezMeasure m2;
```

Note: `copy()` returns a deep copy—notes and CCs are duplicated, so changes to the copy do not affect the original.

<br>

# Splitting and meter

### split (ezMeasure)

Split a long measure into shorter ones. Each resulting measure contains notes whose onsets fall in that time window; onsets are adjusted to be relative to the new measure. Useful when you've built or imported a measure that spans many beats and want to impose bar lines.

```
measure.split(4.0) @=> ezMeasure newMeasures[];           // 4-beat bars
measure.split([4.0, 3.0, 4.0]) @=> ezMeasure newMeasures[];  // variable lengths
```

<br>

### meter (ezPart, ezScore)

Impose bar lengths or time signatures on all measures in a part (or all parts in a score). Empty measures are skipped. This is especially useful after MIDI import, when each track often becomes one long measure—calling `score.meter(4.0)` splits them into 4-beat bars and improves playback performance. See [MIDI import](./midi-import.html).

```
part.meter(4.0);              // 4 beats per bar
part.meter("3/4");            // time signature (quarter = 1 beat)
part.meter([4.0, 3.0, 4.0]);  // variable bar lengths
score.meter(4.0);             // applies to all parts
```

<br>

# normalizeNegativeOnsets (ezPart)

After MIDI import or manual editing, some notes may have negative onsets (e.g. notes that start before the measure due to ties or import quirks). `normalizeNegativeOnsets()` moves those notes into the correct measure and recomputes onsets. Do not use this on parts where negative onsets are intentional (e.g. notes tied over the barline from the previous measure).

```
part.normalizeNegativeOnsets();
```

<br>

# Saving your edits

After you've edited a score, you can save it to a JSON file using the `smIO` class. See [Score I/O](./score-io.html) for more details.