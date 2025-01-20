<div align="center">
<!-- Add ChuGL logo -->
<!-- <img align="left" style="width:260px" src="https://github.com/raysan5/raylib/blob/master/logo/raylib_logo_animation.gif" width="288px"> -->

<img src="images/smuck-logo.svg" width="100%"></img>

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

**ChuGL v0.1.5** (alpha) — [**SMucK API Reference**](./api/)
• [**Examples**](./examples/)
• [**Cheatsheet (coming soon)**](./doc/cheatsheet.html)
• [**Walkthrough (coming soon)**](./doc/walkthru.html)
• [**Tutorial (coming soon)**](./doc/tutorial.html)
• [**Paper (coming soon)**](https://mcd.stanford.edu/publish/files/2024-nime-chugl.pdf)
___

## Installation

### macOS / Linux
1. Clone the SmucK repository
    ```
    git clone https://github.com/smuck/smuck.git
    ```
2. Copy the contents of `src` to `~/.chuck/lib` with the following command:
    ```
    cp -r smuck/src/* ~/.chuck/lib
    ```
    If you get the error `cp: ~/.chuck/lib is not a directory`, try the following command instead:
    ```
    sudo cp -r smuck/src/* /usr/local/lib/chuck
    ```

### Windows
1. Clone the SmucK repository
    ```
    git clone https://github.com/smuck/smuck.git
    ```
2. Copy the contents of `src` to `~/.chuck/lib` with the following command:
    ```
    cp -r smuck/src/* ~/.chuck/lib
    ```
    If you get the error `cp: ~/.chuck/lib is not a directory`, try the following command instead:
    ```
    sudo cp -r smuck/src/* /usr/local/lib/chuck
    ```

## Running

### Minimal Example

If the SMucK library is properly loaded, the following example will run without errors.

```cpp
// example.ck
@import "smuck"
```

Congrats, you now have SMucK properly installed!

## Learning Resouces

- [API Reference](./api/)
- [Examples](./examples/)
- [ChuGL Cheatsheet](./doc/cheatsheet.html)
- [ChuGL Tutorial](./doc/tutorial.html)
