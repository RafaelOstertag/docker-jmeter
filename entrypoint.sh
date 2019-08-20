#!/bin/bash
# Inspired from https://github.com/hhcordero/docker-jmeter-client
# Basically runs jmeter, assuming the PATH is set to point to JMeter bin-dir (see Dockerfile)
#
# This script expects the standdard JMeter command parameters.
#
set -e
freeMem=`awk '/MemFree/ { print int($2/1024) }' /proc/meminfo`
s=$(($freeMem/10*8))
x=$(($freeMem/10*8))
n=$(($freeMem/10*2))
export JVM_ARGS="-Xmn${n}m -Xms${s}m -Xmx${x}m"

echo "START Running Jmeter on `date`"
echo "JVM_ARGS=${JVM_ARGS}"
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
