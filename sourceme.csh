#Check for simulator setups
if ( `where use` == "" ) then
    echo "You have to set the simulator paths in the sourceme script"
else
    # This is AaltoUniversity  specific way to set paths
    # Set paths for Mentor programs (Eldo, Questasim)
use advms_17.1
# Set paths for Cadence programs (Spectre)
use icadv123
use ngspice
use icarus
endif

#Set module thesdk to PYTHONPATH
set called=($_)
set scriptfp=`readlink -f $called[2]`
set scriptdir=`dirname $scriptfp`

if ( ! $?PYTHONPATH ) then
    setenv PYTHONPATH $scriptdir/Entities
    foreach package ( `cat .gitmodules | sed -n '/^\[submodule\s*"Entities/p' | sed 's/\(\[submodule\s*"\)\(Entities.*\)\(\s*"\]\)/\2/g'` )
        setenv PYTHONPATH ${scriptdir}/${package}:${PYTHONPATH}
    end
else
    setenv PYTHONPATH $scriptdir/Entities:${PYTHONPATH}
    foreach package ( `cat .gitmodules | sed -n '/^\[submodule\s*"Entities/p' | sed 's/\(\[submodule\s*"\)\(Entities.*\)\(\s*"\]\)/\2/g'` )
        setenv PYTHONPATH ${scriptdir}/${package}:${PYTHONPATH}
    end
endif

if ( -d $scriptdir/.venv ) then
    echo "Found the default virtual environment at .venv. Sourcing the activation script ./.venv/bin/activate.csh."
    source  $scriptdir/.venv/bin/activate.csh && echo "Virtual environmetn activated. Deactivate with 'deactivate'".
else
    if ( -d ${HOME}/.local/bin && "${PATH}" !~ *"${HOME}/.local/bin"* ) then
        echo "Adding \${HOME}/.local/bin to path for user specific python installations"
        setenv PATH ${HOME}/.local/bin:${PATH}
    else
        echo "${HOME}/.local/bin already in path"
    endif
endif

unset called
unset scriptfp
unset scriptdir


