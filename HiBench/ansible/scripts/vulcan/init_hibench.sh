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

export SPARK_CONF_DIR=~/bigdata/$PBS_JOBID/spark-conf
module load bigdata/spark_cluster; [[ ! -d ~/$SPARK_CONF_DIR ]] && init-spark

export HADOOP_HOME=$HADOOP_PREFIX
# export SPARK_HOME=$SPARK_HOME

export HIBENCH_HOME={{ hibench_prefix }}
export HIBENCH_CONF_DIR=$HIBENCH_HOME/conf

SPARK_MASTER=$(cat $SPARK_CONF_DIR/spark-defaults.conf | grep spark.master | sed -E "s/(^spark.master\s+)(\w+)/\2/") \
    && SPARK_SLAVES=$(cat $SPARK_CONF_DIR/slaves | sed 'N;s/\n/,/') \
    && SPARK_NUM_SLAVES=$(cat $SPARK_CONF_DIR/slaves | wc -l) \
    && echo "master: $SPARK_MASTER. $SPARK_NUM_SLAVES slaves: $SPARK_SLAVES"

# Set config files to defaults
rm -rf $HIBENCH_CONF_DIR/hadoop.conf; cp $HIBENCH_CONF_DIR/templates/hadoop.conf $HIBENCH_CONF_DIR/hadoop.conf
rm -rf $HIBENCH_CONF_DIR/spark.conf; cp $HIBENCH_CONF_DIR/templates/spark.conf $HIBENCH_CONF_DIR/spark.conf

# Patch config files with job-specific data
sed -i -E "s@(^hibench\.masters\.hostnames\s*)(.*)@\1 ${SPARK_MASTER}@" $HIBENCH_CONF_DIR/hibench.conf
sed -i -E "s@(^hibench\.slaves\.hostnames\s*)(.*)@\1 ${SPARK_SLAVES}@" $HIBENCH_CONF_DIR/hibench.conf

sed -i -E "s@(^hibench\.hadoop\.home\s*)(.*)@\1 ${HADOOP_HOME}@" $HIBENCH_CONF_DIR/hadoop.conf

sed -i -E "s@(^hibench.spark.home\s*)(.*)@\1 ${SPARK_HOME}@" $HIBENCH_CONF_DIR/spark.conf
sed -i -E "s@(^hibench.yarn.executor.num\s*)(.*)@\1 ${SPARK_NUM_SLAVES}@" $HIBENCH_CONF_DIR/spark.conf
# Set up Spark master for standalone mode
#   for YARN mode use: yarn-client
sed -i -E "s@(^hibench.spark.master\s*)(.*)@\1 ${SPARK_MASTER}@" $HIBENCH_CONF_DIR/spark.conf
# Copy extra Spark configs to ensure security (valid for Vulcan)
sed    -E "/(^spark\.master\s*)(.*)/d" $SPARK_CONF_DIR/spark-defaults.conf >> $HIBENCH_CONF_DIR/spark.conf

# Create checkpointing folder
SPARK_CHECKPOINTING_DIR=$(cat $HIBENCH_CONF_DIR/spark.conf | grep hibench.streambench.spark.checkpointPath | \
			      sed -E "s/(^hibench.streambench.spark.checkpointPath\s+)(.+)/\2/")
mkdir -p $SPARK_CHECKPOINTING_DIR
