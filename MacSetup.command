#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

SetupDir="$SCRIPTPATH"

BaseInstallPath="$SetupDir";
LogPath="$BaseInstallPath/install.log";

SlicerCount=$(ls -tr /Applications/ | grep -cE '.*Slicer.*[.]app')
SlicerPath=$(ls -dtr /Applications/*Slicer*.app|tail -n1)
if [ "$SlicerCount" -eq 0 ];then
    echo ""
    echo ""
    echo "3D slicer not found in /Applications, Please install Slicer first. Otherwise manually create your start shortcut"
    echo ""
    echo ""
    exit 1;
elif [ "$SlicerCount" -gt 1 ];then
    echo ""
    echo ""
    echo "Using newest 3D Slicer found: $SlicerPath, To use alternate see HELP file for hints manual instructions"
    echo ""
    echo ""
fi;

DataPath="$BaseInstallPath";

#
# get data version somehow
#
DataVersionString=$(basename "$DataPath");

echo "Start install log" > "$LogPath";
date -j >> "$LogPath";

rm=`which rm`;

idx_LibConf="$BaseInstallPath/lib.conf";
if [ ! -f "$idx_LibConf" ]; then
  echo ERROR setting up lib, missing "$idx_LibConf"
  echo ERROR setting up lib, missing "$idx_LibConf">> "$LogPath"
fi

#
# Create shortcut app.
#
# PyStart=$DataVersionString.py
PyStart=ndLibrarySupport/Testing/DistStart.py

ShortcutName="StartSlicer_with_$DataVersionString";

StartShortcut="$BaseInstallPath/$ShortcutName.app";
StartShortcut_sh="$BaseInstallPath/$ShortcutName.sh";
if [ ! -d "$StartShortcut" ]; then
  echo "Making lib link to $DataVersionString"
  if [ ! -d "$BaseInstallPath/$ShortcutName.app"  ]; then
    echo "#!/bin/sh" > "$StartShortcut_sh";
    echo "open $SlicerPath --args --python-script \"$DataPath/$PyStart\"" >> "$StartShortcut_sh";
    #Components/util/appify.sh your-shell-script.sh "Your App Name"
    chmod a+rx "$StartShortcut_sh"
    chmod go-w "$StartShortcut_sh"
    echo "pushd $PWD">>"$LogPath";
    pushd "$PWD";
    echo "cd $BaseInstallPath" >> "$LogPath";
    cd "$BaseInstallPath";
    echo "Components/utils/appify.sh \"$ShortcutName\" \"$ShortcutName\"">>"$LogPath";
    "$SetupDir/Components/utils/appify.sh" "$ShortcutName.sh" "$ShortcutName";
    echo "$rm \"$ShortcutName.sh\"" >> "$LogPath";
    $rm "$ShortcutName.sh";
    echo "popd">>"$LogPath";
    popd;
  else
        echo "Existing $BaseInstallPath/$ShortcutName.app, not re-creating";
  fi;
  echo find $BaseInstallPath/$ShortcutName.app -exec chmod a+rx {} \; >> "$LogPath";
  find "$BaseInstallPath/$ShortcutName.app" -exec chmod a+rx {} \;
fi


echo "Continuing in 3 seconds...";
sleep 3;

clear;
# Give user a summary.
echo "It is now safe to close this window"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo "Setup complete."
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo "Log file saved to $LogPath."
echo "To start program use"
echo "$StartShortcut"
echo ""
echo "To uninstall this package, simply delete folder."
echo "  $DataPath"
echo ""
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
