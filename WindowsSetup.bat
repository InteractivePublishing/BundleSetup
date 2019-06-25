@echo off
if %PROCESSOR_ARCHITECTURE% EQU AMD64 (
  @REM echo AMD64%PROCESSOR_ARCHITECTURE%
  set "sevenZ=%~dp0Setup\7z1805-extra\x64\7za.exe"
) else (
  @REM echo is32%PROCESSOR_ARCHITECTURE%
  echo Warning AtlasViewer only compiled for 64-bit architecture.
  set "sevenZ=%~dp0Setup\7z1805-extra\7za.exe"
  timeout 30;
  exit /b
)

@REM Get version from index later...
@REM AppInstaller, LibItemNumber, and LibIndex will probably need to be specified.
@REM a var_line txt file will probably be best, and this script will look for that.
call %~dp0\Setup\utils\var_line_parser %~dp0\setup_vars.txt

@REM set "LibItemNumber=CIVM-17001"
@REM set "LibIndex=000Mouse_Brain"
set "AppBundleName=%WinAppBundleName%"
set "PROGRAMVERSION=%WinProgramVersion%"

set "astr=-win-amd64_"

set "AppInstaller=%AppBundleName%%astr%%PROGRAMVERSION%.exe"

for /f "delims=" %%F in ('dir /b /s "%~dp0Setup\%AppInstaller%" 2^>nul') do set p=%%F

if not exist %~dp0Setup\%AppInstaller% (
  echo Setup application not found, quiting.
  echo Missing %~dp0Setup\%AppInstaller%
  exit /b
) else (
  echo Proceeding with installer %AppInstaller%
)

@REM #    astr"-macosx-amd64";


@REM


@REM set "BaseInstallPath=C:\InteractivePublishing"
@REM pushed BaseInstallPath to setup vars.
@REM currently includes C:\ , maybe we should use %HOMEDRIVE% inside  this script?
echo "i:%BaseInstallPath%"
@REM In case there is any madness in the directory given, clobber the vast majortiy of repeated slashes.
SET "BaseInstallPath=%BaseInstallPath:\\\=\%"
REM echo "3:%BaseInstallPath%"
SET "BaseInstallPath=%BaseInstallPath:\\\=\%"
REM echo "2:%BaseInstallPath%"
SET "BaseInstallPath=%BaseInstallPath:\\\=\%"
REM echo "1:%BaseInstallPath%"
SET "BaseInstallPath=%BaseInstallPath:\\=\%"
REM echo "d:%BaseInstallPath%"

@REM Set logging path.
SET "LogPath=%BaseInstallPath%\install.log"

set "AppPath=%BaseInstallPath%\App"
set "DataPath=%BaseInstallPath%\Data"
set "DataUninst=%DataPath%\%LibItemNumber%_tempuninst.list"
IF %DataPath:~-1%==\ SET DataPath=%DataPath:~0,-1%
@REM Alt data path is the path for ndLibraray with unix style slashes.
SET "DataPathAlt=%DataPath:\=/%"


if not exist %DataPath% (
  echo Making directory "%DataPath%"
  mkdir %DataPath%
) else (
  echo Data path ready for data "%DataPath%"
)
echo Open Install log  >> "%LogPath%"
date /T  >> "%LogPath%"
time /T  >> "%LogPath%"

@REM Extract data
echo.>%DataUninst%
for /f "usebackq delims=|" %%f in (`dir /b "%~dp0Data\*.zip"`) do (
  echo Extract - %%f
  @REM 7za <command> [<switches>...] <archive_name> [<file_names>...]
  echo %sevenZ% x -o"%DataPath%" -y -aos %~dp0%%f >> "%LogPath%"
  %sevenZ% x -o"%DataPath%" -y -aos %~dp0%%f
  echo %sevenZ% l -o"%DataPath%" -y -aos %~dp0%%f ^>%DataUninst% >> "%LogPath%"
  %sevenZ% l -o"%DataPath%" -y -aos %~dp0%%f >>%DataUninst%
)

@Rem get data version somehow
@REM Should be stored into the index lib.conf
@REM We'll do two tests, one for a lib.conf, find Version= line.
@REM If that fails, get last dir which starts with v.

