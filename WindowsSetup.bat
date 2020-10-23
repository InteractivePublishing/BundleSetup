@echo off
setlocal enableDelayedExpansion


set "SetupDir=%~dp0"
@REM 8.3 setup path
for %%A in ("%SetupDir%") do set "SetupDir=%%~sA"

REM for /f "tokens=2" %%a in ("%~df0") do (
    REM echo folder path contains space, setup cannot continue, quiting in a few seconds ...
    REM timeout /t 8
    REM exit /b
REM )

SET BaseInstallPath=%SetupDir%
IF %BaseInstallPath:~-1%==\ SET BaseInstallPath=%BaseInstallPath:~0,-1%

@REM Set logging path.
SET "LogPath=%BaseInstallPath%\install.log"
@REM TODO: Prompt user for path to slicer.exe
@REM set "SlicerPath=c:\Program Files\Slicer\Slicer.exe"
@REM set "SlicerPath=C:\Program Files\Mozilla Firefox\firefox.exe"
set "SlicerPath=D:\CIVM_Apps\Slicer\4.11.0-2020-09-25\Slicer.exe"
@REM 8.3 program path
for %%A in ("%SlicerPath%") do set "SlicerPath=%%~sA"

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

@REM   set newar=%Project_Name: =_%
@REM set "SetupDirArgReady=%SetupDir =\ %

for %%A in (%SetupDir%) do set "SetupDirArgReady=%%~sA"

@REM set PyStart=%DataVersionString%.py
set PyStart=ndLibrarySupport\Testing\DistStart.py


set "StartShortcut=%BaseInstallPath%\StartSlicer_with_%DataVersionString%"
echo %SetupDir%Components\utils\shortcut.bat "%SlicerPath%" "%BaseInstallPath%" "%DataVersionString%" "--python-script %SetupDirArgReady%%PyStart%" >>%LogPath%
if not exist "%StartShortcut%.lnk" (
  echo Making lib link to %DataVersionString%
  call %~dp0Components\utils\shortcut.bat "%SlicerPath%" "%BaseInstallPath%" "%DataVersionString%" "--python-script %SetupDirArgReady%%PyStart%"
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
echo To uninstall data, delete data folder. WARNING THIS ELIMINATES ALL LIBRARIES.
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
echo To uninstall data, delete data folder. WARNING THIS ELIMINATES ALL LIBRARIES.
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
