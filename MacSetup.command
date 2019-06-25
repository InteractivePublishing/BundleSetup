#!/bin/bash
cd $(dirname $0);


# Should read these vars in from startup file
for thing in $( < setup_vars.txt ) ; do if [ "$thing" != "ENDECHO" ]; then eval $thing; else break; fi; done
# LibItemNumber="CIVM-17001";
# LibIndex="000Mouse_Brain";
AppBundleName=$MacAppBundleName;
PROGRAMVERSION=$MacProgramVersion;

astr="-macosx-amd64_";
AppInstaller="${AppBundleName}$astr$PROGRAMVERSION.dmg";


if [ ! -e "Setup/$AppInstaller" ] ; then 
  echo "Setup application not found, quiting.";
  echo "Missing \"Setup/$AppInstaller\"";
  sleep 30
  exit 
else 
  echo "Proceeding with installer $AppInstaller";
fi;

#mountpoint AtlasViewer-0.4.0-854976d-macosx-amd64
BaseInstallPath="/Applications/InteractivePublishingStorage.app";
InstallParent=$(dirname $BaseInstallPath)

LogPath="$BaseInstallPath/install.log";
TMPLOG="$HOME/.IP_tmp.log";  #This is where we log things before we can add them to our application.
PermFile="$HOME/.IP_tmp.perm";

AppPath="$BaseInstallPath";
DataPath="$BaseInstallPath/Data";
TMP_DATAPATH="$AppPath/../.IPData";
DataUninst="$DataPath/${LibItemNumber}_tempuninst.list";

echo "$LibItemNumber"
echo "$LibIndex";

echo "Start install log" > $TMPLOG;
date -j >> $TMPLOG;

if [ ! -w "$InstallParent" ]; then
  echo "Sorry I cant continue, I dont have enough privilege : (";
  echo "Please give me more privilege...";
  correct_perms=$(stat -f %Mp%Lp $InstallParent);
  #osascript -e "do shell script  \"mkdir $BaseInstallPath && chown $USER $BaseInstallPath\" with administrator privileges"
  #sudo mkdir $BaseInstallPath && chown user $BaseInstallPath;
  # this isnt sufficient... i guess i ahve to elevate this whole script....
  #osascript -e "do shell script  \"$0\" with administrator privileges"
  # This comes with its own problems. we lose all output. Lets try clobbering permissions, then repairing them when we're done.
  echo "osascript -e \"do shell script  \\\"chmod a+rwx $InstallParent \\\" with administrator privileges\" " >> $TMPLOG;
  osascript -e "do shell script  \"chmod a+rwx $InstallParent \" with administrator privileges"
  if [ ! -f $PermFile ]; then
      echo "Saving perms to $PerMFile";
      echo 'echo $correct_perms > $PermFile;' >> $TMPLOG ; 
      echo $correct_perms > $PermFile;
  fi;
fi
if [ ! -w "$InstallParent" ]; then
  echo "Sorry I cant continue, I dont have enough privilege : (";
  sleep 6;
  exit;
fi
rm=`which rm`;

AppUpdate=0;
if [ -d $AppPath ]; then 
  iAppBundleName=$(grep "^AppBundleName=.*$" "$AppPath/bundle_name.info"|tail -n 1|cut -d '=' -f2);
  iPROGRAMVERSION=$(grep "^PROGRAMVERSION=.*$" "$AppPath/bundle_name.info"|tail -n 1|cut -d '=' -f2);
  if [ "$iAppBundleName" = "$AppBundleName" -a "$PROGRAMVERSION" = "$iPROGRAMVERSION" ]; then 
    echo "WARNING: Repeated install may cause error!";
    #exit;
  else
    echo "App Update detected!";
    echo "Old \"$iAppBundleName:$iPROGRAMVERSION\"";
    echo "New \"$AppBundleName:$PROGRAMVERSION\"";
    AppUpdate=1;
  fi;
