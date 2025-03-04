<div align="center">

<img src="../images/logo.png" width="60%"></img>

<h2>Defining a New Package</h2>

</div> <!-- end center -->

<p align="justify">

Want to make your own ChuMP package? Here's how!

---

[**ChuMP v0.0.1**](./index.html) (alpha) — [**Browse Packages**](../release/chump/)
• [**Building for Linux**](./linux-build.html)
• [**Using ChuMP**](./usage.html)
• [**Defining a New Package**](./walkthru.html)

---

**What is a Package?**

A ChuMP package can be anything from a single `.ck` file to an effects
suite containing dozens of ChuGins and hundreds of audio files. Every
package has versions that are a specific release of your package. Your
package and version metadata is stored in a central ChuMP manifest
that is used by ChuMP to download, update, and install a compatible
version to the user's machine.

Your job as a package creator is to define your package and it's
versions, host the package's files online, and submit this information
to the [chump-packages](https://github.com/ccrma/chump-packages)
repository so that it can be added to the ChuMP package manifest.

---
**Your First Package**

You can define your packages in a ChucK script using the Chumpinate
ChuGin. Chumpinate provices two classes, `Package` and
`PackageVersion` that define and generate your package.

Start by installing Chumpinate:

```txt
chump install Chumpinate
```

Now, let's say our package consists of two files: `AwesomeEffect.ck`
and `AwesomeExample.ck`. We are going to define a `build-pkg.ck` that
generates all the files needed for our package.

First, we start by importing Chumpinate and defining our package metadata:

```txt
@import "Chumpinate"

// instantiate a Chumpinate package
Package pkg("AwesomeEffect");

// add our metadata here
"James P. Awesome" => pkg.author;

"https://awesome.com" => pkg.homepage;
"https://github.com/awe/some" => pkg.repository;

"A really sweet audio effect." => pkg.description;
"MIT" => pkg.license;

["effect", "UGen", "really cool"] => pkg.keywords;

```

Now that we've added all our metadata, we can generate the `package.json` file:

```txt
// generate a package-definition json file,
// this will be stored in (./AwesomeEffect/package.json)
"./" => pkg.generatePackageDefinition;
```

`Chumpinate` will take this metadata and convert it to a format that ChuMP understands.

Next, we define a specific version of this package. This includes the packages file,
ChucK language version bounds (i.e. what versions of ChucK will this code work on?), etc.:

```txt
// Now we need to define a specific PackageVersion and all the associated files and metadata
PackageVersion ver("AwesomeEffect", "1.0.0");

// what is the oldest version of ChucK this package will run on?
"1.5.4.1" => ver.languageVersionMin;
// optionally, we can also define a maximum compatible version of ChucK
// "1.5.5.0" => ver.languageVersionMin;

// Because this is a ChucK file (and not a ChuGin, which is a complied
// binary, this package is compatible with any operating systems and
// all CPU architectures.
"any" => ver.os;
"all" => ver.arch;

// add our package's files
ver.addFile("AwesomeEffect.ck");

// add our example, this will be stored in the package's `_examples` directory.
ver.addExampleFile("AwesomeExample.ck");
```

Now that we have defined AwesomeEffect v1.0.0, we need to generate two files: a `version.json` and a `.zip` file containing all of the version's files:

```txt
// zip up all our files into AwesomeEffect.zip, and tell Chumpinate what URL
// this zip file will be located at.
ver.generateVersion("./", "AwesomeEffect", "https://awesome.com/releases/1.0.0/AwesomeEffect.zip")

// pGenerate a version definition json file, stores this in "AwesomeEffect/<VerNo>/version.json"
ver.generateVersionDefinition("version", "./");
```

After this script has bene run, you will see the file
`./AwesomeEffect.zip`, as well as the two `json` files
`AwesomeEffect/package.json` and `AwesomeEffect/1.0.0/version.json`.

For `AwesomeEffect.zip`, it needs to be hosted at the URL `https://awesome.com/releases/1.0.0/AwesomeEffect.zip`.

For the `AwesomeEffects` directory with the `json` files, this folder
needs to be added to the
[`chump-packages`](https://github.com/ccrma/chump-packages)
repository. In order to do that, `git clone` the repo and submit a
pull request for the ChucK team to review.

Here is our full `build-pkg.ck`:

```txt
@import "Chumpinate"

// instantiate a Chumpinate package
Package pkg("AwesomeEffect");

// add our metadata here
"James P. Awesome" => pkg.author;

"https://awesome.com" => pkg.homepage;
"https://github.com/awe/some" => pkg.repository;

"A really sweet audio effect." => pkg.description;
"MIT" => pkg.license;

["effect", "UGen", "really cool"] => pkg.keywords;

// generate a package-definition json file,
// this will be stored in (./AwesomeEffect/package.json)
"./" => pkg.generatePackageDefinition;

// Now we need to define a specific PackageVersion and all the associated files and metadata
PackageVersion ver("AwesomeEffect", "1.0.0");

// what is the oldest version of ChucK this package will run on?
"1.5.4.1" => ver.languageVersionMin;
// optionally, we can also define a maximum compatible version of ChucK
// "1.5.5.0" => ver.languageVersionMin;

// Because this is a ChucK file (and not a ChuGin, which is a complied
// binary, this package is compatible with any operating systems and
// all CPU architectures.
"any" => ver.os;
"all" => ver.arch;

// add our package's files
ver.addFile("AwesomeEffect.ck");

// add our example, this will be stored in the package's `_examples` directory.
ver.addExampleFile("AwesomeExample.ck");

// zip up all our files into AwesomeEffect.zip, and tell Chumpinate what URL
// this zip file will be located at.
ver.generateVersion("./", "AwesomeEffect", "https://awesome.com/releases/1.0.0/AwesomeEffect.zip")

// pGenerate a version definition json file, stores this in "AwesomeEffect/<VerNo>/version.json"
ver.generateVersionDefinition("version", "./");

```
