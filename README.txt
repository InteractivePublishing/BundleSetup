Data+Viewer Bundle Setup.
Viewer is based on 3D Slicer, for documentation on Slicer, visit
https://www.slicer.org/wiki/Documentation/4.8
(Not all modules available.)

Please run the appropriate script for your operating system.
(sorry linux/mac users, support is in the works.)

The installer may be blank for a while upon startup.

Do not close the script window until it states Setup complete.
If there are any problems in setup Please check the HELP file for a solution.


Windows, the default installation path is C:/IP/
Power Users: To change the install location edit BaseInstallPath in setup_vars
NOTE: Support is not available to assist.

Mac, the primary installation is to /Applications/InteractivePublishingStorage.app
Power Users: To adjust the install location the MacSetup.command script must
be edited. NOTE: Support is not available to assist.

Once installed a shortcut will be created to launch this application+data together.
These shortcuts follow a formula of
InteractivePublishingApp_{LIBCATELOGITEM}{LIBNAME}_a{PROGRAMVERSION}_d{DATAVERSION}

On windows they will be in the BaseInstallPath (not on the start menu).
On mac these shortcut apps will be created in /Applications.



Upon startup, you will select a working directory for Atlas Viewer, this may
be changed later upon startup. If you select the permanent checkbox see HELP
file for settings reset instructions.

Once a working directory is selected, you are greeted with the main interface.
From here, continue along the tool bar menus at the top from left to right.
"Data" sets the data set (may be disabled if only one data set available).
"Protocol" sets the view protocol and controls available
    -"Review" (if available) displays publication information and figure views.
    -"Registration" displays and interacts with 2D data, and user supplied data
      (scalar slices, labels, etc.)
    -"3D" displays and interacts with 3D data
      (3D volumes, tracts, 3D labels, etc.)
"Labels" opens the listing of labels and allows you to turn individual lables on/off by clicking the image


Advanced users can access the full 3D Slicer functionality by right clicking
on the main toolbar, and enabling the parts you're looking for.
Please note: Support is only additional options from the full slicer documentation.

Full documentation on Slicer, visit
https://www.slicer.org/wiki/Documentation/4.8
(Not all modules available.)

To access the 3D Slicer settings, in three steps.
One: open python terminal using key combo shortcut "ctrl+3"
Two: copy/paste the following into the open pyton console, and press enter to
open settings dialog.
slicer.app.settingsDialog().show();
Three: close python terminal using key combo shortcut "ctrl+3"
