#!/bin/bash

FLOW_DIR=${PWD}/../..
export PYTHONPATH="${PYTHONPATH}:${FLOW_DIR}"
export RAY_MEMORY_MONITOR_ERROR_THRESHOLD=0.8


# Even vehicle placement
MERGE_INFLOW=200
MAIN_INFLOW=2000
AVP=30

let MAIN_RL_INFLOW=MAIN_INFLOW*${AVP}/100
let MAIN_HUMAN_INFLOW=MAIN_INFLOW-MAIN_RL_INFLOW

WINDOW=400

echo "Avp:${AVP}, Inflows:${MAIN_HUMAN_INFLOW} ${MAIN_RL_INFLOW} ${MERGE_INFLOW}"
python3 ${FLOW_DIR}/examples/rllib/multiagent_exps/zipper_simple_merge_aamas.py \
    --handset_inflow $MAIN_HUMAN_INFLOW $MAIN_RL_INFLOW $MERGE_INFLOW \
    --exp_folder_mark shadow_Main${MAIN_INFLOW}_Merge${MERGE_INFLOW} \
    --window_size $WINDOW $WINDOW $WINDOW \
	--cpu 20


