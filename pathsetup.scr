#set paths for matlab
setenv PATH ${PATH}:/tools/mathworks/matlabR2016a/bin
setenv MGC_AMS_HOME /tools/mentor/modelsim/modelsim10.5c/
setenv MODEL_TECH  /tools/mentor/modelsim/modelsim10.5c/modeltech/linux_x86_64
setenv PATH ${PATH}:/tools/mentor/modelsim/modelsim10.5c/modeltech/bin
setenv PATH ${PATH}:$MODEL_TECH/bin
setenv PATH ${PATH}:$MGC_AMS_HOME/modeltech/bin

#     
#     Sets the C shell user environment for texlive commands
#
set path =  (/tools/commercial/texlive/2015/bin/x86_64-linux/ $path)

if ( ${?MANPATH} ) then
  setenv MANPATH ${MANPATH}:/tools/comercial/texlive/2015/texmf-dist/doc/man
else
  setenv MANPATH :/tools/commercial/texlive/2015/texmf-dist/doc/man
endif


#Set paths for licences and lsf
source /tools/flexlm/flexlm.cshrc
source /tools/support/lsf/conf/cshrc.lsf

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


