#!/bin/bash

FLOW_DIR=${PWD}/../..
export PYTHONPATH="${PYTHONPATH}:${FLOW_DIR}"
export RAY_MEMORY_MONITOR_ERROR_THRESHOLD=0.8


# Even vehicle placement
MERGE_INFLOW=200

MAIN_HUMAN=1
MAIN_RL=0
MERGE=1
#python3 ${FLOW_DIR}/examples/rllib/stabilizing_i696.py 
HORIZONTAL_WINDOW=400
VERTICAL_WINDOW=400
MERGE_WINDOW=400

python3 ${FLOW_DIR}/examples/rllib/multiagent_exps/i696_multiagent.py \
            --horizon 4000 \
            --i696 \
            --lateral_resolution 0.25 \
            --cpu 10 \
            --window_size ${HORIZONTAL_WINDOW} ${VERTICAL_WINDOW} ${MERGE_WINDOW} \
            --exp_folder_mark 'priority_merge' \
            --handset_inflow $MAIN_HUMAN $MAIN_RL $MERGE

            #--max_deceleration 20 \

#for AVP in 10 #30 50 80 100
#do
#	for MAIN_INFLOW in 1850 #1650 1850 2000 
#	do
#		let MAIN_RL_INFLOW=MAIN_INFLOW/AVP
#		let MAIN_HUMAN_INFLOW=MAIN_INFLOW-MAIN_RL_INFLOW
#		echo "Avp:${AVP}, Inflows:${MAIN_HUMAN_INFLOW} ${MAIN_RL_INFLOW} ${MERGE_INFLOW}"
#		python3 ${FLOW_DIR}/examples/rllib/stabilizing_i696.py \
#	done
#done


