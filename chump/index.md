<div align="center">

<img src="img/chump-logo.png" width="60%"></img>

<h2>ChuMP: The ChucK Manager of Packages</h2>

</div> <!-- end center -->

<p align="justify">

<b>ChuMP</b> is ChucK's official package manager on macOS, Linux, and 
Windows. It downloads, installs, and all-around manages libraries, chugins 
(ChucK plugins), tools, datasets, etc. so that you don't have to ([browse 
all available packages](../release/chump/)). There is a growing list of 
installable packages from both the ChucK community and ChucK Team. On 
macOS and Windows, ChuMP is bundled with the [**ChucK 
distribution**](../release/) since `1.5.5.0`, and is available as the 
command `chump` in your terminal. If you are on Linux, see [**Building for 
Linux**](./linux-build.html).

ChuMP was created by <a href="https://nicholasshaheed.com/">Nick 
Shaheed</a> with support from the <a href="../doc/authors.html">ChucK 
Team</a>.

---


[**ChuMP v0.0.2**](./index.html) (alpha) — [**Browse All Packages**](../release/chump/)
• [**Building for Linux**](./linux-build.html)
• [**Using ChuMP**](./usage.html)
• [**Defining a New Package**](./walkthru.html)

---


To install a package:

```txt
chump install [package name]
```

To update a package:

```txt
chump update [package name]
```

To uninstall a package:

```txt
chump uninstall [package name]
```

To list available packages:
```txt
chump list
```

To list all installed packages:
```txt
chump list -i
```

To get detailed information about a package:

```txt
chump info WarpBuf
```


To display ChuMP's help page:
```txt
chump help
```

For a more in-depth explanation, see [**How to use ChuMP**](./usage.html).