fi;
if [ -d $AppPath -a $AppUpdate -eq 1 ];then
  #
  # Save old data, the uninstall and log and remove application
  #
  echo "Preserve Old Data";
  echo "mv $DataPath $TMP_DATAPATH" >> $TMPLOG
  mv $DataPath $TMP_DATAPATH
  #echo "Preserve OldDataUninstaller";
  #echo "mv $DataUninst $TMP_DATAPATH/$(basename $DataUninst)" >> $TMPLOG
  #mv $DataUninst $TMP_DATAPATH/$(basename $DataUninst)
  echo "Preserve old log";
  echo "mv $LogPath $TMP_DATAPATH/$(basename $LogPath)" >> $TMPLOG
  mv $LogPath $TMP_DATAPATH/$(basename $LogPath)
  if [ ! -d $DataPath ]; then  #Only remove all app's if data is safe.
  #$rm -fr $AppPath
  echo "find /Applications -type d -name \"InteractivePublishing*app\" -maxdepth 1 -exec rm -fr {} \; -print" >> $TMPLOG;
  find /Applications -type d -name "InteractivePublishing*app" -maxdepth 1 -exec rm -vfr {} \; -print;
  fi;
fi;

if [ -d $AppPath ];then
    if [  $AppUpdate -eq 1 ];then
        echo "Old app removal failed! Data in $TMP_DATAPATH. Log details in $TMPLOG."
        exit 1;
    fi
    echo "App exists and is up to date, not reinstalling";
else 
  #
  # (Re)Install application.
  #
  dt='';
  if [ ! -w "$PWD" ]; then
    echo "Cant use this directory for setup! Will use home.";
    dt="$HOME/"; # If we cant write here, then re-create in home dir. 
  fi;
  # remove old lic pass installer.
  if [ -f $dt.LIC_ACCEPT.cdr ];then
      if [ $dt.LIC_ACCEPT.cdr -ot Setup/$AppInstaller -o $AppUpdate -eq 1 ]; then
	  echo "Removing old installer cache...";
	  echo "rm $dt.LIC_ACCEPT.cdr" >>$TMPLOG;
	  rm $dt.LIC_ACCEPT.cdr;
      fi;
  fi;
  if [ ! -f $dt.LIC_ACCEPT.cdr ]; then # bludgeon the license stuff.
    echo "Preparing installer ... please wait";
    echo "hdiutil convert -quiet \"Setup/$AppInstaller\" -format UDTO -o $dt.LIC_ACCEPT" >>$TMPLOG;
    hdiutil convert -quiet "Setup/$AppInstaller" -format UDTO -o $dt.LIC_ACCEPT
  fi;
  
  echo "hdiutil attach -quiet -nobrowse -noverify -noautoopen -mountpoint .AppImg $dt.LIC_ACCEPT.cdr" >>$TMPLOG;
  hdiutil attach -quiet -nobrowse -noverify -noautoopen -mountpoint .AppImg $dt.LIC_ACCEPT.cdr

  echo "Copying Application ...";
  echo "cp -RPp  .AppImg/Atlasviewer.app $AppPath" >> $TMPLOG
  cp -RPp $dt.AppImg/AtlasViewer.app $AppPath
  echo "AppBundleName=$AppBundleName" >> $AppPath/bundle_name.info
  echo "PROGRAMVERSION=$PROGRAMVERSION" >> $AppPath/bundle_name.info
  echo "hdiutil detach $dt.AppImg" >> $TMPLOG
  hdiutil detach $dt.AppImg
fi
#
# Add/restore data
#
if [ ! -d $AppPath ];then
  echo "Error installing application!";
  sleep 6;
  exit 1;
else
  if [ -d $TMP_DATAPATH ]; then
    echo "Restore Old Data Uninstaller";
    #echo "mv $TMP_DATAPATH/$(basename $DataUninst) $DataUninst" >>$TMPLOG;
    #mv $TMP_DATAPATH/$(basename $DataUninst) $DataUninst ;
    echo "Restore Old install Log";
    echo "mv $TMP_DATAPATH/$(basename $LogPath) $LogPath";
    mv $TMP_DATAPATH/$(basename $LogPath) $LogPath;
    echo "Restore Old Data";
    echo "mv $TMP_DATAPATH $DataPath" >> $TMPLOG;
    mv $TMP_DATAPATH $DataPath;
  fi;
  echo "inserting new log details.";
  cat $TMPLOG >> $LogPath;
  echo "rm $TMPLOG;" >> $LogPath;
  $rm $TMPLOG;
  echo ''>$DataUninst
  echo "Installing zips from $PWD";
  sleep 3
  for zipfile in *zip ;
  do echo $zipfile;
     #echo unzip $zipfile $DataPath;
     echo "unzip -u $zipfile -d $DataPath" >> $LogPath;
     unzip -u $zipfile -d $DataPath;
     echo "unzip -l $zipfile >> $DataUninst" >> $LogPath
     unzip -l $zipfile >> $DataUninst
  done
