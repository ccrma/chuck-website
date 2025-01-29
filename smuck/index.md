<div align="center">
<!-- Add ChuGL logo -->
<!-- <img align="left" style="width:260px" src="https://github.com/raysan5/raylib/blob/master/logo/raylib_logo_animation.gif" width="288px"> -->

<img src="images/smuck-logo.svg" width="100%"></img>

<h2>SMucK ~&gt; Symbolic Music in ChucK</h2>

</div> <!-- end center -->


<p align="justify">

<b>SMucK</b> is a framework for writing music in ChucK with symbolic music notation.


SMucK was created by <a href="https://ccrma.stanford.edu/~alexhan/">Alex Han</a>,
<a href="https://kiranvbhat.com/">Kiran Bhat</a>, and <a href="https://ccrma.stanford.edu/~ge/">Ge Wang</a>, 
with support from the <a href="../doc/authors.html">ChucK Team</a>.
</p>

<!-- ![logo](images/chugl-banner.jpg) -->

---

**SMucK v0.0.0** (pre-alpha) — [**SMucK API Reference**](./api/)
• [**SMucK Cheatsheet**](./doc/cheatsheet.html)
• [**SMucKish Rosetta Stone**](./doc/smuckish.html)
• [**Basic Playback**](./doc/walkthru.html)
• [**Examples**](./examples/)
___

## Installation

First, download the latest release of SMucK here (this is a pre-alpha release made specially for use in Music 220B):

<!-- *Original release*[Download SMucK Source](./smuck-220b.zip) -->

*01/29/2025 Update:* 
<br>

*fixed some playback bugs, reworked API naming conventions (see API Reference), added several ezInstrument extended classes for MIDI/OSC handling*

[Download SMucK Source](./smuck-220b_01292025.zip)

<br>

### macOS / Linux

1. Un-zip the file and get the filepath (for instance, `~/Downloads/smuck-220b`)
2. Copy the contents to `~/.chuck/lib` with the following command, replacing `[YOUR_FILEPATH]` with the filepath you got from step 1:

    ```txt
    cp -r [YOUR_FILEPATH]/* ~/.chuck/lib
    ```
    If you get the error `cp: ~/.chuck/lib is not a directory`, try the following command instead:
    ```txt
    sudo cp -r [YOUR_FILEPATH]/* /usr/local/lib/chuck
    ```

### Windows
1. Un-zip and copy the contents of `smuck-220b.zip` to one of the following directories:
    ```txt
    C:\Windows\system32\ChucK
    C:\Program Files\ChucK\chugins
    C:\Program Files (x86)\ChucK\chugins
    C:\Users\%USERNAME%\Documents\ChucK\chugins
    ```

## Running

### Minimal Example

If the SMucK library is properly loaded, the following example will run without errors:

```
// example.ck
@import "smuck-220b"
```

Congrats, you now have SMucK properly installed!

## Learning Resouces

- [API Reference](./api/)
- [SMucK Cheatsheet](./doc/cheatsheet.html)
- [SMucKish Rosetta Stone](./doc/smuckish.html)
- [Basic Playback](./doc/walkthru.html)
- [Examples](./examples/)
