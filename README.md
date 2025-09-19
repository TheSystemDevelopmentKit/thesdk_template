# Minimum instructions to take TheSyDeKick into use
These scripts work out of the box in Linux with a csh or tcsh command line shell.

Initialize submodules
```shell
./init_submodules.sh
```

Install Python dependencies:
If you wish to install to you user-specific directory
```shell
./pip3userinstall.sh
```

If you wish to first create a virtual environment to TheSyDeKick root.
TheSyDeKick assumes your local virtual environment is in .venv . It may also be elsewhere.
```shell
python3 -m venv ./.venv
./pip3userinstall.sh -V
```
See `python3 -m venv -h`for all the options for virtual environment.

Take the tool into use:
```shell
source sourceme.csh
```

Configure TheSyDeKick:
```shell
./configure
```

Further detailed instructions can be found in the documentation
[https://thesystemdevelopmentkit.github.io/docs/index.html](https://thesystemdevelopmentkit.github.io/docs/index.html)


