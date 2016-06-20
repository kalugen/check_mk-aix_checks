#!/bin/ksh93

# This plugin returns 4 values:
# - USAGE_PCT is the average processor usage percentage over ${COUNT} seconds
# - USAGE_CORES is the average processor usage in number (fractions) of cores
# - MAX_CORES is the maximum number of physical CPU cores we can use
# - ENT is the entitled capacity, whatever it means depending on LPAR type and mode

# Since the plugin will take 5 seconds to run (by design) it could be a good idea
# configure it as an asynchronous plugin

### POSSIBLE INPUTS FROM DIFFERENT LPAR TYPES AND MODES

### Dedicated, Capped

# LPARSTAT
# System configuration: type=Dedicated mode=Capped smt=4 lcpu=4 mem=4096MB
#
# %user  %sys  %wait  %idle
# ----- ----- ------ ------
#  5.6   5.1    0.5   88.9

# VMSTAT
# System configuration: lcpu=4 mem=4096MB
#
# kthr    memory              page              faults        cpu
# ----- ----------- ------------------------ ------------ -----------
#  r  b   avm   fre  re  pi  po  fr   sr  cy  in   sy  cs us sy id wa
#  0  0 181682 835636   0   0   0   0    0   0   5  271  73  0  0 99  0
#  0  0 181682 835636   0   0   0   0    0   0   0   32  65  0  0 99  0
#  0  0 181682 835636   0   0   0   0    0   0   2   38  73  0  0 99  0
#  0  0 181682 835636   0   0   0   0    0   0   2   33  66  0  0 99  0
#  0  0 181682 835636   0   0   0   0    0   0   0   99  74  0  0 99  0

### Dedicated, Donating

# LPARSTAT
# System configuration: type=Dedicated mode=Donating smt=4 lcpu=4 mem=4096MB
#
# %user  %sys  %wait  %idle physc  vcsw
# ----- ----- ------ ------ ----- -----
#   8.6   7.6    1.2   82.5  0.00 56065

# VMSTAT
# System configuration: lcpu=4 mem=4096MB
#
# kthr    memory              page              faults        cpu
# ----- ----------- ------------------------ ------------ -----------
#  r  b   avm   fre  re  pi  po  fr   sr  cy  in   sy  cs us sy id wa
#  0  0 181682 835636   0   0   0   0    0   0   5  271  73  0  0 99  0
#  0  0 181682 835636   0   0   0   0    0   0   0   32  65  0  0 99  0
#  0  0 181682 835636   0   0   0   0    0   0   2   38  73  0  0 99  0
#  0  0 181682 835636   0   0   0   0    0   0   2   33  66  0  0 99  0
#  0  0 181682 835636   0   0   0   0    0   0   0   99  74  0  0 99  0

### Shared, Capped

# LPARSTAT
# System configuration: type=Shared mode=Capped smt=4 lcpu=8 mem=18432MB psize=16 ent=0.70
#
# %user  %sys  %wait  %idle physc %entc  lbusy  vcsw phint
# ----- ----- ------ ------ ----- ----- ------ ----- -----
#   5.3  10.5    0.0   84.2  0.17  24.3    6.0 6133902387 210796057

# VMSTAT
# System configuration: lcpu=8 mem=18432MB ent=0.70
#
# kthr    memory              page              faults              cpu
# ----- ----------- ------------------------ ------------ -----------------------
#  r  b   avm   fre  re  pi  po  fr   sr  cy  in   sy  cs us sy id wa    pc    ec
#  5  0 3292699 1345521   0   0   0   0    0   0  45 3743 3154  2  3 95  0  0.06   8.3
#  2  0 3292699 1345521   0   0   0   0    0   0  11 3034 3165  2  3 96  0  0.05   7.6
#  8  0 3292699 1345521   0   0   0   0    0   0   8 4089 2989  2  4 94  0  0.07  10.2
#  0  0 3292699 1345521   0   0   0   0    0   0  26 3048 3049  1 13 86  0  0.15  21.4
#  1  0 3292699 1345521   0   0   0   0    0   0  17 3139 3254  1  3 96  0  0.05   7.2

### Shared, Uncapped

# LPARSTAT
# System configuration: type=Shared mode=Uncapped smt=4 lcpu=4 mem=16383MB psize=16 ent=0.20
#
# %user  %sys  %wait  %idle physc %entc  lbusy  vcsw phint
# ----- ----- ------ ------ ----- ----- ------ ----- -----
#   3.6   4.3    0.0   92.1  0.03  14.0    0.9 1684423289 38026251

# VMSTAT
# System configuration: lcpu=4 mem=16383MB ent=0.20
#
# kthr    memory              page              faults              cpu
# ----- ----------- ------------------------ ------------ -----------------------
#  r  b   avm   fre  re  pi  po  fr   sr  cy  in   sy  cs us sy id wa    pc    ec
#  1  0 2779769 624669   0   0   0   0    0   0  17 1287 1486  2  4 93  0  0.03  14.1
#  1  0 2779769 624669   0   0   0   0    0   0  11 1049 1497  2  4 94  0  0.03  13.4
#  1  0 2779769 624669   0   0   0   0    0   0  25 1047 1534  3  5 93  0  0.03  15.8
#  1  0 2779769 624669   0   0   0   0    0   0  22 1100 1530  3  7 90  0  0.04  19.6
#  1  0 2779769 624669   0   0   0   0    0   0  10 1602 1302  3  6 91  0  0.04  17.8

