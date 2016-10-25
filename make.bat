@echo off

set APP=winrmrf

if "%1" == "run"   goto run 
if "%1" == "dist"  goto dist 
if "%1" == "build" goto build
if "%1" == "clean" goto clean
if "%1" == "test"  goto test
if "%1" == "help"  goto usage
if "%1" == "lpath" goto lpath  
if "%1" == ""      goto build

REM ===========================================================================
REM USAGE/HELP
REM ===========================================================================
:usage
echo Usage: make [run^|build^|clean^|test^|dist^|lpath^|help]
echo   - run   : build and execute (nim c -run)
echo   - build : Build executable into 'bin' directory
echo   - clean : Remove all binary and temporary files
echo   - test  : Execute unit tests
echo   - dist  : Rebuild and compress final executable into 'dist' directory
echo   - lpath : Create nested 'toolong' directories for testing
echo   - help  : Show this message
goto :EOF

REM ===========================================================================
REM RUN
REM ===========================================================================
REM Build the release version of the executable.
REM ===========================================================================
:run
echo Build and run...
if not exist bin (
  mkdir bin
)
REM windres src\%APP%.rc src\resource.o
shift
nim c -o:bin\%APP%.exe -r src\%APP%.nim %1
goto :EOF

REM ===========================================================================
REM DIST
REM ===========================================================================
REM Clean, build, test, strip, then compress the executable with UPX.
REM The final executable is available in the 'dist' directory.
REM The tools 'strip' and 'upx' needs to be installed on the system and in 
REM the PATH.
REM ===========================================================================
:dist
call :clean
call :build
REM call :test
REM if not exist bin\%APP%.exe (
REM  echo Execute 'make build' first
REM  goto :EOF
REM )
if not exist dist (
  mkdir dist
)
strip -o bin\%APP%.exe bin\%APP%.exe
upx -odist\%APP%.exe bin\%APP%.exe
echo Executable availabe in directory 'dist'
goto :EOF

REM ===========================================================================
REM BUILD
REM ===========================================================================
REM Build the release version of the executable.
REM ===========================================================================
:build
echo Building...
if not exist bin (
  mkdir bin
)
windres src\%APP%.rc src\resource.o
nim c -o:bin\%APP%.exe -d:release src\%APP%.nim
goto :EOF

REM ===========================================================================
REM CLEAN
REM ===========================================================================
REM Clean all the temporary files (build, cache...)
REM ===========================================================================
:clean
echo Cleaning...
if exist bin (
  echo Removing bin directory...
  rmdir /s /q bin
)
if exist src\nimcache (
  echo Removing nimcache directory...
  rmdir /s /q src\nimcache
)
if exist dist (
  echo Removing dist directory...
  rmdir /s /q dist
)
if exist src\resource.o (
  echo Removing resource object file...
  del /q src\resource.o
)
goto :EOF

REM ===========================================================================
REM LPATH
REM ===========================================================================
REM Create nested 'toolong' directory for manual testing.
REM ===========================================================================
:lpath
nim c -r tests/helper
goto :EOF

REM ===========================================================================
REM TEST
REM ===========================================================================
REM Execute the tests.
REM ===========================================================================
:test
nim c -r tests/test
goto :EOF


