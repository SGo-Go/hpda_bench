#!/bin/bash

# tiny small large huge gigantic and bigdata.
ALL_SCALES=${1:-{{ hibench_default_scales | join(' ') }}}

# export HIBENCH_HOME={{ hibench_prefix }}
current_dir=`dirname "$0"`
root_dir=`cd "${current_dir}/.."; pwd`

. ${root_dir}/bin/init_hibench.sh
for TEST_SCALE in ${ALL_SCALES}
do
    TEST_INPUT_PATH={{ nfs_path }}/${TEST_SCALE}
    CONF_DIR=${root_dir}/conf
    mkdir -p ${TEST_INPUT_PATH}
    sed -i -E "s@(^hibench\.hdfs\.master\s+).*@\1 file://${TEST_INPUT_PATH}@" $CONF_DIR/hadoop.conf
    sed -i -E "s@(^hibench\.scale\.profile\s*)([a-z]+)@\1${TEST_SCALE}@" $CONF_DIR/hibench.conf
    . ${root_dir}/bin/prepare.sh
done
