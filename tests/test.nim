import unittest, winrmrf, os, helper

suite "winrmrf":
  
  test "delete dir":
    let testDir = "test_dir"
    check(not existsDir(testDir))
    createDir(testDir)
    check(existsDir(testDir))
    let absPath = expandFileName(testDir)
    check(delDir(absPath))
    check(not existsDir(testDir))

  test "create long path directory":
    createlongDirPath()
    
    # Calling the default removeDir causes an OSError
    expect OSError:
      removeDir(tooLongDir)

    # Calling the winrmrf function is successful
    check(delDir(expandFileName(tooLongDir)))