fi;

#
# get data version somehow
#
# Should be stored into the index lib.conf

# We'll do two tests,
# get last dir which starts with v and find Version= line in lib.conf.

# Find all v* folders get last one(alphabetically).
DATAVERSION=$(find "$DataPath/$LibIndex" -iname "v*" -exec basename {} \;  |tail -n 1);

if [ "X_$DATAVERSION" = "X_" ]; then 
    echo "Data library Not versioned by folder or version failed to set. Only vYYYY-MM-DD type versions supported."
fi

idx_LibConf="$DataPath/$LibIndex/lib.conf";
# should move any old version of index out of way....
echo -n "Checking for data version update ... ";
if [ -f "$idx_LibConf" ]; then
    echo -n " in $idx_LibConf ... ";
    pc=$(grep -c "^Path=.*$" "$idx_LibConf"); # count path parts of lib
    if [ $pc -gt 0 ] ;then # there is at least one path, grab version.
        v=$(grep "^Version=.*$" "$idx_LibConf"|cut -d '=' -f2);
        if [ "$v" != "$DATAVERSION" ];then
            echo "Data Update detected."
            echo "mv \"$idx_LibConf\"  \"${idx_LibConf%.*}.$v.conf\"" >> $LogPath;
            mv "$idx_LibConf"  "${idx_LibConf%.*}.$v.conf"
        fi;
    else
        echo "Warning, no version in old file.";
    fi;
else
    echo " No existing data. Great!";
fi;

if [ ! -f "$idx_LibConf" ]; then 
  echo "cp -p \"$DataPath/$LibIndex/$DATAVERSION/lib.conf\" \"$idx_LibConf\"">>$LogPath;
  cp -p  "$DataPath/$LibIndex/$DATAVERSION/lib.conf" "$idx_LibConf";
  if [ -f "$idx_LibConf" ]; then 
    echo # insert lib path line "Path=$DATAVERSION" into $idx_LibConf>> "$LogPath"
    #if no Path= in file, add Path= to file
    if [ $(grep -c "^Path=.*$" "$idx_LibConf") -eq 0 ]; then 
      echo '' >> $idx_LibConf;
      echo "# Adding Path line \"Path=$DATAVERSION\" into $idx_LibConf" >> $LogPath
      echo "Path=$DATAVERSION">> "$idx_LibConf";
    fi;
    if [ $(grep -c "^Version=.*$" "$idx_LibConf") -eq 0 ]; then
      echo "# Adding Version line \"Version=$DATAVERSION\" into $idx_LibConf" >> $LogPath
      echo "Version=$DATAVERSION">> "$idx_LibConf";
    fi
  else
    echo "ERROR setting up lib! missing \"$idx_LibConf\"!" >> $LogPath
    echo "ERROR setting up lib! missing \"$idx_LibConf\"!" 
  fi
fi
# Get LibName and Version from lib.conf for use with the program shortcut.
# put Version into DATAVERSION
#
if [ -f $idx_LibConf ]; then 
  # Get true lib name from file $idx_LibConf
  # Also grab version if its in there.
  if [ $(grep -c "^LibName=.*$" "$idx_LibConf") -ge 1 ] ; then
    LibName=$(grep "^LibName=.*$" "$idx_LibConf"|tail -n 1|cut -d '=' -f2);
  else
    echo "LibName is NOT defined in $idx_LibConf";
    LibName=$LibIndex;  
  fi
  if [ $(grep -c "^Version=.*$" "$idx_LibConf") -ge 1 ] ; then
    Version=$(grep "^Version=.*$" "$idx_LibConf"|tail -n 1|cut -d '=' -f2);
    DATAVERSION=$Version;
  else
    echo "Version is NOT defined in $idx_LibConf";
  fi
fi
  
# Move data uninstaller list to better name
# sort out available name/details for shortcut
if [ "X_$DATAVERSION" = "X_" ]; then 
  echo Version info not set on lib.
  echo "mv $DataUninst \"$DataPath/Uninstall_$LibItemNumber.list\"" >> $LogPath;
  mv $DataUninst "$DataPath/Uninstall_$LibItemNumber.list"
  DataUninst="$DataPath/Uninstall_$LibItemNumber.list";