echo "<<<aix_lpar_cpu:sep(59)>>>"

# How many seconds we collect data with vmstat to get an average of the CPU usage
COUNT=5

# Initialize variable to avoid error in unforseen conditions
USAGE_PCT="0.0"
USAGE_CORES="0.0"
MAX_CORES="0.0"
ENT="0.0"

# Shortcut function
function _vmstat {
  vmstat 1 ${1} | tail -n ${1}
}

# My version of "mktemp" for ksh, pseudo random using md5sum of time and RANDOM
# from the shell. Not cryptographically secure, just good enough for the task.
function _mktemp {
  typeset var TMPFILE="/tmp/$$.$(echo "${RANDOM}$(date +%y%m%d%H%M%S)" | \
    md5sum | cut -f1 -d' ').aix_lpar_cpu.cmk"

  # Avoids overwriting any existing files: returns only if the new file does
  # not exists. Creates an empty file before exiting.
  if [ ! -e ${TMPFILE} ]; then
    touch ${TMPFILE}
    echo ${TMPFILE}
  else
    # if we hit an already existing file, avoids overwriting 
    # and try again by recursing
    _mktemp
  fi
}

# We need to use a file as input to the while loop because if we used
# "lparstat | while" the loop would be running in a separate shell meaning that
# every variable defined or changed inside the loop would be lost after the loop
# ends. This is a well-known POSIX shells issue.

# Also, Aix generally don't has the "mktemp" command, so we use our custom
# implementation. See above.
TMPFILE=$(_mktemp)

# Capture the raw output of lparstat in our temporary file. Ksh 9.3 does not
# support BASH's syntax of pseudo-file redirection "< <(command)"
lparstat | grep "System configuration" | \
    awk -F':' '{print $NF}' | perl -pe 's/ /\n/g'> ${TMPFILE} 2>&1

##########################
# LPARSTAT HEADER PARSER #
##########################
# Creates constants from lparstat output (see above)
# TYPE, MODE, LCPU, SMT e MEM will be always created 
# PSIZE and ENT will be created only for LPAR in "Shared" mode
while IFS='=' read VAR VAL; do
  if [ ${VAL} ]; then
    VAR=$(echo ${VAR}|tr "[:lower:]" "[:upper:]")
    typeset -r "${VAR}=${VAL}"
  fi;
done < ${TMPFILE}

case "${TYPE}" in
  "Dedicated") # In a "dedicated" LPAR a number of physical CPUs are statically assigned
    case "${MODE}" in

      "Capped"|"Donating")
        # lparstat do not show the number of CPUs but it is easy to calculate it from
        # the number of logical CPUs (lcpu) and the processor threads (smt)
        MAX_CORES=$(( LCPU/SMT ))

        # Manually sets ENT for perfdata sake
        ENT=${MAX_CORES}

        # We get our average cpu % from the "idle" (id) column of vmstat, so that
        # real usage = 100-idle.
        USAGE_PCT=$(_vmstat ${COUNT} | \
              awk '{ SUM+=$(NF-1) } END { print 100.0-(SUM/NR) }')

        # and the number of USAGE_PCT used cores is
        USAGE_CORES=$( echo "scale=2;${USAGE_PCT}*${MAX_CORES}/100" | bc );;

      *) # Unsupported mode
        echo "0.0;0.0;0.0"
        exit 255;;

    esac;;

  "Shared") # In a "shared" LPAR, resources are drawn from a shared pool
    case "${MODE}" in

      "Uncapped") 
	# Entitlement here means "minimum guaranteed cores".

	# Note: at this point ENT has already been set by the lparstat output parser

        # In a way similar to "dedicated" LPARs, here the maximum number of usable
        # cores is limited by the number of configured logical processors and
        # processors threading technology.
        MAX_CORES=$(( LCPU/SMT ))

        # Here average core num usage is collected directly from the "pc" column of vmstat
        USAGE_CORES=$(_vmstat ${COUNT} | \
              awk -v '{ SUM+=$(NF-1) } END { print (SUM/NR) }')

	# CPU usage % is the average of (pc/max cores) * 100
        USAGE_PCT=$( echo "scale=2;${USAGE_CORES}*(100/${MAX_CORES})" | bc );;

      "Capped") 
	# Entitlement here is "maximum usable cores"

	# Note: at this point ENT has already been set by the lparstat output parser

        # MAX_CORES here is the same as the entitled capacity
        MAX_CORES=${ENT}

        # "ec" column in vmstat gives us directly the percentage of entitled capacity used
        USAGE_PCT=$(_vmstat ${COUNT} | \
              awk '{SUM+=$(NF)} END {print SUM/NR}')

        # CPU cores usage is the average of "ec" * entitled capacity/100
        USAGE_CORES=$( echo "scale=2;${USAGE_PCT}*${ENT}/100.00" | bc );;

      *) 
	# Unsupported mode
        echo "0.0;0.0;0.0"
        exit 255;;

    esac;;

  *) 
    # Unsupported LPAR type
    echo "0.0;0.0;0.0"
    exit 255;;
esac

# Stampa l'output in formato float "0.00"
echo "$(printf "%.2f;%.2f;%.2f;%.2f\n" ${USAGE_PCT} ${USAGE_CORES} ${MAX_CORES} ${ENT})"

rm ${TMPFILE}
