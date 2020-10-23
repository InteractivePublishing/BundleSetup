@echo off
setlocal enableDelayedExpansion

for /f "tokens=2" %%a in ("%~df0") do (
    echo folder path contains space, setup cannot continue, quiting in a few seconds ...
    timeout /t 8
    exit /b
)
set SetupDir=%~dp0

SET BaseInstallPath=%~dp0
IF %BaseInstallPath:~-1%==\ SET BaseInstallPath=%BaseInstallPath:~0,-1%

@REM Set logging path.
SET "LogPath=%BaseInstallPath%\install.log"
@REM TODO: Prompt user for path to slicer.exe
@REM set "SlicerPath=c:\Program Files\Slicer\Slicer.exe"
set "SlicerPath=C:\Program Files\Mozilla Firefox\firefox.exe"

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
  exit /b
)


set "StartShortcut=%BaseInstallPath%\StartSlicer_with_%DataVersionString%"
echo %SetupDir%Components\utils\shortcut.bat "%SlicerPath%" "%BaseInstallPath%" %DataVersionString% "--python-script ^"%SetupDir%%DataVersionString%.py^"" >>%LogPath%
if not exist "%StartShortcut%.lnk" (
  echo Making lib link to %DataVersionString%
  call %~dp0Components\utils\shortcut.bat "%SlicerPath%" "%BaseInstallPath%" %DataVersionString% "--python-script ^"%SetupDir%%DataVersionString%.py^""
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
