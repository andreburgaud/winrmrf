import os, winlean, strutils

const tooLongDir* = "toolong"

template wrapUnary(varname, winApiProc, arg: untyped) =
  var varname = winApiProc(newWideCString(arg))

# Call native windows function to create directories
proc createDirW(path: string) =
  wrapUnary(res, createDirectoryW, path)
  if res == 0'i32 and getLastError() != 183'i32:
    echo "Error: " & $osLastError()

# Create a "too long path", by recursively creating 100 nested subdirectories
# Create a test file at the first level of the newly created tree
proc createlongDirPath* =
  var path = r"\\?\$1" % expandFileName(".")
  for _ in 0..100:
    path &= r"\" & tooLongDir
    createDirW(path)
  writeFile(joinPath(tooLongDir, "test_file.txt"), "This is a test file for test 'delete file'")

when isMainModule:
  ## Progam entry point
  createlongDirPath()