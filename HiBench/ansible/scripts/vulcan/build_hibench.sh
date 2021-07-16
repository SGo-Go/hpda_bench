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
# [[ -z "$SPARK_HOME" ]] && module load bigdata/spark_cluster && init-spark
module load bigdata/spark_cluster; [[ ! -d ~/$SPARK_CONF_DIR ]] && init-spark

export HIBENCH_HOME={{ hibench_prefix }}
# current_dir=`dirname "$0"`
# export HIBENCH_HOME=`cd "${current_dir}/.."; dirname $(pwd)`
export HIBENCH_CONF_DIR=$HIBENCH_HOME/conf

export PATH=$PATH:{{ maven_prefix }}/bin

HADOOP_VERSION=$(hadoop version | grep -e ^Hadoop\\s*\.*\$ | sed -E "s/(^Hadoop\s+)([\.0-9]+).*/\2/")
SPARK_VERSION=$(spark-submit --version 2>&1 | grep -e ^\.*\\s*version\\s*\.*\$ | grep -v Scala | sed -E "s/(^.+version\s+)([\.0-9]+).*/\2/")
SCALA_VERSION=$(spark-submit --version 2>&1 | grep -e ^\.*\\s*version\\s*\.*\$ | grep Scala | sed -E "s/(^.+version\s+)([\.0-9]+).*/\2/")

# # Enable proxying with port forwarding to have access to Internet
# # @TODO: use ~/.m2/settings.xml for this purpose
# http_proxy=http://127.0.0.1:8118
# https_proxy=http://127.0.0.1:8118
# HTTP_PROXY=http://127.0.0.1:8118
# HTTPS_PROXY=http://127.0.0.1:8118

rm -rf $HIBENCH_CONF_DIR/hadoop.conf; cp $HIBENCH_CONF_DIR/templates/hadoop.conf $HIBENCH_CONF_DIR/hadoop.conf
rm -rf $HIBENCH_CONF_DIR/spark.conf; cp $HIBENCH_CONF_DIR/templates/spark.conf $HIBENCH_CONF_DIR/spark.conf

sed    -E "/(^spark\.master\s*)(.*)/d" $SPARK_CONF_DIR/spark-defaults.conf >> $HIBENCH_CONF_DIR/spark.conf

# Compile benchmarks
# @NOTE:
#   - For some reason, setting up Scala version does not work: "-Dscala=$SCALA_VERSION"
#   - Pwebsearch requires Apache Mahout
cd $HIBENCH_HOME && \
    mvn {{ ['-P'] | product(hibench_frameworks | product(['bench']) | map('join') | list) | map('join') | list | join(' ') }} \
	-Dmodules {{ ['-P'] | product(hibench_modules) | map('join') | list | join(' ') }} \
	-Dspark=$SPARK_VERSION -Dspark.version=$SPARK_VERSION clean package
