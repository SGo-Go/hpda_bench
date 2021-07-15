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
# current_dir=`dirname "$0"`
# export HIBENCH_HOME=`cd "${current_dir}/.."; dirname $(pwd)`
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

# Compile benchmarks
# @NOTE:
#   - For some reason, setting up Scala version does not work: "-Dscala=$SCALA_VERSION"
#   - Pwebsearch requires Apache Mahout
cd $HIBENCH_HOME && \
    mvn {{ ['-P'] | product(hibench_frameworks | product(['bench']) | map('join') | list) | map('join') | list | join(' ') }} \
	-Dmodules {{ ['-P'] | product(hibench_modules) | map('join') | list | join(' ') }} \
	-Dspark=$SPARK_VERSION -Dspark.version=$SPARK_VERSION clean package
