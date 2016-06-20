#!/bin/bash

. ${SOURCEDIR}/scripts/lib/util.sh
. ${SOURCEDIR}/scripts/lib/pkg_environment.sh

mkdir -p ${SOURCEDIR}/packages/

su - ${SITE} -c "cmk -P pack ${NAME}"

mv ${OMDBASE}/${SITE}/${NAME}-*.mkp ${SOURCEDIR}/packages/
