#!/bin/bash

# tiny small large huge gigantic and bigdata.
ALL_SCALES=${1:-tiny small}
# 576 288 144 72 36
ALL_NCORES=${2:-576 288 144 72 36}
NNODES_PREPARE=8
NUM_REPEATS=1
REPORTS_DIR=./report/summary

mkdir -p ${REPORTS_DIR}
for TEST_SCALE in ${ALL_SCALES}
do
    sed -i -E "s/(^hibench.scale.profile\s+)([a-z]+)/\1${TEST_SCALE}/" ./conf/hibench.conf
    ./bin/prepare_all.sh ${NNODES_PREPARE}
    for NUM_CORES in ${ALL_NCORES}
    do
	sed -i -E "s/(^hibench.yarn.executor.cores\s+)([0-9]+)/\1${NUM_CORES}/" ./conf/spark.conf
	./bin/run_frameworks_only.sh ${NUM_REPEATS}
	mv -f ./report/hibench.report ${REPORTS_DIR}/hibench-${TEST_SCALE}-${NUM_CORES}.report
    done
done