else
  if [ "${DATAVERSION:0:1}" = "v" ]; then
    DataVersionString="_d${DATAVERSION:1}";
  else
    DataVersionString="_d$DATAVERSION";
  fi
  echo "mv $DataUninst \"$DataPath/Uninstall_${LibItemNumber}_$DATAVERSION.list\"" >> $LogPath;
  mv $DataUninst "$DataPath/Uninstall_${LibItemNumber}_$DATAVERSION.list"
  DataUninst="$DataPath/Uninstall_${LibItemNumber}_$DATAVERSION.list";
fi


echo "find $BaseInstallPath -type d -exec chmod a+rx {} \;" >> $LogPath;
find $BaseInstallPath -type d -exec chmod a+rx {} \;

echo "find $BaseInstallPath -type f -exec chmod a+r {} \;" >> $LogPath;
find $BaseInstallPath -type f -exec chmod a+r {} \; 

if [ "X_$LibItemNumber" = "X_" ]; then
  echo LibItemNumber Missing!
else
  LibItemString="${LibItemNumber}_";
fi
#
# Create shortcut app.
#
ShortcutName="InteractivePublishingApp_${LibItemString}${LibName}_a$PROGRAMVERSION$DataVersionString";

StartShortcut="/Applications/$ShortcutName.app";
StartShortcut_sh="$BaseInstallPath/$ShortcutName.sh";
if [ ! -d $StartShortcut ]; then
  echo "Making lib link to $LibItemString$LibName \"$ShortcutName\""
  if [ ! -d "$BaseInstallPath/$ShortcutName.app"  ]; then 
    echo "#!/bin/sh" > $StartShortcut_sh;
    echo "open $BaseInstallPath --args --ndLibrary \"$DataPath/$LibIndex\"" >> $StartShortcut_sh;
    #Setup/util/appify.sh your-shell-script.sh "Your App Name"
    echo "pushd $PWD">>$LogPath;
    setupdir=$PWD;
    pushd $PWD;
    echo "cd $BaseInstallPath" >> $LogPath;
    cd $BaseInstallPath;
    echo "Setup/util/appify.sh \"$ShortcutName\" \"$ShortcutName\"">>$LogPath;
    $setupdir/Setup/util/appify.sh "$ShortcutName.sh" "$ShortcutName";
    echo "$rm \"$ShortcutName.sh\"" >> $LogPath;
    $rm "$ShortcutName.sh";
    echo "popd">>$LogPath;
    popd;
  fi;
  echo "mv $BaseInstallPath/$ShortcutName.app $StartShortcut" >> $LogPath;
  mv "$BaseInstallPath/$ShortcutName.app" "$StartShortcut";
  
  echo find $StartShortcut -exec chmod a+rx {} \; >> $LogPath;
  find $StartShortcut -exec chmod a+rx {} \; ;
fi

correct_perms=$(cat $PermFile);
echo "osascript -e \"do shell script  \\\"chmod $correct_perms $InstallParent \\\" with administrator privileges\" " >> $LogPath;
osascript -e "do shell script  \"chmod $correct_perms $InstallParent \" with administrator privileges";

cur_perms=$(stat -f %Mp%Lp $InstallParent);
# becaiuse these are octal -eq would also have worke.d 
if [ "$cur_pemrs" == "$correct_perms" ]; then
    if [ -f $PermFile ]; then 
        $rm $PermFile;
    fi
else
    echo "ERROR: Permissions couldnt be repaired on $InstallParent They should be $correct_perms, but instead are $cur_perms" >> $LogPath;
    echo "ERROR: Permissions couldnt be repaired on $InstallParent They should be $correct_perms, but instead are $cur_perms";
fi


echo "Continuing in 3 seconds...";
sleep 3;

clear;
# Give user a summary.
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo "Setup complete."
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo "Log file saved to $LogPath."
echo ""
echo "To uninstall data, delete data folder. WARNING THIS ELIMINATES ALL LIBRARIES."
echo "  $DataPath"
echo "To uninstall application, NOTE: this will leave app shortcut litter(sorry)."
echo "  run rm -fr $AppPath/Contents"
echo "  run rm -fr $AppPath/bundle_name.info"
echo "WARNING: If you remove $AppPath you will remove all data!"
echo ""
echo ""
echo "To start the program with your data use "
echo "$StartShortcut"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
