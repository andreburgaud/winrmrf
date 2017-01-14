## winrmrf is a tool to delete folders or directories that the
## regular Windows tools like 'DEL' can't delete due to 'too long path'

{.link: "resource.o".}

import os, terminal, winlean, rdstdin, strutils, system, resource

const prefix = r"\\?\"
const date = "01/14/2017"
const confirmTmpl = """Do you really want to delete the following directory:
$1?"""

proc info =
  ## Display centered information each time the program is executed
  let width = terminalWidth()
  setForegroundColor fgGreen, false
  echo center("$1 v$2" % [VER_PRODUCTNAME_STR, VER_PRODUCTVERSION_STR], width - 10)
  echo center(VER_LEGALCOPYRIGHT_STR, width - 10)
  echo()
  resetAttributes()

proc getProgramName: string =
  ## Extract the program name from the command line
  splitFile(paramStr(0))[1]

proc version =
  ## Display version when program invoked with -h or --help
  echo "$1 $2 ($3)" % [getProgramName(), VER_PRODUCTVERSION_STR, date]

proc usage =
  ## Display usage for this application
  setForegroundColor fgYellow, true
  echo "Usage:"
  resetAttributes()
  echo """  $1 [-h|--help]
  $1 [-v|--version]
  $1 [-y|--yes] <directory_to_delete>""" % getProgramName()

proc error(msg: string) =
  ## Display error
  setForegroundColor fgRed, true
  echo "Error: $1\n" % msg
  resetAttributes()

proc getAbsPath(dir: string): string =
  ## Return absolute path for a given directory
  if not existsDir(dir):
    error "'$1' is not a valid directory" % dir
    usage()
    quit(1)

  expandFileName(dir)

proc confirm(msg: string): bool =
  ## Request a confirmation. Return true if response is 'y' or 'yes'
  var resp = readLineFromStdin("$1 [y/n] " % msg)
  resp = resp.toLowerAscii()
  resp == "y" or resp == "yes"

proc delDir*(absPath: string): bool =
  ## Delete directory given an absolute directory name
  let extPath = prefix & absPath
  try:
    removeDir(extPath)
    return true
  except OSError:
    let msg = getCurrentExceptionMsg()
    error(strip(msg))
    echo "Ensure that the directory is not currently locked by another program (i.e. Windows explorer)."
    quit(2)

proc main() =
  ## Main procedure. Analyze parameters and invoke appropriate actions.
  info()

  let arguments = commandLineParams()
  if (len(arguments) == 0 or paramStr(1) == "-h" or paramStr(1) == "--help"):
    usage()
    quit(0)

  if (paramStr(1) == "-v" or paramStr(1) == "--version"):
    version()
    quit(0)

  var dir = ""
  var conf = true
  if len(arguments) > 1:
    if (paramStr(1) == "-y" or paramStr(1) == "--yes"):
      dir = paramStr(2)
      conf = false
  else:
      dir = paramStr(1)

  let absPath = getAbsPath(dir)

  var success = false

  if conf:
    let msg = confirmTmpl % absPath
    if confirm(msg):
      success = delDir(absPath)
    else:
      echo "Bye!"
  else:
    success = delDir(absPath)

  if success:
    echo "Directory '$1' was successfully deleted" % absPath

when isMainModule:
  ## Progam entry point
  main()
