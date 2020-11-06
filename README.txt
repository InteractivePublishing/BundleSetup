Data+Viewer Bundle Setup. For best viewing on windows, open with wordpad.
Viewer uses 3D Slicer, for documentation on Slicer, visit
https://www.slicer.org/wiki/Documentation/4.10
(Not all modules available.)

**** Requirements ****
Software:
3D slicer, version 4.10.2 or newer. Availabe at https://download.slicer.org/
(Release, 4.10.2, and 4.11.20200930 tested, cannot guarntee other versions will function.)
Optional, git command line tools to update ndLibrarySupport code.
Hardware:
Dual core processor recommendd with 8GiB RAM

**** Setup ****
Setup generates a shortuct to launch this data with custome slicer views.
These shortcuts follow a formula of
StartSlicer_with_{LIBNAME}_v{DATAVERSION}

They are always created in the root of the data path, next to the setup files.
You can move the shortcuts after creation.
You CANNOT move the data folder, if you do delete the shortcut, and re-run setup.

Run the appropriate script for your operating system to generate the shortcut.
(linux, you can use the mac setup to clue you in.)

WARNING: The setup scripts don't work if there are spaces or special characters in the path.

Do not close the script window until it states Setup complete.
If there are any problems in setup Please check the HELP file for a solution.

The setup routine is simple, it's job is to create a shortcut to 3D slicer
with --python-script "bundlePath/ndLibrarySupport/Testing/DistStart.py"

Mac Security settings will likely be a problem. Google will help you find resolution.

**** Use ****
See Getting Started guide for more indepth info.
Upon startup, you will be prompted to click the menu

After making your initial selection you can select the image type at the bottom
of the viewers.

Advanced users can access the full 3D Slicer functionality by clicking on the
view menu and enabling the parts which have been shut off.
Please note: Support is only avilable from the full slicer documentation.

Full documentation on Slicer, visit
https://www.slicer.org/wiki/Documentation/4.10
(Not all modules available.)

Customized view layouts are in use to attach data switch drop down menus.
You can switch between the default 3D slicer layouts or customizations using
the view menu and selecting layouts.
The custom views are designated with a Green Arrow.

Some layouts have a "load" panel for data which is not part of the bundle.
This allows arbitrary data to integrate with the simplified intterface.

Only a limited selection of data files have been tested and confirmed to work
well in this "load" panel. 2D images of nrrd/nhdr, png, tiff, nifti, or jpeg
work are known to work.
3D slicer supports a wide range of images, and data formats which may also
work.


Some data bundles require additional slicer modules. The viewer code will
check for them and prompt the user.

**** Help ****
For hints, basic problems, or known issues see HELP file.
