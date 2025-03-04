<div align="center">

<img src="images/chump-logo.png" width="35%"></img>

<h2>How to Use ChuMP</h2>

</div> <!-- end center -->

<p align="justify">

**ChuMP** is bundled with the ChucK installer since `1.5.5.0` and is available as the command `chump` in your terminal. If you are on Linux, see [**Building for Linux**](../building_for_linux).

---


[**ChuMP v0.0.1**](./index.html) (alpha) — [**Browse Packages**](../release/chump/)
• [**Building for Linux**](./linux-build.html)
• [**Using ChuMP**](./usage.html)
• [**Defining a New Package**](./walkthru.html)

---


To install a package:

```txt
chump install WarpBuf
```

The `chump install` command downloads a package and stores it in a special `packages` directory. If you are on MacOS or Linux, this will be in `~/.chuck/packages` and if you are on Windows it's located at `C:\Users\<UserName>\Documents\chuck\packages`. Each package is a folder inside `packages` that contains all of the package's files.

If you want to download a specific version of a package, you can specificy which verison number to use:

```txt
chump install WarpBuf=0.0.1
```

---

To update a package:

```txt
chump update WarpBuf
```

If there is a newer version of a package, then ChuMP will uninstall the local version and install the most up to date version. If the currently installed version is up-to-date, or if the package is not installed, ChuMP will do nothing.

---

To uninstall a package:

```txt
chump uninstall WarpBuf
```

This will remove all package files installed on your computer. It will also remove the `PackageName` directory from the `packages` directory, unless there are files not associated with the package inside that directory. In that case, the directory, and the unassociated files, will remain.

In the case that the installation is broken, it might be necessary to delete the entire directory instead of having ChuMP delete the individaul files one at a time. If this happens you can perform a force-uninstall with the `-f/--force` flag:

```txt
chump uninstall -f WarpBuf
```

---

To list available packages:
```txt
chump list
```

This will provide a list of available packages, descriptions and other metadata, and information about what is the latest package version compatible with your computer. If the package is currently installed, the package's installation directory will be shown.

To only list packages that are currently installed:

```txt
chump list -u
```

---

To get detailed information about a package:

```txt
chump info WarpBuf
```

This will include all metadata, installed files (if the package is installed), and a list of all versions of package

---

To get to the help page:

```txt
chump help
```
