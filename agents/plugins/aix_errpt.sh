#!/bin/sh

# Nota: DEVE GIRARE COME ROOT

DATECMD=/opt/freeware/bin/date

# Timestamp di ADESSO - 24h
PREVDATE=$( ${DATECMD} -d '-1 days' '+%m%d%H%M%y' )

# Hardware e Software errors
HW_ERRORS=$( errpt -d 'H'   -D -s ${PREVDATE} -T 'PERM' | grep -v 'RESOURCE_NAME' )
SW_ERRORS=$( errpt -d 'S,O' -D -s ${PREVDATE}           | grep -v 'RESOURCE_NAME' )

# Output
echo '<<<aix_errpt:sep(58)>>>'
echo "HW:${HW_ERRORS};"
echo "SW:${SW_ERRORS};"
