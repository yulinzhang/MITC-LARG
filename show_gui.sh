#!/bin/bash
TRAIN_DIR=~/gitlab/flow_results/new_adaptive_headway_penality_avp10_main2000_merge200_maxheadway50
#count_ahead_normalized_multiagent_main2000_merge200_avp10
#new_adaptive_headway_penality_avp10_main2000_merge200_maxheadway50
#new_adaptive_headway_avp10_main2000_merge200_maxheadway50
$merge4_highway2000_merge200_avp_10
#new_adaptive_headway_avp10_main2000_merge200_maxheadway50
#new_adaptive_headway_avp90_main2000_merge200_maxheadway50
#new_adaptive_headway_count_ahead_avp10_main2000_merge200_maxheadway50
#adaptive_headway_count_ahead_main2000_merge200_avp10_maxheadway50
#adaptive_headway_penality_main2000_merge200_avp10_maxheadway50
#merge4_highway2000_merge200_avp_90 
#merge4_highway2000_merge200_avp_10
#merge_4_HUMAN_Sim
#linearPPO
#merge4_highway2000_merge200_avp_90
CHCKPOINT=500
#390

PYTHONPATH=. python3 flow/visualize/new_rllib_visualizer.py \
$TRAIN_DIR \
$CHCKPOINT \
--render_mode sumo_gui \
--num_rollouts 1 \
--handset_avp 10 
#--handset_inflow 1350 150 200 
#sumo_gui \
