import os, system, unittest
import winrmrf
import mklgdir

suite "winrmrf":

  test "delete dir":
    let testDir = "test_dir"
    check(not existsDir(testDir))
    createDir(testDir)
    check existsDir(testDir)
    let absPath = expandFileName(testDir)
    check remove(absPath)
    check(not existsDir(testDir))

  test "delete file":
    let testFile = "test_file.txt"
    check(not existsFile(testFile))
    writeFile(testFile, "This is a test file for test 'delete file'")
    check existsFile(testFile)
    let absPath = expandFileName(testFile)
    check(remove(absPath))
    check(not existsFile(testFile))

  test "create long path directory":
    createlongDirPath()

    # Calling the default removeDir causes an OSError
    expect OSError:
      removeDir(tooLongDir)

    # Calling the winrmrf function is successful
    check(remove(expandFileName(tooLongDir)))
