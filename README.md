# README

## Description

**Windows rmrf** is a simple tool intended to delete directories that the default Windows tools (e.g. `DEL`) can't delete due to the **MAX_PATH** limitation (260 characters).

The target OS is Windows only.

## Motivation

I wrote this tool to overcome problems on Windows whith `too long path`, in particular when attempting to delete directories with a too long path.

For example:

```
> del /q /s many_nested_directories
The directory name C:\test\many_nested_directories\many_nested_directories... is too long.
```

## Installation

* Download the Windows 64-bit binary from the following URL:
 * https://s3.amazonaws.com/burgaud-download/winrmrf.exe
 * [SHA1 file](winrmrf.exe.sha1)
* Copy the executable in a directory included in the OS `PATH`.

**Note**: To build from the source code, see section **Build** below.

## Usage

```
> winrmrf --help
    windows rmrf (winrmrf) v0.1.2
  Copyright (c) 2016 - Andre Burgaud

Usage:
  winrmrf [-h|--help]
  winrmrf [-v|--version]
  winrmrf [-y|--yes] <directory_to_delete>
```

### Examples

```
C:\test> winrmrf many_nested_directories
    windows rmrf (winrmrf) v0.1.2
  Copyright (c) 2016 - Andre Burgaud

Do you really want to delete the following directory:
C:\test\many_nested_directories? [y/n] y
Directory 'C:\test\many_nested_directories' was successfully deleted
```

The option `-y` allows to delete directories bypassing the confirmation step:

```
C:\test> winrmrf -y many_nested_directories
    windows rmrf (winrmrf) v0.1.2
  Copyright (c) 2016 - Andre Burgaud

Directory 'C:\test\many_nested_directories' was successfully deleted
```

**Notes**:

1. Be careful when using this tool, especially with the `-y` option. As its
name indicates, `winrmrf` is similar to `rm -rf` on a UNIX system, therefore, it will delete the directory provided as parameter and all directories, subdirectories and files under this directory.
2. It does not support wildcards such as `*` (star) to force entering the exact folder name and to prevent the typical error of deleting more than intended.

## Build

### Requirements

This tool is coded in the **Nim** programing language and requires the MinGW GCC compiler.

* **Nim**: http://nim-lang.org/
* **MinGW**: http://www.mingw.org/
* **UPX**: https://upx.github.io/ (only needed if you want to obtain maximum compression with the resuling executable)

If you decide to build `winrmrf`, install Nim without MinGW, then fully install MinGW (the MinGW binaries will need to be available in the OS `PATH`). A full MinGW install includes tools like `windres` and `strip` that are used to respectively build the resources for `winrmrf` and strip the generated executable from its symbols and sections.

```
C:\> git clone https://github.com/andreburgaud/winrmrf.git
C:\> cd winrmrf
C:\> make dist
```

* The final executable will be in the `dist` directory.
* Another option is to execute `make build` to generate a non compressed executable in directory `bin`.

For other options available in the build file (`make.bat`), execute `make help`:

```
> make help
Usage: make [run|build|clean|test|dist|lpath|help]
  - run   : build and execute (nim c -run)
  - build : Build executable into 'bin' directory
  - clean : Remove all binary and temporary files
  - test  : Execute unit tests
  - dist  : Rebuild and compress final executable into 'dist' directory
  - lpath : Create nested 'toolong' directories for testing
  - help  : Show this message
```

### Notes about the build

1. If you want to avoid the burden of building the resources and compression steps, remove the *link* pragma from the top of `winrmrf.nim`, line `{.link: "resource.o".}`, and simply execute `make build`. The resulting executable will be in directory `bin`.
2. You want to use a regular Windows terminal and not an Msys terminal to avoid the `make.bat` file to conflict with the regular `make` expecting a `Makefile`.

## Release Notes

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

* https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247(v=vs.85).aspx
* http://nim-lang.org/
* http://www.mingw.org/
* https://upx.github.io/
