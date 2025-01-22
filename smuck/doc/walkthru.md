# Basic Playback with SMucK
- [Overview](#overview)
- [Background: Class Heirarchy](#background-class-heirarchy)
- [Creating an ezScore      (1)](#creating-an-ezscore-1)
- [Creating an ezInstrument (2)](#creating-an-ezinstrument-2)
- [Playing an ezScore       (3)](#playing-an-ezscore-3)
- [Full Example](#full-example)

# Overview
Playing a score with SMucK is as easy as 1, 2, 3!

(1) Create an `ezScore` object

(2) Make your own instruments (extending `ezInstrument`)

(3) Create an `ezScorePlayer`, choose it's score/instruments, and play!

### Minimal Example
```
// example.ck - creation and playback of a new score with SMucK!
@import "smuck"
ezScore score("a b c d");
ezScorePlayer player(score);
player.preview();             // play with built in preview instrument! (skip step (2))
eon => now;
```

<br>

# Background: Class Heirarchy
For this walkthrough, it might be helpful to understand the structure of the `ezScore` class.
```txt
Class Heirarchy:

ezScore
  ezPart
    ezMeasure
      ezNote
```
Please refer to the [SMucK API Reference](../api/) for more details about each class.

### Minimal Example
To access the first note of the first measure of the first part of an ezScore object `score`, you would write:
```
score.parts[0].measures[0].notes[0]
```

<br>

# Creating an `ezScore` (1)

### Method 1: SMucKish 🎶

SMucKish is a string-based syntax for writing music in SMucK. You can read more about the syntax 
on the <a href="./smuckish.html" target="_blank">SMucKish Rosetta Stone</a>.

You can create an `ezScore` object by passing a SMucKish string to the constructor.
  ```
  ezScore score("a b c d")
  ```

<br>

For multi-part scores, create `ezPart` objects and add them to the `ezScore` object.
  ```
  ezPart part1("a b c d")
  ezPart part2("f g a b")

  ezScore score;
  score.addPart(part1);
  score.addPart(part2);
  ```
  
<br>

For multiple measures, create `ezMeasure` objects and add them to the `ezPart` object.
  ```
  ezMeasure measure1("a b c d")
  ezMeasure measure2("f g a b")

  ezPart part;
  part.addMeasure(measure1);
  part.addMeasure(measure2);

  ezScore score;
  score.addPart(part);
  ```

<br>

### Method 2: Importing MIDI 🎹
You can read a MIDI file into an ezScore object with the constructor
```
ezScore score("PATH/TO/MIDI/file.mid");
```
or the `importMIDI` method
```
ezScore score;
score.importMIDI("PATH/TO/MIDI/file.mid");
```

<br>

**Note:** When exporting a MIDI file with multiple parts, make each part includes the appropriate amount of silence at the beginning.
For example, if part 1 starts at 0:00, and part 2 starts at 0:15, then part 2 should include 15 seconds of silence at the beginning.


<br>

# Creating an `ezInstrument` (2)
Before you can play back an `ezScore`, you need to create your own `ezInstrument`'s for each part of the score.
These instruments will be used to play back the score.
### Requirements
- `ezInstrument` is an abstract class, so you must extend it to create your own custom instrument.
- `ezInstrument` has two required functions: `noteOn` and `noteOff`.
- `ezInstrument` also has a required `n_voices` variable that describes how many voices the instrument has for polyphony.

### Basic Example
```
// myInstrument.ck
public class myInstrument extends ezInstrument
{
    // how many voices our instrument has (for polyphony)
    10 => n_voices;
    SinOsc oscs[n_voices];
    Gain g => outlet;     // outlet lets us connect to any output! (e.g. myInstrument inst => Nrev rev => dac)
    g.gain(0.1);
    for (0 => int i; i < n_voices; i++)
    {
        oscs[i].gain(0);  // we want each osc to be silent before a note is played
        oscs[i] => g;
    }
    
    // what our instrument does when a note is played
    fun void noteOn(ezNote note, int voice)
    {
        Std.mtof(note.pitch) => oscs[voice].freq;
        note.velocity / 127.0 => oscs[voice].gain;
    }

    // what our instrument does when a note is released
    fun void noteOff(int voice)
    {
        0 => oscs[voice].gain;
    }
}
```
Polyphony is handled automatically by the `ezScorePlayer`. The `ezInstrument` functions receive a `voice` argument
that describes which "voice" of the instrument to turn on or off.

<br>

# Playing an `ezScore` (3)
For the examples below, we'll assume that we have an `ezScore` object `score`, and a custom instrument class `myInstrument`.
The score has two parts, each of which will be played by one of our instruments.

### a. Creating an `ezScorePlayer`
```
ezScorePlayer player(score);
```

<br>

### b. Setting the instruments 🎷🎹
i. Create your instruments and connect them an output of your choice.
```
Gain g => Nrev rev => dac;
myInstrument instrument1 => g;
myInstrument instrument2 => g;
```

<br>

ii. Set the player's instruments.
```
player.setInstrument(0, instrument1);   // use instrument1 for part 0 of the score
player.setInstrument(1, instrument2);   // use instrument2 for part 1 of the score
```
OR
```
player.setInstrument(@[instrument1, instrument2]);
```

<br>

### c. Playing the score ⏯️
To play the score, call the `play` method on our `player` object.
```
player.play();
eon => now;
```

<br>

You can also pause or stop the score!
```
player.play();
5::second => now;
player.pause();
1::second => now;
player.play();
5::second => now;
player.stop();
```

<br>

You can even enable looping and change playback rate!
```
true => player.loop;
1.5 => player.rate;
player.play();
10::second => now;
-0.7 => player.rate;
10::second => now;
```

<br>

# Full Example
```
@import "smuck";
@import "myInstrument";   // the instrument we created in step (2)

// 1. Create the score
ezPart part0("a b c d");
ezPart part1("c d e f");
ezScore score;
score.addPart(part0);
score.addPart(part1);

// 2. Create our instruments
myInstrument inst1 => dac;
myInstrument inst2 => dac;

// 3. Play the score
ezScorePlayer player(score);
player.setInstrument(@[inst1, inst2]);
player.play();
10::second => now;
```

Congratulations! You can now write and play music with SMucK!

