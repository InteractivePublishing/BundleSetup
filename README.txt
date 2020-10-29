Data+Viewer Bundle Setup.
Viewer uses 3D Slicer, for documentation on Slicer, visit
https://www.slicer.org/wiki/Documentation/4.10
(Not all modules available.)

To create a convience shortcut to start slicer with this data,
please run the appropriate script for your operating system.
(linux, you can use the mac setup to clue you in.)

WARNING: The setup scripts don't work if there are spaces or special characters in the path.

Do not close the script window until it states Setup complete.
If there are any problems in setup Please check the HELP file for a solution.

The setup routine is simple, it's job is to create a shortcut to 3D slicer
with --python-script "bundlePath/ndLibrarySupport/Testing/DistStart.py"

Mac Security settings will likely be a problem. Google will help you find resolution.

Setup generates a shortuct to launch this data with custome slicer views.
These shortcuts follow a formula of
StartSlicer_with_{LIBNAME}_d{DATAVERSION}

They are always created in the root of the data path, next to the setup files.
You can move the shortcuts after creation.
You CANNOT move the data folder, if you do delete the shortcut, and re-run setup.

Upon startup, you will be prompted to click the menu

After making your initial selection you can select the image type at the bottom
of the viewers.

Advanced users can access the full 3D Slicer functionality by clicking on the
view menu and enabling the parts which have been shut off.
Please note: Support is only avilable from the full slicer documentation.

Full documentation on Slicer, visit
https://www.slicer.org/wiki/Documentation/4.10
(Not all modules available.)

If tractography is available, the view code checks for the required slicer
module and prompts the user to install them.

Tractography is not fully integrated. Load the tractography.mrml slicer scene
after loading a data set. (Dragging the tractography.mrml file on to the open
window is probably easiest.)
Enable the slicer module panel with the view menu.
Enable the module selection panel as well.
The "Models" module is probably the easiest to work with.
"TractographyDisplay", and "Data" modules also work to enable/disable visiblity.
WARNING: Many of the advanced features in TractographyDisplay require powerful
graphics cards, and can eaasily overwhelm available graphics processing power.

If you like our custom data switch buttons, we provide some 3D inclusive views.
You can swich to them using the view menu, and selecting layouts.
The custom views are designated with a Green Arrow.
