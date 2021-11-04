# Set paths for Mentor programs (Eldo)
use advms_17.1
# Set paths for Cadence programs (Spectre)
use icadv123
     
#Set module thesdk to PYTHONPATH
set called=($_)
set scriptfp=`readlink -f $called[2]`
set scriptdir=`dirname $scriptfp`

if ( ! $?PYTHONPATH ) then
    setenv PYTHONPATH $scriptdir/Entities/thesdk
else
    setenv PYTHONPATH $scriptdir/Entities/thesdk:${PYTHONPATH}
endif

if ( -d ${HOME}/.local/bin && "${PATH}" !~ *"${HOME}/.local/bin"* ) then
    echo "Adding \${HOME}/.local/bin to path for user specific python installations"
    setenv PATH ${HOME}/.local/bin:${PATH}
else
    echo "${HOME}/.local/bin already in path"
endif

unset called
unset scriptfp
unset scriptdir


