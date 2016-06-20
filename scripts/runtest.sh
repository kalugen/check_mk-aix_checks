#!/bin/bash

SOURCEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
PACKAGENAME=$(basename ${SOURCEDIR} | sed 's/check_mk-\(.\{1,10\}\).*/\1/')
OMDLOG=$(mktemp /tmp/cmk_test_omd.log.XXXXXXXX)
TESTLOG=$(mktemp /tmp/cmk_test_run.log.XXXXXXXX)

function setup {
   TESTSITE=$1

   # Create the site if necessary
   omd sites | grep ${TESTSITE} > /dev/null || {
       omd create ${TESTSITE}
   }

   # Start the site if necessary
   omd status ${TESTSITE} > /dev/null || {   
     omd start ${TESTSITE} || (echo "Impossibile avviare sito di test: ${TESTSITE}. Alcuni test potrebbero fallire."; exit 255;)
   }

   # Install our files in the Test Site
   ${SOURCEDIR}/scripts/install.sh ${TESTSITE}
}

function teardown {
   TESTSITE=$1

   # OMD rm expects the user to answer a question. After removing the test site, no further 
   # removals and cleanup are necessary. The expect script ignores errors from omd and continues 
   /usr/bin/expect <<EOD
       spawn /usr/bin/omd rm --kill ${TESTSITE}
       expect {
		"(yes/NO): "                    { send "yes\n"; exp_continue }
                "omd: no such site: ${TESTSITE} { exp_continue }
       }
       expect eof
EOD
}

if [[ "${1}" == "-c" ]]; then
  CLEANUP=1
else 
  CLEANUP=0
fi

for TESTRUN in ${SORUCEDIR}/test/test_*.sh; do
   export TESTID=$(printf "%05d" $( shuf -i 00000-99999 -n1 ))
   export TESTSITE="${PACKAGENAME}_${TESTID}"
 
   setup ${TESTSITE} >> ${OMDLOG} 2>&1

   exec ${TESTRUN} ${TESTSITE} | tee -a ${TESTLOG}

   teardown ${TESTSITE} >> ${OMDLOG} 2>&1
done  


if [[ ${CLEANUP} -eq 1 ]]; then
  rm -f ${OMDLOG}
  rm -f ${TESTLOG}
fi

exit 0
