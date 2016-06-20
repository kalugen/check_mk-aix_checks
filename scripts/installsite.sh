#!/bin/bash

. ${SOURCEDIR}/scripts/lib/util.sh

# Start
echo "${NAME} ${VERSION} installation script"

DRYRUN=0

# If we're not in dry-run mode, copy the files to their destinations
if [ ${DRYRUN} -eq 0 ]; then

    # The checks
    cp -v ${SOURCEDIR}/checks/*                 ${CHECKDIR}/                  

    # The checks manpages
    cp -v ${SOURCEDIR}/docs/*                   ${MANDIR}/

    # PNP4Nagios templates
    cp -v ${SOURCEDIR}/templates/*              ${TEMPLDIR}/

    # WATO plugins
    for PLUGINTYPE in ${SOURCEDIR}/web/plugins/*; do
      cp -v ${PLUGINTYPE}/* ${WEBPLUGINSDIR}/$(basename ${PLUGINTYPE})
    done

    # Agent files
    cp -v ${SOURCEDIR}/agents/plugins/*         ${AGENTSDIR}/plugins
    cp -v ${SOURCEDIR}/agents/*                 ${AGENTSDIR}/

    # Deploy the package info, making cmk package management aware of our modifications
    # NOTE: this depends on the exported variables above

    # Determine the running version of CheckMK
    export CMK_PKG_VERSION=$(su - ${SITE} -c "cmk --version" | grep "check_mk version" | awk '{print $NF}')

    ${SOURCEDIR}/scripts/create_package_descriptor.sh
    cp ${SOURCEDIR}/.cmkpackage.json ${OMDBASE}/${SITE}/var/check_mk/packages/${NAME}

else
    # If we are in dry-run mode, just display the package descriptor without writing anythng anywhere
    cat ${SOURCEDIR}/.cmkpackage.json
fi


exit 0
