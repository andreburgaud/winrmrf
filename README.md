# README

## Description

**Windows rmrf** is a simple tool intended to delete files and directories that the default Windows tools (e.g. `DEL`) can't delete due to the **MAX_PATH** limitation (260 characters).

The target operating system is Windows only. The other operating systems don't expose this particular behavior.

![Winrmrf Screenshot](https://cloud.githubusercontent.com/assets/6396088/21960346/7e692992-daad-11e6-8a9a-9ee903c16689.png)

## Motivation

I wrote this tool to overcome problems on Windows whith `too long path`, in particular when attempting to delete directories with path length exceeding the Windows `MAX_PATH`.

For example:

```
> del /q /s toolong
The directory name C:\test\toolong\toolong... is too long.
```

Or:

```
> rmdir /s toolong
toolong, Are you sure (Y/N)? Y
toolong\toolong\toolong\toolong\toolong\...\toolong - The directory is not empty.
```

For further details related to files and directories with paths exceeding 260 characters on Windows, see the following blog post: https://www.burgaud.com/path-too-long/.

## Installation

* Binary 64-bit versions of `winrmrf` are available in the releases section of this repo on GitHub: https://github.com/andreburgaud/winrmrf/releases.
* Download the latest version.
* If the package is a zip file, extract the executable from the zip file.
* Copy the executable, `winrmrf.exe`, into a directory included in your Windows `PATH`.

**Note**: If you prefer building the product yourself, see section **Build** below.

## Usage

```
> winrmrf --help
                   Windows rmrf v0.4.0
          Copyright (c) 2016-2017 - Andre Burgaud
Usage:
  winrmrf [-yhv] [directory... | file...]

Description:
  The winrmrf utility attempts to remove directories and/or files
  specified on the command line. By default the user is prompted for
  confirmation prior to deleting each file or directory.

Options:
  -y, --yes     Bypass prompt to confirm file(s) deletion
  -h, --help    Display this help and exit
  -v, --version Output version information and exit
```

### Examples

```
C:\test> winrmrf toolong
                   Windows rmrf v0.4.0
          Copyright (c) 2016-2017 - Andre Burgaud
remove C:\test\toolong? [y/N] y
winrmrf: C:\test\toolong: successfully deleted
```

The option `-y` (or `--yes`) allows to delete directories bypassing the confirmation step:

```
C:\test> winrmrf -y toolong
                   Windows rmrf v0.4.0
          Copyright (c) 2016-2017 - Andre Burgaud
winrmrf: C:\test\toolong: successfully deleted
```

**Notes**:

1. Be careful when using this tool, especially with the `-y` option. As its
name indicates, `winrmrf` is similar to `rm -rf` on a UNIX system, therefore, it will delete the files and/or directories provided as arguments and all subdirectories and files under any top directory.
2. Since version 0.3.0 `winrmrf` supports wildcards such as `*` (star) or `?` (question-mark) allowing removing multiple files and directory with similar name patterns.

## Build

### Requirements

This tool is coded in the **Nim** programing language and requires the MinGW GCC compiler.

* **Nim**: http://nim-lang.org/
* **MinGW**: http://www.mingw.org/
* **UPX**: https://upx.github.io/ (only needed if you want to obtain maximum compression with the resuling executable)

If you decide to build `winrmrf`, install Nim without MinGW, then fully install MinGW (the MinGW binaries will need to be available in the OS `PATH`). A full MinGW install includes tools like `windres` and `strip` that are used to respectively build the resources for `winrmrf` and strip the generated executable from its symbols and sections.

```
> git clone https://github.com/andreburgaud/winrmrf.git
> cd winrmrf
> make release
> cd dist
> winrmrf -f
```

Another option is to execute `make build` to generate a non compressed executable in directory `build`.

For other options available in the build file (`Makefile.nims`), in a windows terminal, execute `make help`, or simply `make`:

```
> make

Usage:
  make <task>

The tasks are:

help                 Display the list of available tasks
version              Show project version and Nim compiler version
test                 Runs the test suite
res                  Build resources
release              Compile winrmrf in release mode
upx                  Compile winrmrf in release mode and compress
build                Compile winrmrf in debug mode
clean                Delete generated binaries
```

### Manual build

If the build script (`Makefile.nims`) does not work for your environment (i.e. `windres`, `strip`, `upx` not available in the system `PATH`), you can shortcut the process with the following manual steps:

* At the beginning of `winrmrf.nim`, comment out the line starting with the following pragama `{.link: "resource.o".}`, to obtain:

```
#{.link: "resource.o".}
```

* From the root directory of the project, execute the following commands:
```
> cd src
> c2nim resource.h
> nim c winrmrf
> winrmrf -h
```

## Release Notes

* Version 0.4.0 (5/29/2017):
  * Simplified the build process (abstraction via `make.bat`)
  * Removed sha1sum from build process
  * Binary built with Nim 0.17.0
  * Binary compressed with UPX 3.94
* Version 0.3.0 (1/15/2017):
  * Uses parseopt to parse options and arguments
  * Support for multiple file or directory arguments
  * Support for wildcards in the file or directory name arguments
  * Added a CTRL+C hook
  * Improved error handling and messages
* Version 0.2.0 (1/14/2017):
  * Build converted from a batch file to a nimscript (project.nims)
  * Reorganized the tests
  * Built with Nim 0.16.0
* Version 0.1.2 (10/28/2016):
  * Externalized fileversion resources for easy reuse
  * Generate sha1sum during build
* Version 0.1.1 (10/26/2016):
  * Built with Nim 0.15.2
  * Replaced `windows` import with `winlean`
* Version 0.0.2 (10/25/2016):
  * First release
  * Built with Nim0.15.0

## License

MIT License: see included [License file](LICENSE.md).

## Resources

* https://www.burgaud.com/path-too-long/
* https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247(v=vs.85).aspx
* http://nim-lang.org/
* http://www.mingw.org/
* https://upx.github.io/
