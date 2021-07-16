#!/bin/bash
ALL_SCALES=${1:-{{ hibench_default_scales | join(' ') }}}
# ALL_NCORES=${2:-576 288 144 72 36}
# NNODES_PREPARE=8
# NUM_REPEATS=1

REPORTS_DIR=~/hibench-report/$PBS_JOBID

# export HIBENCH_HOME={{ hibench_prefix }}
current_dir=`dirname "$0"`
root_dir=`cd "${current_dir}/.."; pwd`

mkdir -p ${REPORTS_DIR}

. ${root_dir}/bin/init_hibench.sh
for TEST_SCALE in ${ALL_SCALES}
do
    CONF_DIR=${root_dir}/conf
    TEST_INPUT_PATH={{ nfs_path }}/${TEST_SCALE}

    # Set up test scale
    sed -i -E "s@(^hibench\.scale\.profile\s*)([a-z]+)@\1${TEST_SCALE}@" $CONF_DIR/hibench.conf
    sed -i -E "s@(^hibench\.hdfs\.master\s*).*@\1 file://${TEST_INPUT_PATH}@" $CONF_DIR/hadoop.conf

    NUM_CORES=all
    # for NUM_CORES in ${ALL_NCORES}
    # do
    # 	sed -i -E "s/(^hibench.yarn.executor.cores\s+)([0-9]+)/\1${NUM_CORES}/" $CONF_DIR/spark.conf
    . ${root_dir}/bin/run.sh
    mv -f ${root_dir}/report/hibench.report ${REPORTS_DIR}/hibench-${TEST_SCALE}-${NUM_CORES}.report
    # done
done
