#!/bin/bash

export SOURCEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )

SITE_BLACKLIST="pippo"

# Determina l'ultimo pacchetto disponibile (per versione). Il '-v' di 'ls' è cruciale!
PACKAGE=$(ls -1v ${SOURCEDIR}/packages/*.mkp | tail -n1)

/usr/bin/omd  sites | grep -v SITE | awk '{print $1}' | grep -vE "${SITE_BLACKLIST}" | while read SITE; do
    SITE_PATH="/omd/sites/${SITE}"

    # Install the appropriate files in the correct positions inside the site
    cp ${PACKAGE} ${SITE_PATH}/tmp
    su - ${SITE} -c "cmk -P -v install ${SITE_PATH}/tmp/$(basename ${PACKAGE})"
    rm ${SITE_PATH}/tmp/*.mkp

    . ${SOURCEDIR}/scripts/lib/util.sh ${SITE}

    # Fix the permissions, since we are running as root
    chown ${SITEUSER}:${SITEGROUP} -R ${LOCALSHARE}

    # Stop apache and mod_python
    omd stop ${SITE} apache

    # Clear any hanging SysV IPC semaphores while apache is down
    ipcs -s | grep ${USER} | cut -f2 -d' ' | while read SEMID; do
      ipcrm -s ${SEMID}
    done

    # Start apache and mod_python
    omd start ${SITE} apache

done
