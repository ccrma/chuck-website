<div align="center">
<!-- Add ChuGL logo -->
<!-- <img align="left" style="width:260px" src="https://github.com/raysan5/raylib/blob/master/logo/raylib_logo_animation.gif" width="288px"> -->

![logo](images/smuck-logo.png)
<h2>SMucK =&gt; Symbolic Music in ChucK</h2>

</div> <!-- end center -->


<p align="justify">

<b>SMucK</b> is a framework for writing symbolic music in ChucK.


SMucK was created by <a href="https://ccrma.stanford.edu/~alexhan/">Alex Han</a>,
<a href="https://kiranvbhat.com/">Kiran Bhat</a>, and <a href="https://ccrma.stanford.edu/~ge/">Ge Wang</a>, 
with support from the <a href="../doc/authors.html">ChucK Team</a>.
</p>

<!-- ![logo](images/chugl-banner.jpg) -->

---

**ChuGL v0.1.5** (alpha) — [**ChuGL API Reference**](./api/)
• [**Examples**](./examples/)
• [**Cheatsheet**](./doc/cheatsheet.html)
• [**Walkthrough**](./doc/walkthru.html)
• [**Tutorial**](./doc/tutorial.html)
• [**Paper (NIME 2024)**](https://mcd.stanford.edu/publish/files/2024-nime-chugl.pdf)
<br>
**Videos** [SoundBulb Audiovisualizer](https://www.youtube.com/watch?v=wnSmS_y9-Cs) (code: 
[soundbulb.ck](examples/deep/soundbulb.ck) | [sndpeek.ck](examples/deep/sndpeek.ck))
| [Selected Student Projects](https://vimeo.com/909845445)
___

## Installation

### macOS and Windows

As of ChucK 1.5.2.1, ChuGL (alpha) is part of the [**standard ChucK 
distribution**](https://chuck.stanford.edu/release/) on macOS and Windows. ChucK 1.5.2.5 contains 
the latest and last OpenGL-based ChuGL v0.1.5 (alpha). ChucK 1.5.3.0 introduces ChuGL v0.2.0 
(alpha) featuring a significant re-write and transition from OpenGL to WebGPU as the underlying 
graphics library.


### Linux

Build ChuGL from source; see <a target="_blank" href="https://github.com/ccrma/chugl#building-chugl">instructions</a>.

## Running

**Note:** currently ChuGL only supports command-line chuck. MiniAudicle support to come soon. 
To run any ChuGL program (e.g., example.ck) on the terminal / command line prompt:
```
> chuck example.ck
```

### Minimal Example

If the chugin is properly loaded, running the following example via commandline chuck will 
open a blank window. Press `esc` to exit.

```cpp
while (true) { GG.nextFrame() => now; }
```

Congrats, you now have ChuGL properly installed!

## Learning Resouces

- [API Reference](./api/)
- [Examples](./examples/)
- [ChuGL Cheatsheet](./doc/cheatsheet.html)
- [ChuGL Tutorial](./doc/tutorial.html)
