# SMucKish: The input language of SMucK

- [Pitch](#pitch)
    - [Construction of a Pitch](#construction-of-a-pitch)
    - [Proximity and Octaves](#proximity-and-octaves)
    - [Key Signatures and Accidentals](#key-signatures-and-accidentals)
- [Rhythm](#rhythm)
- [Dynamics](#dynamics)
- ["Interleaved" Input](#interleaved-input)
- ["Multi-stage" Input](#multi-stage-input)



<!-- ```
dsfjsdlfjsdklfs
```
![interleaved 1](../images/smuckish/interleaved_1.svg)

## Multi-stage Input Syntax -->


# Pitch

### Construction of a Pitch
```
[STEP][ACCIDENTAL (optional)][OCTAVE (optional)]
```
- `STEP` possible values:
  - `a`, `b`, `c`, `d`, `e`, `f`, `g`
- `ACCIDENTAL` possible values:
  - `#`, `b` (can be repeated an arbitrary number of times)
  - `n`
- `OCTAVE` possible values:
  - `0`, `1`, `2`,..., `INT_MAX`
  - `u` or `d` (can be repeated an arbitrary number of times)

For example, the following are all valid SMucKish pitches:
```txt
a
c#
db
fn
c#####
cbbbb
c3
c#5
c#99999 (this will be way too high to hear, but go ahead ¯\_(ツ)_/¯)
c#u
c#d
c#uuuuuu
c#dddddddddd (floor of C-1, or about 8hz)
```


### Proximity and Octaves

By default, SMucKish uses the **proximity** of a pitch to the previous pitch to determine its octave. In the case of a 7 semitone jump (e.g. `c` to `f#`), the 2nd note will be above the 1st note.
```
ezMeasure measure("c d c e c f c f# c g c a c b c c");
```
![interleaved 1](../images/smuckish/pitch_proximity.svg)

We can also specify the octave **explicitly**. This overrides proximity-based octaves.
```
ezMeasure measure("a1 a2 a3 a4 a5 a6");
```
![interleaved 1](../images/smuckish/)

We can also use `u`'s and `d`'s as a **shortcut** to move up and down octaves.
```
ezMeasure measure("c4 eu c ed ed fuu");
```
![interleaved 1](../images/smuckish/pitch_ud.svg)
<!-- ```
ezMeasure measure("c4 cu cd eu ed c cuu cddd");
``` -->

### Key Signatures and Accidentals

Here we specify the key signature of A major (3 sharps).
```
ezMeasure measure("k3# a b c d e f g a")
```
![interleaved 1](../images/smuckish/)

We can add accidentals (sharps, flats, naturals) to the notes, which override the key signature. While the **key signature 
persists** across a SMucKish string, **accidentals do not** and must be specified for each note.
```
ezMeasure measure("k3# a b cn c d e f gb g a");
```
![interleaved 1](../images/smuckish/pitch_accidentals.svg)

We can also specify an arbitrary number of sharps and flats. Sharps, flats, and naturals override the key signature.
```
ezMeasure measure("c4 c# c c## c cb c cbb c##### cbbbbb");
```
![interleaved 1](../images/smuckish/)

### Rests


# Rhythm
### Basic Rhythms
```
smuckish.rhythms("w h q e s")
```
![interleaved 1](../images/smuckish/)

### Tuplets
```
smuckish.rhythms("tq tq tq")
```
![interleaved 1](../images/smuckish/)

### 
```
smuckish.rhythms(")
```
![interleaved 1](../images/smuckish/)




# Dynamics
### Dynamic Markings
### Velocities

# "Interleaved" Input
The "interleaved" input syntax is a way to specify pitch, rhythm, and dynamics in a single string. As a quick example:
```
Measure measure("ks1 c4|q|mf d e f g|e|mp a b c");
```
Output:
![interleaved 1](../images/smuckish/interleaved_1.svg)
