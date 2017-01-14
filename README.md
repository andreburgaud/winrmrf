# README

## Description

**Windows rmrf** is a simple tool intended to delete directories that the default Windows tools (e.g. `DEL`) can't delete due to the **MAX_PATH** limitation (260 characters).

The target OS is Windows only.

![Winrmrf](https://www.burgaud.com/images/winrmrf.png)

## Motivation

I wrote this tool to overcome problems on Windows whith `too long path`, in particular when attempting to delete directories with path length exceeding the Windows `MAX_PATH`.

For example:

```
> del /q /s many_nested_directories
The directory name C:\test\many_nested_directories\many_nested_directories... is too long.
```

For further derails related to files and directories with paths exceeding 260 characters on Windows, see the following blog post: https://www.burgaud.com/path-too-long/.

## Installation

* Download the Windows 64-bit binary from the following URL:
 * https://s3.amazonaws.com/burgaud-download/winrmrf.exe
 * [SHA1 file](winrmrf.exe.sha1)
* Copy the executable in a directory included in the OS `PATH`.

**Note**: To build from the source code, see section **Build** below.

## Usage

```
> winrmrf --help
    windows rmrf (winrmrf) v0.2.0
  Copyright (c) 2017 - Andre Burgaud

Usage:
  winrmrf [-h|--help]
  winrmrf [-v|--version]
  winrmrf [-y|--yes] <directory_to_delete>
```

### Examples

```
C:\test> winrmrf many_nested_directories
    windows rmrf (winrmrf) v0.2.0
  Copyright (c) 2016-2017 - Andre Burgaud

Do you really want to delete the following directory:
C:\test\many_nested_directories? [y/n] y
Directory 'C:\test\many_nested_directories' was successfully deleted
```

The option `-y` allows to delete directories bypassing the confirmation step:

```
C:\test> winrmrf -y many_nested_directories
    windows rmrf (winrmrf) v0.2.0
  Copyright (c) 2016-2017 - Andre Burgaud

Directory 'C:\test\many_nested_directories' was successfully deleted
```

**Notes**:

1. Be careful when using this tool, especially with the `-y` option. As its
name indicates, `winrmrf` is similar to `rm -rf` on a UNIX system, therefore, it will delete the directory provided as parameter and all subdirectories and files under this directory.
2. It does not support wildcards such as `*` (star) to force entering the exact folder name and to prevent the typical error of deleting more than intended.

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
> nim release project
> cd dist
> winrmrf -f
```

Another option is to execute `nim build project` to generate a non compressed executable in directory `build`.

For other options available in the build file (`project.nims`), execute `nim help project`:

```
> nim help project
Hint: used config file 'C:\Users\andre\AB\Nim\config\nim.cfg' [Conf]
version              Show project version and Nim compiler version
test                 Runs the test suite
res                  Build resources
release              Compile winrmrf in release mode
upx                  Compile winrmrf in release mode and compress
build                Compile syscoretools in debug mode
clean                Delete generated binaries
hash                 Generate SHA1 sum to publish the executable
```

### Manual build

If the build script (`project.nims`) does not work for your environment (i.e. `windres`, `strip`, `upx` not available in the system PATH), you can simplify the process with the following steps:

1. Comment out the line with the following pragama `{.link: "resource.o".}` at the beginning of `winrmrf.nim`, to obtain:

```
#{.link: "resource.o".}
```

2. From the root directory of the project, execute the following commands:
```
> cd src
> c2nim resource.h
> nim c winrmrf
> winrmrf -h
```

## Release Notes

* Version 0.2.0 (1/14/2016):
  * Build converted from a batch file to a nimscript (project.nims)
  * Reorganized the tests
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
