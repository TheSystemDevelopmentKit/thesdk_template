#set paths for matlab
use advms_17.1
#     
#Set module thesdk to PYTHONPATH
set called=($_)
set scriptfp=`readlink -f $called[2]`
set scriptdir=`dirname $scriptfp`

if ( ! $?PYTHONPATH ) then
    setenv PYTHONPATH $scriptdir/Entities/thesdk
else
    setenv PYTHONPATH ${PYTHONPATH}:$scriptdir/Entities/thesdk
endif

unset called
unset scriptfp
unset scriptdir