dir /b  /O-N /AD "%DataPath%\%LibIndex%\v*" > "%DataPath%\%LibIndex%\vtmp.txt"
@REM This over complicated line looks for version number folders which match the proper pattern,
@REM it gets the last one of those and puts it into the DATAVERSION variable.
@REM Two temp files are used for this purpose, vtmp.txt, and vrdy.txt both of which are removed when done.
findstr /R "^v[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$" "%DataPath%\%LibIndex%\vtmp.txt" > "%DataPath%\%LibIndex%\vrdy.txt"  && set /p "DATAVERSION="<"%DataPath%\%LibIndex%\vrdy.txt"  & del "%DataPath%\%LibIndex%\vtmp.txt" & del "%DataPath%\%LibIndex%\vrdy.txt"
if "%DATAVERSION%"=="" (
  echo Data library Not versioned by folder or version failed to set. Only vYYYY-MM-DD type versions supported.
  REM exit /b
)
REM echo DirectoryVersioning = "%DATAVERSION%"

set "idx_LibConf=%DataPath%\%LibIndex%\lib.conf"
@REM should move any old version of index out of way....
echo Checking for data version update ... ;

if exist %idx_LibConf% (
    echo  in %idx_LibConf% ...
    @REM Get Path from lib, place into temp Cant afford to do that! it will kill system.
    @REM findstr /R "^Path=.*" "%idx_LibConf%" > %DataPath%\%LibIndex%\ltmp.txt
    @REM echo.>>%DataPath%\%LibIndex%\ltmp.txt
    @REM Get Version from lib, place into temp
    findstr /R "^Version=.*" "%idx_LibConf%" >> %DataPath%\%LibIndex%\ltmp.txt

    @REM Convert tmp lines to one the line parser understands.
    setlocal enableDelayedExpansion enableextensions
    set "var="
    for /f "usebackq" %%A in ("%DataPath%\%LibIndex%\ltmp.txt") do set var=!var! %%A
    echo !var!  ENDECHO >%DataPath%\%LibIndex%\libvars.txt
    @REM Get the lib vars out of the temp file, use handy dandy varline parser.
    call %~dp0\Setup\utils\var_line_parser %DataPath%\%LibIndex%\libvars.txt

    @REM del  %DataPath%\%LibIndex%\libvars.txt %DataPath%\%LibIndex%\ltmp.txt
    echo Got vo!Version!, and vp!Path!

    IF "!Version!"=="" (
        echo Warning, no version in old file.
    ) else (
        if "!Version!" == "%DATAVERSION%" (
            echo Same version, no update needed.
            echo.
        ) else (
            echo "Data Update detected. new is %DATAVERSION% old is !Version! "

            @REM echo "mv \"$idx_LibConf\"  \"${idx_LibConf%.*}.$v.conf\"" >> $LogPath;
            @REM mv "$idx_LibConf"  "${idx_LibConf%.*}.$v.conf"
            echo move "%idx_LibConf%"  "%idx_LibConf:~0,-1%.!Version!.conf" >> "%LogPath%"
            move "%idx_LibConf%"  "%idx_LibConf:~0,-1%.!Version!.conf"
        )
    )
) else (
    echo  No existing data. Great!
)

if not exist %idx_LibConf% (
  @REM mkdir "%DataPath%\%LibItemNumber%"
  echo copy "%DataPath%\%LibIndex%\%DATAVERSION%\lib.conf" "%idx_LibConf%" >> "%LogPath%"
  copy "%DataPath%\%LibIndex%\%DATAVERSION%\lib.conf" "%idx_LibConf%"

  if exist %idx_LibConf% (
    @REM The path echo line adds a newline to the file in case it was missing.
    @REM This line is very fragile, and must be extra careful with extra spaces.

    echo @REM insert lib path line "Path=%DATAVERSION%" into %idx_LibConf%>> "%LogPath%"
    findstr /R "^Path=.*$" "%idx_LibConf%" || echo.>>"%idx_LibConf%"&echo Path=%DATAVERSION%>> "%idx_LibConf%"
    findstr /R "^Version=.*$" "%idx_LibConf%" || echo @REM Adding Version line "Version=%DATAVERSION%" into %idx_LibConf%>> "%LogPath%"
    findstr /R "^Version=.*$" "%idx_LibConf%" || echo Version=%DATAVERSION%>> "%idx_LibConf%"
  ) else (
    echo ERROR setting up lib! missing "%idx_LibConf%"!
    echo ERROR setting up lib! missing "%idx_LibConf%"!>> "%LogPath%"
  )
)
@REM Clean lib of whitesepace then,
@REM Get LibName and DATAVERSION from data for use with the program shortcut.
if exist %idx_LibConf% (
  call %~dp0\Setup\utils\remove_blanks %idx_LibConf%
  @REM del %idx_LibConf%
  @REM move %idx_LibConf%.clean %idx_LibConf%
  @REM Get true lib name from file %idx_LibConf%
  @REM Also grab version if its in there.
  findstr /R "^LibName=.*" "%idx_LibConf%" > %DataPath%\%LibIndex%\ltmp.txt
  echo.>>%DataPath%\%LibIndex%\ltmp.txt
  findstr /R "^Version=.*" "%idx_LibConf%" >> %DataPath%\%LibIndex%\ltmp.txt

  @REM Get the lib vars out of the temp file, use handy dandy varline parser.
  setlocal enableDelayedExpansion enableextensions
  set "var="
  for /f "usebackq" %%A in ("%DataPath%\%LibIndex%\ltmp.txt") do set var=!var! %%A
  echo !var!  ENDECHO >%DataPath%\%LibIndex%\libvars.txt

  @REM echo call %~dp0Setup\utils\var_line_parser %DataPath%\%LibIndex%\libvars.txt
  call %~dp0\Setup\utils\var_line_parser %DataPath%\%LibIndex%\libvars.txt
  REM echo ver=!Version!
  REM echo lib=!LibName!
  del  %DataPath%\%LibIndex%\libvars.txt %DataPath%\%LibIndex%\ltmp.txt

  IF "!Version!"=="" (
    ECHO Version is NOT defined in lib.conf
  ) else (
    set DATAVERSION=!Version!
  )
  IF "!LibName!"=="" (
    set LibName=%LibIndex%
    ECHO LibName is NOT defined in lib.conf
  )
)

