#!/bin/bash

# Esclude eventuali placeholders rimasti in giro
FIND_HERE="find . ! -name .placeholder"

# Project Name - handles Jenkins workspace paths
if [ $(basename $SOURCEDIR) == "workspace" ]; then
  export NAME=$(basename $(dirname ${SOURCEDIR}) |  sed 's/check_mk-//g')
else
  export NAME=$( echo $(basename ${SOURCEDIR}) | sed 's/check_mk-//g' )
fi

# Gets the version from Git tags or just uses date-time
if [[ $(git status 2>/dev/null) ]]; then
  VERSION=$(git describe --tags | sed 's/-/./g')
else
  VERSION="v99.$(date +'%Y%m%d.%H%M%S')"
fi
export VERSION

# Gets the package title and description from the title inside the check man page, if present
MANFILE=${SOURCEDIR}/docs/${NAME}
if [ -f ${MANFILE} ]; then
  TITLE="$(grep title ${MANFILE}  | awk -F': ' '{print $NF}')"
  DESCRIPTION="$(cat ${MANFILE} | perl -e 'while (<>) { print if /^description:\s+$/i .. /^item:\s+$/ }' | grep -v ':')"
else # or uses the project's NAME
  TITLE=${NAME}
  DESCRIPTION=${NAME}
fi
export TITLE DESCRIPTION

# Package Descriptor Variables
export AUTHOR="MIS Monitoring Desk"
export CMK_MIN_VERSION="1.2.6p1"

# Determine which version of CMK is available
export CMK_PKG_VERSION="1.2.6p12"

export DESCRIPTION="Package Descr"
export URL="http://mxplgitas01.mbdom.mbgroup.ad/Monitoring/check_mk-${NAME}"

# Now populate files arrays: this is needed for custom package descriptors
if [ -d  ${SOURCEDIR}/agents ]; then
  pushd ${SOURCEDIR}/agents > /dev/null
  export AGENTS=$(${FIND_HERE} -type f|xargs|sed 's/ /,/g; s/\.\///g')
  popd > /dev/null
fi

if [ -d  ${SOURCEDIR}/docs ]; then
  pushd ${SOURCEDIR}/docs > /dev/null
  export CHECKMAN=$(${FIND_HERE} -type f|xargs|sed 's/ /,/g;s/\.\///g')
  popd > /dev/null
fi

if [ -d  ${SOURCEDIR}/otherdocs ]; then
  pushd ${SOURCEDIR}/otherdocs > /dev/null
  export DOC=$( ${FIND_HERE} -type f | while read DOC; do echo "${NAME}/$(basename ${DOC})"; done | xargs | sed 's/ /,/g;s/\.\///g'  )
  popd > /dev/null
fi

if [ -d  ${SOURCEDIR}/checks ]; then
  pushd ${SOURCEDIR}/checks > /dev/null
  export CHECKS=$(${FIND_HERE} -type f|xargs|sed 's/ /,/g;s/\.\///g')
  popd > /dev/null
fi

if [ -d  ${SOURCEDIR}/templates ]; then
  pushd ${SOURCEDIR}/templates > /dev/null
  export PNP_TEMPLATES=$(${FIND_HERE} -type f|xargs|sed 's/ /,/g;s/\.\///g')
  popd > /dev/null
fi

if [ -d  ${SOURCEDIR}/notifications ]; then
  pushd ${SOURCEDIR}/notifications > /dev/null
  export NOTIFICATIONS=$(${FIND_HERE} -type f|xargs|sed 's/ /,/g;s/\.\///g')
  popd > /dev/null
fi

if [ -d  ${SOURCEDIR}/web ]; then
  pushd ${SOURCEDIR}/web > /dev/null
  STD_DIRS='config|dashboard|icons|pages|perfometer|sidebar|views|visuals|wato'
  WEB=$( echo $(${FIND_HERE} -type f | grep -E ${STD_DIRS}) | xargs | sed 's/ /,/g;s/\.\///g')
  export WEB
  popd > /dev/null
fi
