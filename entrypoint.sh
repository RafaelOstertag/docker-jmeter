#!/bin/bash
#
# This script expects the standdard JMeter command parameters.
#
set -e

echo "START Running Jmeter on `date`"
echo "JVM_ARGS=${JVM_ARGS:-(none)}"
echo "jmeter args=$@"

if [ -z "${OUTPUTDIR}" ]
then
    echo "Please set \$OUTPUTDIR" 1>&2
    exit 1
fi

if [ -z "${TESTPLAN}" ]
then
    echo "Please set \$TESTPLAN to a test plan file" 1>&2
    exit 2
fi

if ! [ -f "${TESTPLAN}" ]
then
    echo "Test plan $TESTPLAN does not exist" 1>&2
    exit 3
fi

per_instance_output="${OUTPUTDIR}/${HOSTNAME}"


jmeter -n -t "${TESTPLAN}" -l "${per_instance_output}/results.csv" -j "${per_instance_output}/log" -e -o "${per_instance_output}/report"
echo "END Running Jmeter on `date`"
