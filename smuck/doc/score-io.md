# Score I/O

The `smIO` class reads and writes `ezScore` objects as JSON files. This is useful for saving work in progress, exchanging scores with other tools, or debugging (the JSON is human-readable). Requires the **HashMap** chugin—run `chump install HashMap` if you haven't already.

<br>

# Saving a score

```
@import {"smuck", "smuck/smIO.ck"}

ezScore score("a b c d e f g a");
score.bpm(120);

smIO.scoreToJson("my_score.json", score);
```

Use a path built from the script directory when you need a predictable location (e.g. for headless execution or when the working directory may vary):

```
me.dir() + "score.json" => string filepath;
smIO.scoreToJson(filepath, score);
```

If the filename doesn't end in `.json`, `smIO` will append it.

<br>

# Loading a score

```
@import {"smuck", "smuck/smIO.ck"}

smIO.jsonToScore("my_score.json") @=> ezScore loaded;
```

With a filepath:

```
me.dir() + "score.json" => string filepath;
smIO.jsonToScore(filepath) @=> ezScore loaded;
```

The loaded score has the same structure as the original: parts, measures, notes, CCs, BPM, and text annotations. You can play it, edit it, or save it again.

<br>

# What gets saved

The JSON format stores notes (onset, beats, pitch, velocity, rest, text, data), measures (notes, CCs, onset, text), parts (measures, text), and score-level metadata (BPM, text). The structure mirrors the SMucK hierarchy, so you can inspect or modify the file by hand if needed.

<br>

# Example

See [smio-json.ck](../examples/basic/smio-json.ck) for a complete example: create a score, save to JSON, load it back, and verify the note count before playing.
