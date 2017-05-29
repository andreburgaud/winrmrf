import strutils

binDir = "dist"
srcDir = "src"

let distDir = "dist"
let testDir = "test"
let buildDir = "build"

# App
let APP = "winrmrf"
let VERSION = "0.4.0"
let NAME = "Windows rmrf"

# Project
let PROJECT = "Makefile"

mode = ScriptMode.Verbose
#mode = ScriptMode.Silent


task version, "Show project version and Nim compiler version":
  echo "$# ($#) $#" % [NAME, APP, VERSION]
  exec "nim -v"


task test, "Runs the test suite":
  echo "Running test suite"
  exec "nim build $#" % PROJECT
  exec "nim c -r tests/all_test"


task res, "Build resources":
  withDir "src":

    if not fileExists "resource.o":
      echo "Compiling resource definition script $#.rc" % APP
      exec "windres $#.rc resource.o" % APP

    if not fileExists "resource.nim":
      echo "Generating resource.nim file from resource.h"
      exec "c2nim -o:resource.nim resource.h"


# Requires: windres, strip and upx to be in the PATH
task release, "Compile winrmrf in release mode":
  rmDir distDir
  mkDir distDir

  exec "nim res $#" % PROJECT

  exec "nim test $#" % PROJECT

  withDir "src":
    echo "Building release $#" % APP
    exec "nim -d:release --opt:size c $#.nim" % APP
    echo "Moving executable '$#' to $# directory" % [APP.toExe, distDir]
    let distExe = "../$#/$#" % [distDir, APP.toExe]
    mvFile APP.toExe, distExe

  # Can be commented out if upx and/or strip are not in the PATH
  exec "nim upx $#" % PROJECT


# Requires both strip and upx in the PATH
task upx, "Compile winrmrf in release mode and compress":

  let stripCmd = "strip"
  let upxCmd = "upx"

  withDir "dist":
    if fileExists APP.toExe:
      echo "Stripping release $#" % APP

      try:
        exec "$# $#" % [stripCmd, APP.toExe]
      except:
        echo "WARNING: Stripping the executable did not succeed."
        echo "         Was it already stripped or is strip in the PATH?"
        echo "         The binary will not have the smallest size, but functionality will not be impacted."

      echo "Compress $# with UPX" % APP.toExe
      try:
        exec "$# $#" % [upxCmd, APP.toExe]
      except:
        echo "WARNING: Compressing the executable did not succeed."
        echo "         Was it already compressed or is upx in the PATH?"
        echo "         The binary may not have the smallest size, but functionality will not be impacted."

    else:
      echo "Executable file dist/$# does not exist. Execute 'nim release project' first." % APP.toExe


task build, "Compile winrmrf in debug mode":
  if not existsDir buildDir:
    mkDir buildDir

  exec "nim res $#" % PROJECT

  withDir "src":
    echo "Building debug " & APP
    exec "nim c $#.nim" % APP
    echo "Moving executable '$#' to build directory" % APP.toExe
    let buildExe = "../$#/$#" % [buildDir, APP.toExe]
    if existsFile buildExe:
      rmFile buildExe
    mvFile APP.toExe, buildExe


task clean, "Delete generated binaries":
  echo "Deleting generated resource files"
  withDir srcDir:
    for res in @["resource.o", "resource.nim"]:
      if fileExists res:
        rmFile res

  echo "Deleting target directories (bin, build)"
  for dir in @[binDir, buildDir]:
    echo "Deleting $#" % dir
    rmDir dir

  echo "Deleting the test executables"
  let allTestExe = "tests/all_test".toExe
  echo "Deleting $#" % allTestExe
  rmFile allTestExe

  echo "Deleting the caches"
  for cache in @["src/nimcache", "tests/nimcache"]:
    echo "Deleting cache: $#" % cache
    rmDir cache
