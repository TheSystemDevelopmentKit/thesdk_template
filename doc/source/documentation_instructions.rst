==========================
Documentation instructions
==========================

Current docstring documentation style is Numpy
https://numpydoc.readthedocs.io/en/latest/format.html

Continuous implementation-build process for documentation
---------------------------------------------------------

Documentation build environment for Sphinx-docstrings build are located in `$THESDKHOME/docs`

CI documentation build process uses a docker configuration 
https://github.com/TheSystemDevelopmentKit/thesdktestimage that has an automated relelease to registry. 
The image is currently a fedora34 image with installed software for building the docs, and there should 
not be need to edit that unless the build process fails due to a missing software. Python dependencies are 
installed during the build by pip3userinstall.sh script.

Aforementioned image is used in the workflow definition file `$THESDKHOME.github/workflows/main.yaml` 
which defines the branch to which the pushes launces execution of a script `$THESDKHOME/CI-helpers/build_docs.sh`.

Conlusion:

* To edit the contents of the documenation, edit the docstrings of the entity python files, 
  the files doc/sources of corresponding entities, and the files under THESDKHOME/dosc/sources.
  
* To reconfigure the build environment, modify https://github.com/TheSystemDevelopmentKit/thesdktestimage.

* To configure on which branches the build process is launced, edit `$THESDKHOME/.github/workflows/main.yaml`

* To control the build process, edit `$THESDKHOME/CI-helpers/build_docs.sh`

