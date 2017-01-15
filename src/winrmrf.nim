## winrmrf is a tool to delete folders or directories that the
## regular Windows tools like 'DEL' can't delete due to 'too long path'

{.link: "resource.o".}

import os, parseopt, rdstdin, strutils, system, terminal
import resource # generated from resource.h with c2nim

const
  SPACES = 10
  PREFIX = r"\\?\"
  DATE = "01/15/2017"
  MISSING_ARGUMENTS = "missing file or directory arguments"

proc appName: string =
  ## Extract the program name from the command line
  splitFile(getAppFilename())[1]

proc ctrlC*() {.noconv.} =
  ## Handler invoked by setControlCHook when a Control C is captured.
  echo("$#: manually interruped." % appName())
  quit QuitSuccess

proc printInfo =
  ## Display centered information each time the program is executed
  let width = terminalWidth()
  styledEcho fgGreen, center("$1 v$2" % [VER_PRODUCTNAME_STR, VER_PRODUCTVERSION_STR],
                                         width - 10)
  styledEcho fgGreen, center(VER_LEGALCOPYRIGHT_STR, width - 10)

proc printVersion =
  ## Display version when program invoked with -h or --help
  # Remove the trailing nul resulting from c2nim conversion from resource.h
  let ver = VER_FILEVERSION_STR.strip(leading=false, trailing=true, {'\0'})
  writeStyled appName()
  echo " version $1 ($2)" % [ver, DATE]

proc printUsageOption(shortOpt: string, longOpt: string, description: string) =
  ## For the usage, print a line for a given option
  let displayLongOpt = longOpt & spaces(max(0, SPACES - longOpt.len))
  writeStyled "  $1, $2" % [shortOpt, displayLongOpt]
  echo description

proc printDescription =
  ## Display the description for this utility
  styledEcho fgYellow, styleBright, "Description:"
  echo """  The $1 utility attempts to remove directories and/or files
  specified on the command line. By default the user is prompted for
  confirmation prior to deleting each file or directory.""" % appName()
  echo()

proc printOptions =
  ## Print all the options descriptions for the usage
  styledEcho fgYellow, styleBright, "Options:"
  printUsageOption("-y", "--yes", "Bypass prompt to confirm file(s) deletion")
  printUsageOption("-h", "--help", "Display this help and exit")
  printUsageOption("-v", "--version", "Output version information and exit")

proc printUsage =
  ## Display usage for this application
  styledEcho fgYellow, styleBright, "Usage:"
  echo "  $1 [-yhv] [directory... | file...]" % appName()
  echo()
  printDescription()
  printOptions()

proc printError*(msg: string) =
  ## Display an error message
  styledWriteLine stdout, fgRed, styleBright, "$#: $#" % [appName(), strip(msg)]

proc printWarning*(msg: string) =
  ## Display a warning message
  styledWriteLine stdout, fgYellow, "$#: $#" % [appName(), strip(msg)]

proc printSuccess*(path: string, successMsg: string) =
  ## Print a success message upon deletion of a file or directory
  stdout.write "$1: " % appName()
  writeStyled path
  stdout.write ": "
  styledWriteLine stdout, fgGreen, successMsg

proc expandOption*(key: string, isLong: bool=false): string =
  ## Expand the option with a single dash '-' for short option and double dash
  ## for a long option to be displayed to the user
  if isLong: "--$#" % key else: "-$#" % key

proc printUnexpectedOption*(key: string, isLong: bool=false) =
  ## Display an error when an unexpected option was passed on the command line
  printError("$#: unexpected option" % expandOption(key, isLong))

proc getAbsPath(filename: string): string =
  ## Return absolute path for a given directory
  if existsDir(filename) or existsFile(filename):
    result = expandFileName filename
  else:
    raise newException(OSError, "'$1' is not a valid file or directory" % filename)

proc confirm(msg: string): bool =
  ## Request a confirmation. Return true if response is 'y' or 'yes'
  var resp = readLineFromStdin("$1 [y/N] " % msg)
  resp = resp.toLowerAscii()
  resp == "y" or resp == "yes"

proc remove*(absPath: string): bool =
  ## Delete file or directory given an absolute directory or file path
  let extPath = PREFIX & absPath
  try:
    if existsDir(extPath):
      removeDir extPath
    else:
      removeFile(extPath)
    return true
  except OSError:
    printWarning "Is the directory currently locked by another program (i.e. Windows explorer)?"
    raise

proc processFile(filename: string, optYes: bool) =
  ## Process each file and trigger the delete for a file or directory
  ## Present a confirmation dialog if the -y | --yes option was not passed
  ## on the command line
  try:
    var canDelete = optYes
    let absPath = getAbsPath filename
    if not canDelete:
      canDelete = confirm "remove $1?" % absPath
    if canDelete:
      if remove(absPath):
        printSuccess absPath, "successfully deleted"
      else:
        printWarning "$1: a problem occurred during the delete" % absPath
    else:
      printWarning "$1: skipping" % absPath
  except:
    let msg = getCurrentExceptionMsg()
    printWarning("$1: $2" % [filename, strip(msg)])

proc doCommand(filenames: seq[string], optYes: bool) =
  ## Entry point for the command, after parsing of the options and arguments
  var files: seq[string] = @[]

  if filenames == nil or filenames.len == 0:
    printError MISSING_ARGUMENTS
    printUsage()
    quit QuitFailure

  for pattern in filenames: # some arguments may include wildcards
    var foundFile = false
    for filename in walkPattern(pattern):
      foundFile = true
      files.add filename
    if not foundFile:
      files.add pattern

  for f in files:
    processFile(f, optYes)

proc main() =
  ## Main procedure. Analyze options and arguments, prior to trigger
  ## the processing of the command via `doCommand`
  printInfo()

  # Options
  var optYes = false # -y | --yes

  # Arguments
  var filenames: seq[string] = @[]

  var errorOption = false
  for kind, key, val in getopt():
    case kind
    of cmdArgument:
      filenames.add(key)
    of cmdLongOption:
      case key
      of "help": printUsage(); return
      of "version": printVersion(); return
      of "yes": optYes = true
      else: printUnexpectedOption(key, true); errorOption = true
    of cmdShortOption:
      case key
      of "h": printUsage(); return
      of "v": printVersion(); return
      of "y": optYes = true
      else: printUnexpectedOption key; errorOption = true
    of cmdEnd: assert(false)

  if errorOption:
    quit QuitFailure

  if filenames.len > 0:
    setControlCHook(ctrlC) # Trap CTRL+C
    doCommand(filenames, optYes)
  else:
    printError MISSING_ARGUMENTS
    printUsage()

when isMainModule:
  main()
