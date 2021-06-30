#!/bin/bash
############################################################
## @file
## @copyright (C) 2021 HLRS
##    All rights reserved.
##
## Use, modification, and distribution is subject to the license.
##
## @author Sergiy Gogolenko <gogolenko@hlrs.de>
##
############################################################
# submit job with: qsub -l select=1:node_type=clx-21:UNS=True,walltime=00:30:00 

[[ -z "$SPARK_HOME" ]] && module load bigdata/spark_cluster && init-spark

export HIBENCH_HOME={{ hibench_prefix }}
export HADOOP_HOME=$HADOOP_PREFIX
# export SPARK_HOME=$SPARK_HOME

export SPARK_CONF_DIR=~/bigdata/$PBS_JOBID/spark-conf
SPARK_MASTER=$(cat $SPARK_CONF_DIR/spark-defaults.conf | grep spark.master | sed -E "s/(^spark.master\s+)(\w+)/\2/") \
    && SPARK_SLAVES=$(cat $SPARK_CONF_DIR/slaves | sed 'N;s/\n/,/') \
    && SPARK_NUM_SLAVES=$(cat $SPARK_CONF_DIR/slaves | wc -l) \
    && echo "master: $SPARK_MASTER. $SPARK_NUM_SLAVES slaves: $SPARK_SLAVES"

sed -i -E "s@(^hibench\.masters\.hostnames\s*)(.*)@\1 ${SPARK_MASTER}@" $HIBENCH_HOME/conf/hibench.conf
sed -i -E "s@(^hibench\.slaves\.hostnames\s*)(.*)@\1 ${SPARK_SLAVES}@" $HIBENCH_HOME/conf/hibench.conf

sed -i -E "s@(^hibench\.hadoop\.home\s*)(.*)@\1 ${HADOOP_HOME}@" $HIBENCH_HOME/conf/hadoop.conf

sed -i -E "s@(^hibench.spark.home\s*)(.*)@\1 ${SPARK_HOME}@" $HIBENCH_HOME/conf/spark.conf
sed -i -E "s@(^hibench.yarn.executor.num\s*)(.*)@\1 ${SPARK_NUM_SLAVES}@" $HIBENCH_HOME/conf/spark.conf
# Set up Spark master for standalone mode
#   for YARN mode use: yarn-client
sed -i -E "s@(^hibench.spark.master\s*)(.*)@\1 ${SPARK_MASTER}@" $HIBENCH_HOME/conf/spark.conf
# Copy extra Spark configs to ensure security (valid for Vulcan)
# TODO: make this workaround more generic
sed    -E "/(^spark\.master\s*)(.*)/d" $SPARK_CONF_DIR/spark-defaults.conf >> $HIBENCH_HOME/conf/spark.conf


SPARK_CHECKPOINTIING_DIR=$(cat $HIBENCH_HOME/conf/spark.conf | grep hibench.streambench.spark.checkpointPath | \
			       sed -E "s/(^hibench.streambench.spark.checkpointPath\s+)(.+)/\2/")
mkdir -p $SPARK_CHECKPOINTIING_DIR
