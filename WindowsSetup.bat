@echo off
setlocal enableDelayedExpansion

for /f "tokens=2" %%a in ("%~df0") do (
    echo folder path contains space, setup cannot continue,
    echo setups only job is to create a shortcut to start slicer with the proper command line args
    echo you can do that manually
    echo the proper arg is --python-script "
    echo quiting in a few seconds ...
    timeout /t 8
    exit /b
)

set "SetupDir=%~dp0"
@REM 8.3 setup path EXCEPT MICROSOFT DISABLED THIS
@REM MEANING THERE ARE NO SHORT NAMES, and NO method to use them.
@REM for %%A in ("%SetupDir%") do set "SetupDir=%%~sA" & echo %%~sA
for %%A in ("%SetupDir%") do set "SetupDir=%%~sA"
@REM bat -> vbs version of shortname, shouldn't be necessary.
@REM call "%~dp0\Components\utils\shortname.bat" "%SetupDir%"
@REM set SetupDir=%SHORTNAME%


SET BaseInstallPath=%SetupDir%
IF %BaseInstallPath:~-1%==\ SET BaseInstallPath=%BaseInstallPath:~0,-1%

@REM Set logging path.
SET "LogPath=%BaseInstallPath%\install.log"

echo "Select Slicer.exe in pop up window"
@REM TODO: Prompt user for path to slicer.exe
call %~dp0\Components\utils\file_select.bat
set "SlicerPath=%FILEPATH%"
@REM set "SlicerPath=c:\Program Files\Slicer\Slicer.exe"
@REM set "SlicerPath=D:\CIVM_Apps\Slicer\4.11.0-2020-09-25\Slicer.exe"

@REM 8.3 program path EXCEPT MICROSOFT DISABLED THIS
@REM MEANING THERE ARE NO SHORT NAMES, and NO method to use them.
@REM Still gonna try to get them, because they'll be more resilient to stuff.
for %%A in ("%SlicerPath%") do set "SlicerPath=%%~sA"
@REM bat -> vbs version of shortname, shouldn't be necessary.
@REM call %~dp0\Components\utils\shortname.bat "%SlicerPath%"
@REM set SlicerPath=%SHORTNAME%

set "DataPath=%BaseInstallPath%"
set "DataUninst=%DataPath%\%LibItemNumber%_tempuninst.list"

for /D %%i in (%DataPath%) do SET "DataVersionString=%%~ni"

echo Open Install log  >> "%LogPath%"
date /T  >> "%LogPath%"
time /T  >> "%LogPath%"

set "idx_LibConf=%BaseInstallPath%\lib.conf"

if not exist %idx_LibConf% (
  echo ERROR setting up lib! missing "%idx_LibConf%"!
  echo ERROR setting up lib! missing "%idx_LibConf%"!>> "%LogPath%"
  timeout 6
  exit /b
)
@REM string replace example
@REM   set newar=%Project_Name: =_%
@REM thought I could use this to allow spaces in setupdir, but it didnt work.
@REM So, spaces are disabled at the top.
@REM set "SetupDirArgReady=%SetupDir =\ %

@REM 8.3 program path EXCEPT MICROSOFT DISABLED THIS
@REM MEANING THERE ARE NO SHORT NAMES, and NO method to use them.
@REM Still gonna try to get them, because they'll be more resilient to stuff.
for %%A in (%SetupDir%) do set "SetupDirArgReady=%%~sA"

@REM set PyStart=%DataVersionString%.py
set PyStart=ndLibrarySupport\Testing\DistStart.py

set "StartShortcut=%BaseInstallPath%\StartSlicer_with_%DataVersionString%"
echo "%SetupDir%Components\utils\shortcut.bat" "%SlicerPath%" "%BaseInstallPath%" "%DataVersionString%" "--python-script %SetupDirArgReady%%PyStart%" >>%LogPath%
if not exist "%StartShortcut%.lnk" (
  echo Making lib link to %DataVersionString%
  call "%~dp0Components\utils\shortcut.bat" "%SlicerPath%" "%BaseInstallPath%" "%DataVersionString%" "--python-script %SetupDirArgReady%%PyStart%"
  echo move "%BaseInstallPath%\Slicer.lnk" "%StartShortcut%.lnk" >> %LogPath%
  move "%BaseInstallPath%\Slicer.lnk" "%StartShortcut%.lnk"
)
echo Continuing in ...
timeout 6


goto Flasher
@REM Give user a summary.
:CompleteShow
cls
echo It is now safe to close this window
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo Setup complete.
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo Log file saved to %LogPath%.
echo To start program use shortcut
echo %StartShortcut%
echo.
echo To uninstall this package, simply delete folder.
echo   %DataPath%
echo.
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
EXIT /B 0

goto Flasher

:CompleteHide
cls
echo It is now safe to close this window
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo Setup complete.
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo Log file saved to %LogPath%.
echo To start program use shortcut
echo.
echo.
echo To uninstall this package, simply delete folder.
echo   %DataPath%
echo.
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
EXIT /B 0

goto Flasher

:Flasher
@REM FOR /L %variable IN (start,step,end) DO command [command-parameters]

FOR /L %%v IN (1,1,3600) DO (
  call :CompleteShow
  ping localhost -n 3 >nul
  call :CompleteHide
  ping localhost -n 1 >nul
)
call :CompleteShow

exit /b
