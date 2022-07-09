FLOW_DIR=${PWD}/../..
VISUALIZER=$FLOW_DIR/flow/visualize/new_rllib_visualizer.py
#VISUALIZER=$FLOW_DIR/flow/visualize/parallized_visualizer.py
EXP_FOLDER=$FLOW_DIR/exp_results/

# merge 200

TRAIN_DIR_i696=${HOME}/ray_results/yulin_stabilizing_i696/PPO_MergePOEnv-v0_9a4a5_00000_0_2022-04-28_12-42-41
# daniel's i696
TRAIN_DIR_i696=${HOME}/ray_results/i696_window_size_300_300/PPO_MultiAgentI696POEnvParameterizedWindowSizeCollaborate-v0_e3194_00000_0_2022-04-29_22-16-12/
# single_lane i696
#TRAIN_DIR_i696=${HOME}/ray_results/i696_window_size_300_300/PPO_MultiAgentI696POEnvParameterizedWindowSizeCollaborate-v0_80a69_00000_0_2022-04-30_00-07-58/
#TRAIN_DIR_i696=${HOME}/ray_results/zyl_i696_window_size_300_300/PPO_MultiAgentI696POEnvParameterizedWindowSizeCollaborate-v0_fc465_00000_0_2022-05-01_22-14-32/
TRAIN_DIR_i696=${HOME}/ray_results/zyl_i696_window_size_300_300/PPO_MultiAgentI696POEnvParameterizedWindowSizeCollaborate-v0_f7bca_00000_0_2022-05-02_16-00-59/

TRAIN_DIR_i696=${HOME}/may13/zipper_merge_i696_window_size_300.0_300.0/PPO_MultiAgentI696POEnvParameterizedWindowSizeCollaborate-v0_c8963_00000_0_2022-05-13_20-40-06
#TRAIN_DIR_i696=${HOME}/jun27/shadow_i696/PPO_MultiAgentI696POEnvParameterizedWindowSizeCollaborate-v0_95f34_00000_0_2022-06-27_18-48-03
TRAIN_DIR_i696_shadow=${HOME}/july7/shadow/PPO_MultiAgentI696ShadowHeadwayPOEnvParameterizedWindowSizeCollaborate-v0_b4c71_00000_0_2022-07-07_19-48-39

mkdir ${EXP_FOLDER}
WORKING_DIR=$EXP_FOLDER

echo "*************add python path to current direction***********"
export PYTHONPATH="${PYTHONPATH}:${PWD}/../../"

CHCKPOINT=1

MAIN_HUMAN=8000
MAIN_RL=0
MERGE=400
measurement=8000
for MAIN_HUMAN in 8000 6000 4000
    python3 $VISUALIZER \
                $TRAIN_DIR_i696 \
                $CHCKPOINT \
                --seed_dir $FLOW_DIR \
                --horizon 14000 \
                --i696 \
                --render_mode sumo_gui \
                --cpu 50 \
                --measurement_rate ${measurement} \
                --lateral_resolution 0.25 \
                --max_deceleration 20 \
                --handset_inflow $MAIN_HUMAN $MAIN_RL $MERGE \
                >> ${WORKING_DIR}/july8_i696/EVAL_idm_${MAIN_HUMAN}_${MAIN_RL}_${MERGE}.txt 

    python3 $VISUALIZER \
                $TRAIN_DIR_i696_shadow \
                $CHCKPOINT \
                --seed_dir $FLOW_DIR \
                --horizon 14000 \
                --i696 \
                --render_mode sumo_gui \
                --cpu 50 \
                --measurement_rate ${measurement} \
                --lateral_resolution 0.25 \
                --max_deceleration 20 \
                --handset_inflow $MAIN_HUMAN $MAIN_RL $MERGE \
                >> ${WORKING_DIR}/july8_i696/EVAL_shadow_${MAIN_HUMAN}_${MAIN_RL}_${MERGE}.txt 
                #--print_metric_per_time_step_in_file metrics 

wait 

source ~/notification_zyl.sh

