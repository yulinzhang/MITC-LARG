#!/bin/bash

FLOW_DIR=${PWD}/../..
export PYTHONPATH="${PYTHONPATH}:${FLOW_DIR}"
export RAY_MEMORY_MONITOR_ERROR_THRESHOLD=0.8

MAIN_INFLOW=2000
# Merge vehicle placement
MERGE_INFLOW=200
WINDOW=400
MAIN_HUMAN=2000
MAIN_RL=0
MERGE=200

python3 ${FLOW_DIR}/examples/rllib/multiagent_exps/shadow_simple_merge.py \
            --horizon 2000 \
            --lateral_resolution 0.25 \
            --max_deceleration 20 \
            --cpu 16 \
            --window_size ${WINDOW} ${WINDOW} ${WINDOW} \
            --handset_inflow $MAIN_HUMAN $MAIN_RL $MERGE
            #--i696 \

wait
source ~/notification_zyl.sh

#inflow_type=0
#python3 ${FLOW_DIR}/examples/rllib/multiagent_exps/multiagent_lane_change_merge4_Collaborate_lrschedule.py \
#	--exp_folder_mark yulin${inflow_type} \
#	--lateral_resolution 3.2 \
#	--cpu 30 \
#	--to_probability \
#	--preset_inflow ${inflow_type} &
#
#inflow_type=1
#python3 ${FLOW_DIR}/examples/rllib/multiagent_exps/multiagent_lane_change_merge4_Collaborate_lrschedule.py \
#	--exp_folder_mark yulin${inflow_type} \
#	--lateral_resolution 3.2 \
#	--cpu 30 \
#	--to_probability \
#	--preset_inflow ${inflow_type}


