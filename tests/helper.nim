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
proc createlongDirPath* =
  var path = r"\\?\$1" % expandFileName(".")
  for _ in 0..100:
    path &= r"\" & tooLongDir
    createDirW(path)
    
when isMainModule:
  ## Progam entry point
  createlongDirPath()