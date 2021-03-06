#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -u

NO_REPEAT=${1:-1}

current_dir=`dirname "$0"`
root_dir=`cd "${current_dir}/.."; pwd`

# module load tools/mesos

. ${root_dir}/bin/functions/color.sh

# echo -e "${BGreen}start resource allocation...${Color_Off}"
# echo -e "${BCyan}Flex up YARN: ${Cyan}urika-yam-flexup --nodes ${URIKA_YARN_NODES} --identifier hibench-prepare --timeout 720${Color_Off}"
# urika-yam-flexup --nodes ${URIKA_YARN_NODES} --identifier hibench-prepare --timeout 720
# echo -e "${UGreen}${BGreen}allocated resources${Color_Off}"

# function exit_with_cleanup(){ # exit script and release URIKA nodes
#     echo -e "${UGreen}${BGreen}flex down YARN${Color_Off}"
#     urika-yam-flexdown --identifier hibench-prepare
#     exit $1
# }

for benchmark in `cat $root_dir/conf/benchmarks.lst`; do
    if [[ $benchmark == \#* ]]; then
        continue
    fi

    echo -e "${UYellow}${BYellow}Prepare ${Yellow}${UYellow}${benchmark} ${BYellow}...${Color_Off}"
    benchmark="${benchmark/.//}"

    WORKLOAD=$root_dir/bin/workloads/${benchmark}
    # echo -e "${BCyan}Exec script: ${Cyan}${WORKLOAD}/prepare/prepare.sh${Color_Off}"
    # "${WORKLOAD}/prepare/prepare.sh"

    # result=$?
    # if [ $result -ne 0 ]
    # then
    # 	echo "ERROR: ${benchmark} prepare failed!"
    #     exit_with_cleanup $result
    # fi

    for no_repeat in $(seq 1 $NO_REPEAT); do
	    for framework in `cat $root_dir/conf/frameworks.lst`; do
  		if [[ $framework == \#* ]]; then
  		    continue
  		fi

  		if [ $benchmark == "micro/dfsioe" ] && [ $framework == "spark" ]; then
  		    continue
  		fi
  		if [ $benchmark == "websearch/nutchindexing" ] && [ $framework == "spark" ]; then
  		    continue
  		fi
  		if [ $benchmark == "graph/nweight" ] && [ $framework == "hadoop" ]; then
  		    continue
  		fi
  		if [ $benchmark == "ml/lr" ] && [ $framework == "hadoop" ]; then
  		    continue
  		fi
  		if [ $benchmark == "ml/als" ] && [ $framework == "hadoop" ]; then
  		    continue
  		fi
  		if [ $benchmark == "ml/svm" ] && [ $framework == "hadoop" ]; then
  		    continue
  		fi
		if [ $benchmark == "ml/pca" ] && [ $framework == "hadoop" ]; then
		    continue
		fi
		if [ $benchmark == "ml/gbt" ] && [ $framework == "hadoop" ]; then
		    continue
		fi
		if [ $benchmark == "ml/rf" ] && [ $framework == "hadoop" ]; then
		    continue
		fi  
		if [ $benchmark == "ml/svd" ] && [ $framework == "hadoop" ]; then
		    continue
		fi      
		if [ $benchmark == "ml/linear" ] && [ $framework == "hadoop" ]; then
		    continue
		fi
		if [ $benchmark == "ml/lda" ] && [ $framework == "hadoop" ]; then
		    continue
		fi

  		echo -e "${UYellow}${BYellow}Run ${Yellow}${UYellow}${benchmark}/${framework}${Color_Off}"
  		echo -e "${BCyan}Exec script: ${Cyan}$WORKLOAD/${framework}/run.sh${Color_Off}"
  		$WORKLOAD/${framework}/run.sh

  		result=$?
  		if [ $result -ne 0 ]
  		then
  		    echo -e "${On_IRed}ERROR: ${benchmark}/${framework} failed to run successfully.${Color_Off}"
		    exit $result
  		fi
	    done
	done
    done

echo "Run all done!"
