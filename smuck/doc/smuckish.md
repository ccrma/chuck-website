# SMucKish: The input language of SMucK

- [Pitch](#pitch)
    - [Construction of a Pitch](#construction-of-a-pitch)
    - [Proximity and Octaves](#proximity-and-octaves)
    - [Key Signatures and Accidentals](#key-signatures-and-accidentals)
- [Rhythm](#rhythm)
- [Dynamics](#dynamics)
- ["Interleaved" Input](#interleaved-input)
- ["Multi-stage" Input]



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
- `STEP`
  - `a`, `b`, `c`, `d`, `e`, `f`, `g`
- `ACCIDENTAL`
  - `#`, `b` (can be repeated an arbitrary number of times)
  - `n`
- `OCTAVE`
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

By default, SMucKish uses the **proximity** of a pitch to the previous pitch to determine its octave.
```
ezMeasure measure("c d c e c f c g c a c b c c");
```
![interleaved 1](../images/smuckish/interleaved_1.svg)

We can also specify the octave **explicitly**. This overrides the proximity-based octave.
```
ezMeasure measure("a1 a2 a3 a4 a5 a6");
```
![interleaved 1](../images/smuckish/interleaved_1.svg)

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
![interleaved 1](../images/smuckish/interleaved_1.svg)

We can add sharps, flats, and naturals to the notes, which override the key signature. Accidentals don't persist, and must be specified for each note.
```
ezMeasure measure("k3# a b cn c d e fb f g gn a");
```

We can also specify an arbitrary number of sharps and flats. Sharps, flats, and naturals override the key signature.
```
ezMeasure measure("c4 c# c c## c cb c cbb c##### cbbbbb");
```
![interleaved 1](../images/smuckish/interleaved_1.svg)



# Rhythm
### sdflksdjfl
```
smuckish.rhythms("w h q e s")
```
![interleaved 1](../images/smuckish/interleaved_1.svg)

### Tuplets
```
smuckish.rhythms("tq tq tq")
```
![interleaved 1](../images/smuckish/interleaved_1.svg)

```
smuckish.rhythms(")
```
![interleaved 1](../images/smuckish/interleaved_1.svg)

### Subdivisions



```
```
```
ezMeasure measure();
```


# Dynamics

# "Interleaved" Input
The "interleaved" input syntax is a way to specify pitch, rhythm, and dynamics in a single string. As a quick example:
```
Measure measure("ks1 c4|q|mf d e f g|e|mp a b c");
```
Output:
![interleaved 1](../images/smuckish/interleaved_1.svg)



___

## Do collision detection?

[Box2D](https://box2d.org/documentation/) integration is WIP.

For now, you'll have to roll your own collision detection. See the section "Get the Object I'm Clicking On" for links to resources about intersection testing.

Note: if you only need basic collision testing or old-school 2d platformer physics, a general-purpose 2d physics engine like Box2D is way overkill; you can get away with something much simpler. Here are some simple collision-only libraries (no collision resolution) written in  [Lua](https://www.lua.org/) for the [Love2D](https://love2d.org/) game engine. These are ripe for translating to ChucK and using in your own ChuGL app!

- <https://www.love2d.org/wiki/bump.lua>
  - collision detection for AABBs
- <https://www.love2d.org/wiki/HardonCollider>
  - collision detection for scalable and rotatable shapes: rectangles, polygons, circles, points

___

## (Advanced) Dispatch compute shaders?

### CKdoc <!-- omit in toc -->

- [ComputePass](https://chuck.stanford.edu/chugl/api/chugl-pass.html#ComputePass)

### Examples <!-- omit in toc -->

- [rendergraph/boids_compute.ck](https://chuck.stanford.edu/chugl/examples/rendergraph/boids_compute.ck)

### Further Learning Resources <!-- omit in toc -->

- <https://learnopengl.com/Guest-Articles/2022/Compute-Shaders/Introduction>
- <https://webgpufundamentals.org/webgpu/lessons/webgpu-compute-shaders.html>
- <https://math.hws.edu/graphicsbook/c9/s6.html>
- <https://anteru.net/blog/2018/intro-to-compute-shaders/>

___

## (Advanced) Make custom materials / custom vertex and fragment shaders?

This part of the API is unstable, going to hold off on writing documentation. Ask Andrew directly if you need help with this.

(Personal TODO)

- Copy the struct descriptions here.
- Add a `ShaderIncludes` singleton class

___