@REM Silent Install app
set ip=%~dp0Setup\%AppInstaller%
set InstallPath=%AppPath%\%PROGRAMVERSION%
if not exist %ip% (
  echo App installer missing! "%ip%"
)
echo %ip% /S /D=%InstallPath% >> "%LogPath%"
if not exist %InstallPath% (
  echo "Installing app to %InstallPath%"
  start /b /wait %ip% /S /D=%InstallPath%
) else (
  echo app already installed at "%InstallPath%"
)

echo if not exist %InstallPath%\Uninstall.exe del %AppPath%\Uninstall%PROGRAMVERSION%.bat ^& exit /b > %AppPath%\Uninstall%PROGRAMVERSION%.bat
echo %InstallPath%\Uninstall %InstallPath% >> %AppPath%\Uninstall%PROGRAMVERSION%.bat

@REM Create shortcut.
IF "!DATAVERSION!"=="" (
  echo Version info not set on lib.
  move %DataUninst% %DataPath%\Uninstall_%LibItemNumber%.list
  set "DataUninst=%DataPath%\Uninstall_%LibItemNumber%.list"
) else (
  IF "!DATAVERSION:~0,1!"=="v" (
    SET "DataVersionString=_d!DATAVERSION:~1!"
  ) else (
    set "DataVersionString=_d!DATAVERSION!"
  )
  move %DataUninst% %DataPath%\Uninstall_%LibItemNumber%_!DATAVERSION!.list
  set "DataUninst=%DataPath%\Uninstall_%LibItemNumber%_!DATAVERSION!.list"
)

if "%LibItemNumber%"=="" (
  echo LibItemNumber Missing!
) else (
  set "LibItemString=%LibItemNumber%_"

)

set "StartShortcut=%BaseInstallPath%\%LibItemString%%LibName%_a%PROGRAMVERSION%%DataVersionString%"
echo %~dp0Setup\utils\shortcut.bat %InstallPath%\AtlasViewer.exe %InstallPath% InteractivePublishingDataViewer "--ndLibrary %DataPathAlt%/%LibIndex%" >>%LogPath%
if not exist %StartShortcut%.lnk (
  echo "Making lib link to %LibItemString%%LibName%"
  echo continue in
  call %~dp0Setup\utils\shortcut.bat %InstallPath%\AtlasViewer.exe %InstallPath% InteractivePublishingDataViewer "--ndLibrary %DataPathAlt%/%LibIndex%"
  echo move %InstallPath%\AtlasViewer.lnk %StartShortcut%.lnk >> %LogPath%
  move %InstallPath%\AtlasViewer.lnk %StartShortcut%.lnk
)
echo Continuing in ...
timeout 6
cls

@REM Give user a summary.
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo Setup complete.
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo Log file saved to %LogPath%.
echo Shortcut to Viewer and data is
echo %StartShortcut%
echo.
echo To uninstall data, delete data folder. WARNING THIS ELIMINATES ALL LIBRARIES.
echo   %DataPath%
echo To uninstall application, find the uninstall shortcut from startmenu,
echo   OR
echo run %AppPath%\Uninstall%PROGRAMVERSION%.bat
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
timeout 15
exit /b
