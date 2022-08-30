FLOW_DIR=${PWD}/../..
#VISUALIZER=$FLOW_DIR/flow/visualize/new_rllib_visualizer.py
VISUALIZER=$FLOW_DIR/flow/visualize/parallized_visualizer.py
EXP_FOLDER=$FLOW_DIR/exp_results/

# merge 200

TRAIN_DIR_i696=${HOME}/ray_results/yulin_stabilizing_i696/PPO_MergePOEnv-v0_9a4a5_00000_0_2022-04-28_12-42-41
# daniel's i696
TRAIN_DIR_i696=${HOME}/ray_results/i696_window_size_300_300/PPO_MultiAgentI696POEnvParameterizedWindowSizeCollaborate-v0_e3194_00000_0_2022-04-29_22-16-12/
# single_lane i696
#TRAIN_DIR_i696=${HOME}/ray_results/i696_window_size_300_300/PPO_MultiAgentI696POEnvParameterizedWindowSizeCollaborate-v0_80a69_00000_0_2022-04-30_00-07-58/
#TRAIN_DIR_i696=${HOME}/ray_results/zyl_i696_window_size_300_300/PPO_MultiAgentI696POEnvParameterizedWindowSizeCollaborate-v0_fc465_00000_0_2022-05-01_22-14-32/

TRAIN_DIR_i696=${HOME}/may13/zipper_merge_i696_window_size_300.0_300.0/PPO_MultiAgentI696POEnvParameterizedWindowSizeCollaborate-v0_c8963_00000_0_2022-05-13_20-40-06

TRAIN_DIR_i696=${HOME}/aug18/zyl_i696_window_size_300_300/PPO_MultiAgentI696POEnvParameterizedWindowSizeCollaborate-v0_f7bca_00000_0_2022-05-02_16-00-59/
#TRAIN_DIR_i696=/home/users/yulin/ray_results/aug21_i696_window_size_400.0_400.0/PPO_MultiAgentI696POEnvParameterizedWindowSizeCollaborate-v0_a5a2c_00000_0_2022-08-21_20-20-45

#TRAIN_DIR_i696=${HOME}/jun27/shadow_i696/PPO_MultiAgentI696POEnvParameterizedWindowSizeCollaborate-v0_95f34_00000_0_2022-06-27_18-48-03
TRAIN_DIR_i696_shadow=${HOME}/july7/shadow/PPO_MultiAgentI696ShadowHeadwayPOEnvParameterizedWindowSizeCollaborate-v0_b4c71_00000_0_2022-07-07_19-48-39

zipper_simple_merge_aamas=${HOME}/aug10/zipper_simple_merge_aamas_Main2000_Merge200_AVP30/PPO_MultiAgentHighwayPOEnvMerge4Collaborate-v0_0e8b3_00000_0_2022-08-10_14-53-08
priority_simple_merge_aamas=${HOME}/aug10/priority_simple_merge_Main2000_Merge200_AVP30/PPO_MultiAgentHighwayPOEnvMerge4Collaborate-v0_50fc3_00000_0_2022-08-10_16-49-31


mkdir ${EXP_FOLDER}
WORKING_DIR=$EXP_FOLDER/aug18_prob_i696
mkdir ${WORKING_DIR}

echo "*************add python path to current direction***********"
export PYTHONPATH="${PYTHONPATH}:${PWD}/../../"

CHCKPOINT=1

MAIN_HUMAN=8000
MAIN_RL=0
MERGE=300
measurement=8000
render=no_render
WINDOW=400

for MERGE in 200 300
do
    for MAIN_INFLOW in 4000 6000 8000 10000 #400 600 800 
    do
                
        #for AVP in 30 100
        #do
        #    let MAIN_RL_INFLOW=MAIN_INFLOW*${AVP}/100
        #    let MAIN_HUMAN_INFLOW=MAIN_INFLOW-MAIN_RL_INFLOW
        #    echo "Avp:${AVP}, Inflows:${MAIN_HUMAN_INFLOW} ${MAIN_RL_INFLOW} ${MERGE}"

        #    # AAMAS
        #    python3 $VISUALIZER \
        #                $TRAIN_DIR_i696 \
        #                $CHCKPOINT \
        #                --agent_action_policy_dir $zipper_simple_merge_aamas \
        #                --seed_dir $FLOW_DIR \
        #                --horizon 14000 \
        #                --i696 \
        #                --render_mode ${render} \
        #                --num_of_rand_seeds 50 \
        #                --cpu 52 \
        #                --to_probability \
        #                --measurement_rate ${measurement} \
        #                --lateral_resolution 0.25 \
        #                --max_deceleration 20 \
        #                --handset_inflow $MAIN_HUMAN_INFLOW $MAIN_RL_INFLOW $MERGE \
        #                --window_size $WINDOW $WINDOW $WINDOW \
        #                >> ${WORKING_DIR}/EVAL_shadow_window_${WINDOW}_${MAIN_HUMAN_INFLOW}_${MAIN_RL_INFLOW}_${MERGE}.txt 
        #                #--print_metric_per_time_step_in_file metrics 
        #done

	# Human
         python3 $VISUALIZER \
                    $TRAIN_DIR_i696 \
                    $CHCKPOINT \
                    --seed_dir $FLOW_DIR \
                    --horizon 14000 \
                    --i696 \
                    --render_mode ${render} \
                    --cpu 52 \
                    --num_of_rand_seeds 50 \
                    --measurement_rate ${measurement} \
                    --lateral_resolution 0.25 \
                    --max_deceleration 20 \
                    --window_size $WINDOW $WINDOW $WINDOW \
                    --to_probability \
                    --handset_inflow $MAIN_INFLOW 0 $MERGE \
		    >> ${WORKING_DIR}/EVAL_idm_${MAIN_INFLOW}_${MAIN_RL}_${MERGE}.txt 

    done
done

wait 

source ~/notification_zyl.sh

