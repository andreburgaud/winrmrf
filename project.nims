import strutils

binDir = "dist"
srcDir = "src"

let distDir = "dist"
let testDir = "test"
let buildDir = "build"

# App
let APP = "winrmrf"
let VERSION = "0.3.0"
let NAME = "Windows rmrf"

mode = ScriptMode.Verbose
#mode = ScriptMode.Silent


task version, "Show project version and Nim compiler version":
  echo "$# ($#) $#" % [NAME, APP, VERSION]
  exec "nim -v"


task test, "Runs the test suite":
  echo "Running test suite"
  exec "nim build project"
  exec "nim c -r tests/all_test"


task res, "Build resources":
  withDir "src":

    if not fileExists "resource.o":
      echo "Compiling resource definition script $#.rc" % APP
      exec "windres $#.rc resource.o" % APP

    if not fileExists "resource.nim":
      echo "Generating resource.nim file from resource.h"
      exec "c2nim -o:resource.nim resource.h"


# Requires: windres, strip, upx and sha1sum to be in the PATH
task release, "Compile winrmrf in release mode":
  rmDir distDir
  mkDir distDir

  exec "nim res project"

  exec "nim test project"

  withDir "src":
    echo "Building release $#" % APP
    exec "nim -d:release --opt:size c $#.nim" % APP
    echo "Moving executable '$#' to $# directory" % [APP.toExe, distDir]
    let distExe = "../$#/$#" % [distDir, APP.toExe]
    mvFile APP.toExe, distExe

  # Can be commented out if upx and/or strip are not in the PATH
  exec "nim upx project"

  # Can be commented out if sha1sum is not in the PATH
  exec "nim hash project"


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


task build, "Compile syscoretools in debug mode":
  if not existsDir buildDir:
    mkDir buildDir

  exec "nim res project"

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


task hash, "Generate SHA1 sum to publish the executable":
  let command = "sha1sum"

  echo "Generating SHA1 sum file for the release version of $#" % APP.toExe

  withDir distDir:
    if fileExists APP.toExe:
      try:
        exec """CMD /K $# $# > ..\$#.sha1 & exit""" % [command, APP.toExe, APP.toExe]
        if fileExists r"..\$#.sha1" % APP.toExe:
          echo "$#.sha1 generated successfully." % APP.toExe
      except:
        echo "WARNING: SHA1 file failed to be generated (most probably because sha1sum.exe is not in the PATH)."
        echo "         This has no impact on the generated binary and is intended only for distribution."
    else:
      echo "Executable file dist/$# does not exist. Execute 'nim release project' first." % APP.toExe
