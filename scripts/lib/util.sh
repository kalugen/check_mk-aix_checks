#!/bin/bash

# Setup the work parameters
export OMDBASE="/omd/sites"

# Checks if the site name was passed
if [[ ${1} == "" ]]; then
  echo "Indicare il site!"
  exit 255
else
  export SITE=${1}
fi

# Dry-run option
if [[ ${2} == "-n" ]]; then
  export DRYRUN=1
else
  export DRYRUN=0
fi

# Assume that $SITE is also the user and group name
# as is the standard for OMD.
# TODO: figure out how to actually determine these values from OMD config
export SITEUSER=${SITE}
export SITEGROUP=${SITE}

export MANDIR="${LOCALSHARE}/check_mk/checkman"
export DOCSDIR="${LOCALSHARE}/check_mk/docs"
export CHECKDIR="${LOCALSHARE}/check_mk/checks"
export TEMPLDIR="${LOCALSHARE}/check_mk/pnp-templates"
export AGENTSDIR="${LOCALSHARE}/check_mk/agents"
export LOCALSHARE="${OMDBASE}/${SITE}/local/share"
export WEBPLUGINSDIR="${LOCALSHARE}/check_mk/web/plugins"
export NOTIFICATIONSDIR="${LOCALSHARE}/check_mk/notifications"
