# SMucK Scale Dictionary

- [SMucK Scale Input](#smuck-scale-input)
- [Basic scales](#basic)

## SMucK Scale Input
The `smuckish` class has the method `.scale()` which allows for easy conversion of scale names to MIDI note numbers. It optionally takes an additional argument to specify the root note of the scale. Example usage:

```
// Basic usage
smuckish.scale("major") @=> int my_scale[]; 
// my_scale is now an array of MIDI note numbers [0, 2, 4, 5, 7, 9, 11]

// Specify root note as int
smuckish.scale("major", 60) @=> int my_scale[]; 
// my_scale is now an array of MIDI note numbers [60, 62, 64, 65, 67, 69, 71]

// Specify root note as string
smuckish.scale("major", "c5") @=> int my_scale[]; 
// my_scale is now an array of MIDI note numbers [72, 74, 76, 77, 79, 81, 83]
```

A full list of the supported scale names and their definitions can be found below.

## Major/Minor

<div style="text-align: center;">
  <img src="../images/scales/major.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Major scale: "major"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/minor.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Minor scale: "minor"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/minor-melodic.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Melodic minor scale: "melodicminor"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/minor-harmonic.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Harmonic minor scale: "harmonicminor"</p>
</div>

## Pentatonic/Hexatonic
<div style="text-align: center;">
  <img src="../images/scales/blues.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Blues scale: "blues"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/major-pent.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Major pentatonic scale: "major_pentatonic"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/minor-pent.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Minor pentatonic scale: "minor_pentatonic"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/major-hex.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Major hexatonic scale: "major_hexatonic"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/minor-hex.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Minor hexatonic scale: "minor_hexatonic"</p>
</div>

## Symmetric
<div style="text-align: center;">
  <img src="../images/scales/whole-tone.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Whole tone scale: "wholetone"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/augmented.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Augmented scale: "augmented"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/half-whole.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Half-whole Octatonic scale: "half_whole"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/whole-half.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Whole-half Octatonic scale: "whole_half"</p>
</div>

## Greek Modes

<div style="text-align: center;">
  <img src="../images/scales/ionian.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Ionian mode: "ionian"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/dorian.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Dorian mode: "dorian"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/phrygian.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Phrygian mode: "phrygian"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/lydian.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Lydian mode: "lydian"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/mixolydian.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Mixolydian mode: "mixolydian"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/aeolian.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Aeolian mode: "aeolian"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/locrian.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Locrian mode: "locrian"</p>
</div>

## Altered Modes

<div style="text-align: center;">
  <img src="../images/scales/major-harmonic.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Major harmonic scale: "major_harmonic"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/minor-harmonic.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Minor harmonic scale: "minor_harmonic"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/phrygian-dominant.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Phrygian dominant scale: "phrygian_dominant"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/lydian-dominant.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Lydian dominant scale: "lydian_dominant"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/lydian-augmented.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Lydian augmented scale: "lydian_augmented"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/major-locrian.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Major locrian scale: "major_locrian"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/supralocrian.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Supralocrian scale: "supralocrian"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/neapolitan-major.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Neapolitan major scale: "neapolitan_major"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/neapolitan-minor.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Neapolitan minor scale: "neapolitan_minor"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/half-diminished.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Half diminished scale: "half_diminished"</p>
</div>

## "Exotic" Scales

<div style="text-align: center;">
  <img src="../images/scales/double-harmonic.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Double harmonic scale: "double_harmonic"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/enigmatic.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Enigmatic scale: "enigmatic"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/gypsy.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">"Gypsy" scale: "gypsy"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/minor-hungarian.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Hungarian minor scale: "hungarian_minor"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/major-hungarian.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Hungarian major scale: "hungarian_major"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/persian.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Persian scale: "persian"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/prometheus.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Prometheus scale: "prometheus"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/in.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">In scale: "in"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/insen.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Insen scale: "insen"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/iwato.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Iwato scale: "iwato"</p>
</div>
<div style="text-align: center;">
  <img src="../images/scales/yo.svg" alt="Alt text" width="60%">
  <p style="font-style: italic;">Yo scale: "yo"</p>
</div>
