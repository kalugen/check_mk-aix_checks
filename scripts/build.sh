#!/bin/bash

# Prerequisiti:
# * deve essere lanciato dall'interno di una working directory GIT con un checkout del branch desiderato del progetto
# * sul build server devono trovarsi installati git, ruby e expect (TCL)
# * sul build server deve trovarsi un'installazione CheckMK Enterprise funzionante

# Lo script produce un pacchetto MKP reperibile sotto la working directory nella cartella "archive/"

export SOURCEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
. ${SOURCEDIR}/scripts/lib/pkg_environment.sh

RAW_SUM=$(echo "${NAME}_$(date +%s%6N)" | sha1sum)
BUILD_SITE="BUILD_${RAW_SUM:0:7}"

/usr/bin/omd create ${BUILD_SITE}

find ${SOURCEDIR} -name .placeholder | xargs rm -f

${SOURCEDIR}/scripts/installsite.sh ${BUILD_SITE}
${SOURCEDIR}/scripts/package.sh ${BUILD_SITE}

/usr/bin/expect <<EOD
spawn /usr/bin/omd rm --kill ${BUILD_SITE}
expect {
         "(yes/NO): "                      { send "yes\n"; exp_continue }
         "omd: no such site: ${BUILD_SITE} { exp_continue }
	 eof
}
EOD
