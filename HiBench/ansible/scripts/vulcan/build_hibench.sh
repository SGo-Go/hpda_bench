#!/bin/bash
# submit job with: qsub -l select=1:node_type=clx-21:UNS=True,walltime=00:30:00 

module load bigdata/spark_cluster
init-spark

export HIBENCH_HOME={{ hibench_prefix }}

export PATH=$PATH:{{ maven_prefix }}/bin

HADOOP_VERSION=$(hadoop version | grep -e ^Hadoop\\s*\.*\$ | sed -E "s/(^Hadoop\s+)([\.0-9]+).*/\2/")
SPARK_VERSION=$(spark-submit --version 2>&1 | grep -e ^\.*\\s*version\\s*\.*\$ | grep -v Scala | sed -E "s/(^.+version\s+)([\.0-9]+).*/\2/")
SCALA_VERSION=$(spark-submit --version 2>&1 | grep -e ^\.*\\s*version\\s*\.*\$ | grep Scala | sed -E "s/(^.+version\s+)([\.0-9]+).*/\2/")

cd $HIBENCH_HOME && mvn -Dspark=$SPARK_VERSION -Dscala=$SCALA_VERSION -Dspark.version=$SPARK_VERSION clean package
# ./bin/prepare_all.sh
