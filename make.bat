@echo off

if {%1} == {} (
    goto USAGE
)

if {%1} == {help} (
    goto USAGE
)

:MAIN
nim --hints:off %1 Makefile

if errorlevel 0 (
    goto :EOF
)

:USAGE
echo.
echo Usage:
echo.  make ^<task^>
echo.
echo The tasks are:
echo.
echo help                 Display the list of available tasks
nim --hints:off help Makefile
