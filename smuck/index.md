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
• [**Examples**](./examples/)
• [**Walkthrough**](./doc/walkthru.html)
• [**SMucKish Rosetta Stone**](./doc/smuckish.html)
• **Cheatsheet (coming soon)**
• **Tutorial (coming soon)**
• **Paper (coming soon)**
___

## Installation

### macOS / Linux
1. Clone the SmucK repository
    ```txt
    git clone https://github.com/ccrma/smuck.git
    ```
2. Copy the contents of `src` to `~/.chuck/lib` with the following command:
    ```txt
    cp -r smuck/src/* ~/.chuck/lib
    ```
    If you get the error `cp: ~/.chuck/lib is not a directory`, try the following command instead:
    ```txt
    sudo cp -r smuck/src/* /usr/local/lib/chuck
    ```

### Windows
1. Clone the SmucK repository
    ```txt
    git clone https://github.com/ccrma/smuck.git
    ```
2. Copy the contents of `src` to one of the following directories:
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
@import "smuck"
```

Congrats, you now have SMucK properly installed!

## Learning Resouces

- [API Reference](./api/)
- [Examples](./examples/)
- [Walkthrough](./doc/walkthru.html)
- [SMucKish Rosetta Stone](./doc/smuckish.html)
- SMucK Tutorial (coming soon)

