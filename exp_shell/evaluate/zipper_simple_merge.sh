#TRAIN_DIR_1=/home/users/flow_user/ray_results/yulin_hierarchy_eta1_0.9_eta2_0.1/hierarchy_based_on_aamas_full
#TRAIN_DIR_1=/home/users/flow_user/ray_results/yulin_hierarchy_eta1_0.9_eta2_0.1/aamas_full
declare -A TRAIN_DIR
declare -A MARK 


zipper_simple_merge_idm=${HOME}/aug7/zipper_simple_merge_Even_Avp_Main_Merge200_Collaborate_lr_schedule_eta1_0.9_eta2_0.1/PPO_MultiAgentHighwayPOEnvMerge4Collaborate-v0_10544_00000_0_2022-08-07_21-16-08
zipper_simple_merge_shadow=${HOME}/aug7/zipper_simple_merge_shadow_Main_Merge200_Collaborate_lr_schedule_eta1_0.9_eta2_0.1/PPO_MultiAgentMerge4ShadowHeadwayPOEnvParameterizedWindowSizeCollaborate-v0_3ac32_00000_0_2022-08-07_22-50-22
zipper_simple_merge_aamas="Please enter the path to the aamas model"

FLOW_DIR=${PWD}/../..
#VISUALIZER=$FLOW_DIR/flow/visualize/new_rllib_visualizer.py
VISUALIZER=$FLOW_DIR/flow/visualize/parallized_visualizer.py
EXP_FOLDER=$FLOW_DIR/exp_results
WORKING_DIR=$EXP_FOLDER/aug7_zipper_simple_merge

echo "*************add python path to current direction***********"
export PYTHONPATH="${PYTHONPATH}:$FLOW_DIR"
echo "set python path: $PYTHONPATH"
echo "************************************************************"

MERGE_INFLOW=200
measurement=1000

MERGE=200
WINDOW=400
render=no_render

CHCKPOINT=500

mkdir ${WORKING_DIR}
J=0
for MAIN_INFLOW in 2000 1800 1600 1400 1200 #6000 8000 10000 #400 600 800 
    let MAIN_RL=0
    let MAIN_HUMAN=MAIN_INFLOW
    # human baseline
    python3 $VISUALIZER \
        ${zipper_simple_merge_aamas} \
        $CHCKPOINT \
        --seed_dir $FLOW_DIR \
        --horizon 4000 \
        --render_mode ${render} \
        --num_of_rand_seeds 50 \
        --cpu 52 \
        --measurement_rate ${measurement} \
        --to_probability \
        --max_deceleration 20 \
        --handset_inflow $MAIN_HUMAN $MAIN_RL $MERGE \
        --window_size $WINDOW $WINDOW $WINDOW 
        >> ${WORKING_DIR}/EVAL_IDM_${MAIN_HUMAN}_${MERGE}.txt 

    # aamas policy 
    for AVP in 100
    do
        let MAIN_RL_INFLOW=MAIN_INFLOW*${AVP}/100
        let MAIN_HUMAN_INFLOW=MAIN_INFLOW-MAIN_RL_INFLOW
        echo "Avp:${AVP}, Inflows:${MAIN_HUMAN_INFLOW} ${MAIN_RL_INFLOW} ${MERGE_INFLOW}"

        python3 $VISUALIZER \
                    ${zipper_simple_merge_aamas} \
                    $CHCKPOINT \
                    --seed_dir $FLOW_DIR \
                    --horizon 4000 \
                    --render_mode ${render} \
                    --num_of_rand_seeds 50 \
                    --cpu 52 \
                    --measurement_rate ${measurement} \
                    --to_probability \
                    --max_deceleration 20 \
                    --handset_inflow $MAIN_HUMAN $MAIN_RL $MERGE \
                    --window_size $WINDOW $WINDOW $WINDOW \
                    >> ${WORKING_DIR}/EVAL_shadow_window_${WINDOW}_${MAIN_HUMAN}_${MERGE}.txt 
                    #--print_metric_per_time_step_in_file metrics 
                    #--merge2 ${MERGE2} \
                    #--agent_action_policy_dir ${TRAIN_DIR_shadow} \
                    #--lateral_resolution 0.25 \
                    #--i696 \
    done
done
wait
source ~/notification_zyl.sh
