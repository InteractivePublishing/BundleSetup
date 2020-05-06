# Bundler setup for Interactive publishing code.
holds the script components of our bundle setup.
Have thoughts about setting up a minimal busybox env for windows so we have
a lightweight portable script we can schlep around.
Lots wrong with this, including we didnt lookup a cross platform script
setup yet.

This requires 7zip for windows, I think it was configured to use any
7z####-extra folder under setup to find 7za.exe
If we get the busybox idea finished, it'll require msys2's
runtime+busybox+winln extracted together in one folder and given the basic
msys2_bbsetup.

setup_vars.txt is a template for the params we're respecting in our setup
bundles.
