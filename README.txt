Data+Viewer Bundle Setup.
Viewer uses 3D Slicer, for documentation on Slicer, visit
https://www.slicer.org/wiki/Documentation/4.10
(Not all modules available.)

Please run the appropriate script for your operating system.
(linux, you can use the mac setup to clue you in.)

Do not close the script window until it states Setup complete.
If there are any problems in setup Please check the HELP file for a solution.

The setup routine is simple, it's job is to create a shortcut to 3D slicer
with --python-script "bundlePath/ndLibrarySupport/Testing/DistStart.py"

Mac Security settings will likely be a problem. Google will help you find resolution.

Setup generates a shortuct to launch this data with custome slicer views.
These shortcuts follow a formula of
StartSlicer_with_{LIBNAME}_d{DATAVERSION}

They are always created in the root of the data path, next to the setup files.

Upon startup, you will be prompted to click the menu

After selecting the data you'll be looking at, you can select the image type
to load/view at the bottom of the viewers.

Advanced users can access the full 3D Slicer functionality by right clicking
on the main toolbar, and enabling the parts you're looking for.
Please note: Support is only avilable from the full slicer documentation.

Full documentation on Slicer, visit
https://www.slicer.org/wiki/Documentation/4.10
(Not all modules available.)
