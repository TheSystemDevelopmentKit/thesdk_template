#!/bin/env bash
# This is a script that compiles the shell documentation at build-time

detect_rstdoc()
{
    directory=$1
    for file in ${directory}/*.sh; do
        if [ -f $file ]; then
            if [ ! -z "$("${THISDIR}/bash2rst.sh" "${file}")" ]; then
                echo "1"
                return
            fi
        fi
    done
    echo "0"
}

# This script is to be run in 'doc' directory
THISDIR="$(readlink -f $(dirname $0))"
DOCDIR="$(dirname ${THISDIR})"
PROJDIR="$(dirname ${DOCDIR})"

# These are given relative to ${PROJDIR}
# These are hardcoded in order to control the order.
# Alternatively these could be found from ${PROJDIR} with find
SHELLSCRIPT_DIRS="\
    thesdk_helpers/shell \
    doc/shell \
    CI-helpers \
    "


if [ ! -z "${SHELLSCRIPT_DIRS}" ]; then
cat <<- EOF > "${DOCDIR}/source/shell_scripts.rst"
Shell scripts
=============
Many shell scripts have been written to automate repetitive tasks of design and project administration. Below you find the description and
'help'-sections of the scripts in alphabetical order. The information is
automatically generated at the build time of the documentation from the
information provided in the scripts, so if you see something missing, please
help us to improve.

EOF
    #Generating contents
    for dir in ${SHELLSCRIPT_DIRS}; do
        if [ ! -d "${PROJDIR}/${dir}" ]; then 
            echo "Directory $dir does not exist, check your script" &&  exit 1
        fi
        # We will generate somthing only if there is something to document
        if [ "$(detect_rstdoc ${PROJDIR}/${dir})" == "1" ]; then
            # We may generate header underlinings with this information
            CHARS=$(echo $dir | wc -c )
            for ((i=1; i<$CHARS; i++)); do echo -n '=' >> "${DOCDIR}/source/shell_scripts.rst"; done
            echo -e "\n${dir}" >> "${DOCDIR}/source/shell_scripts.rst"
            for ((i=1; i<$CHARS; i++)); do echo -n '=' >> "${DOCDIR}/source/shell_scripts.rst"; done
            echo "" >> "${DOCDIR}/source/shell_scripts.rst"
            # Note that <<- requires that heredoc is intended with TABS 
            cat <<- EOF >> "${DOCDIR}/source/shell_scripts.rst"
			.. toctree::
			    :maxdepth: 1
			
			EOF
            TARGET="${DOCDIR}/source/generated/$dir"
            rm -rf "${TARGET}" && mkdir -p "${TARGET}" || exit 1
            for file in ${PROJDIR}/$dir/*.sh; do
                RSTFILE="$(basename -s .sh ${file}).rst"
                # Avoid generating empty files
                if [ ! -z "$("${THISDIR}/bash2rst.sh" "${file}")" ]; then
                    echo -e "    generated/${dir}/$(basename -s .sh ${file})\n" >> "${DOCDIR}/source/shell_scripts.rst" 
                    ${THISDIR}/bash2rst.sh "${file}" > "${TARGET}/${RSTFILE}"
                fi
            done
        fi
    done
fi

exit 0
