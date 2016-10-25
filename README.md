# README

## Description

**Windows rmrf** is a simple tool intended to delete directories that the default 
Windows tools (e.g. `DEL`) can't delete due to the **MAX_PATH** limitations 
(260 characters).

The target OS is Windows only.

## Motivation

I wrote this tool to overcome problems on windows whith `too long path`, in 
particular when attempting to delete directories.

For example:

```
> del /q /s many_nested_directories
The directory name C:\test\many_nested_directories\many_nested_directories... is too long.
```

## Download Binary

* https://s3.amazonaws.com/burgaud-download/winrmrf.exe
* SHA-1 digest: `bedd20c91cb939d8a356bbc2904fbcfc3c7689e7`

## Usage

```
> winrmrf --help
    windows rmrf (winrmrf) v0.0.2
  Copyright (c) 2016 - Andre Burgaud

Usage:
  winrmrf [-h|--help]
  winrmrf [-v|--version]
  winrmrf [-y|--yes] <directory_to_delete>
```

## Examples

```
C:\test> winrmrf toolong
    windows rmrf (winrmrf) v0.0.2
  Copyright (c) 2016 - Andre Burgaud

Do you really want to delete the following directory:
C:\test\many_nested_directories? [y/n] y
Directory 'C:\test\many_nested_directories' was successfully deleted
```

The option `-y` allows to delete directories bypassing the confirmation step:

```
C:\test> winrmrf -y toolong
    windows rmrf (winrmrf) v0.0.2
  Copyright (c) 2016 - Andre Burgaud

Directory 'C:\test\toolong' was successfully deleted
```

**Note**: be careful when using this tool, especially with the '-y' option. As its
name indicates, this is similar to run `rm -rf` on a UNIX system.

## Build

### Requirements

This tool is coded in Nim and requires the MinGW GCC compiler.

* Nim: http://nim-lang.org/
* MinGW: http://www.mingw.org/
* UPX: https://upx.github.io/ (only needed if you want to obtain maximum compression with the resuling executable)

```
C:\> git clone https://github.com/andreburgaud/winrmrf.git
C:\> cd winrmrf
C:\> make dist
```

## Resources

* https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247(v=vs.85).aspx
* http://nim-lang.org/
* http://www.mingw.org/
* https://upx.github.io/
