#TRAIN_DIR_1=/home/users/flow_user/ray_results/yulin_hierarchy_eta1_0.9_eta2_0.1/hierarchy_based_on_aamas_full
#TRAIN_DIR_1=/home/users/flow_user/ray_results/yulin_hierarchy_eta1_0.9_eta2_0.1/aamas_full
declare -A TRAIN_DIR
declare -A MARK 


zipper_simple_merge_idm=${HOME}/aug7/zipper_simple_merge_Even_Avp_Main_Merge200_Collaborate_lr_schedule_eta1_0.9_eta2_0.1/PPO_MultiAgentHighwayPOEnvMerge4Collaborate-v0_10544_00000_0_2022-08-07_21-16-08
zipper_simple_merge_shadow=${HOME}/aug7/zipper_simple_merge_shadow_Main_Merge200_Collaborate_lr_schedule_eta1_0.9_eta2_0.1/PPO_MultiAgentMerge4ShadowHeadwayPOEnvParameterizedWindowSizeCollaborate-v0_3ac32_00000_0_2022-08-07_22-50-22



FLOW_DIR=${PWD}/../..
#VISUALIZER=$FLOW_DIR/flow/visualize/new_rllib_visualizer.py
VISUALIZER=$FLOW_DIR/flow/visualize/parallized_visualizer.py
EXP_FOLDER=$FLOW_DIR/exp_results
WORKING_DIR=$EXP_FOLDER/aug7_zipper_simple_merge

# 1. 1650_200_30 I=4
# 2. 1850_200_30 I=5
# 3. 2000_200_30 I=6

echo "*************add python path to current direction***********"
export PYTHONPATH="${PYTHONPATH}:$FLOW_DIR"
#${PWD}/$FLOW_DIR/
echo "set python path: $PYTHONPATH"

echo "************************************************************"
#echo ${TRAIN_DIR[*]}
NUM=0

MERGE_INFLOW=200

MAIN_HUMAN=2000
MAIN_RL=0
MERGE=200
measurement=8000
WINDOW=400
render=no_render

CHCKPOINT=1




mkdir ${WORKING_DIR}
J=0

for MAIN_HUMAN in 2000 1800 1600 1400 1200 #6000 8000 10000 #400 600 800 
do
    #python3 $VISUALIZER \
    #            ${zipper_simple_merge_idm} \
    #            $CHCKPOINT \
    #            --seed_dir $FLOW_DIR \
    #            --horizon 4000 \
    #            --render_mode ${render} \
    #            --num_of_rand_seeds 50 \
    #            --cpu 52 \
    #            --measurement_rate ${measurement} \
    #            --to_probability \
    #            --max_deceleration 20 \
    #            --handset_inflow $MAIN_HUMAN $MAIN_RL $MERGE \
    #            --window_size $WINDOW $WINDOW $WINDOW 
    #            >> ${WORKING_DIR}/EVAL_IDM_${MAIN_HUMAN}_${MERGE}.txt 

    python3 $VISUALIZER \
                ${zipper_simple_merge_shadow} \
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


#for I in 62 63 64 #3 7 8 9 10 #11 12 13 14 15 1 #7 8 9 10 11 12 13 14 15
#do
#	echo "${TRAIN_DIR[$I]}"
#	#mkdir ${WORKING_DIR}/${MARK[$I]}
#
#	for MERGE_INFLOW in 200 #400 600 800 #180 190 200 210 220 230 240 250 260 270 280 290 300 310 320 330 340 350 360 370 380 390 400 500 600 700 800 900 1000 
#	do
#		for MAIN_INFLOW in 2000 #1700 1800 1900 2000 #1650 #2000 #1850 1650
#		do
#			for AVP in 10 #2 3 4 5 6 7 8 9 10 12 14 16 18 20 25 30 35 40
#			do
#				let MAIN_RL_INFLOW=MAIN_INFLOW*${AVP}/100
#				let MAIN_HUMAN_INFLOW=MAIN_INFLOW-MAIN_RL_INFLOW
#				echo "evaluate" ${TRAIN_DIR[$I]} ${MARK[$I]} "on AVP ${AVP}"
#				echo $MAIN_HUMAN_INFLOW $MAIN_RL_INFLOW $MERGE_INFLOW
#
#                if (($I==62)); then
#                    FNAME="IJCAI_Krauss"
#                elif (($I==63)); then
#                    FNAME="IJCAI_IDM"
#                elif (($I==64)); then
#                    FNAME="IJCAI_avg_speed"
#                fi
#                echo "fname" ${FNAME}
#
#				python3 $VISUALIZER \
#					${TRAIN_DIR[$I]} \
#					$CHCKPOINT \
#					--render_mode no_render \
#					--seed_dir $FLOW_DIR \
#				    --cpu 10 \
#					--measurement_rate 5000 \
#					--horizon 2000 \
#					--handset_inflow $MAIN_HUMAN_INFLOW $MAIN_RL_INFLOW $MERGE_INFLOW \
#					>> ${WORKING_DIR}/${FNAME}_EVAL_${MAIN_INFLOW}_${MERGE_INFLOW}_${AVP}_even.txt &
#
#                python3 $VISUALIZER \
#					${TRAIN_DIR[$I]} \
#					$CHCKPOINT \
#					--render_mode no_render \
#					--seed_dir $FLOW_DIR \
#				    --cpu 10 \
#                    --to_probability \
#					--measurement_rate 5000 \
#					--horizon 2000 \
#					--handset_inflow $MAIN_HUMAN_INFLOW $MAIN_RL_INFLOW $MERGE_INFLOW \
#					>> ${WORKING_DIR}/${FNAME}_EVAL_${MAIN_INFLOW}_${MERGE_INFLOW}_${AVP}_random.txt &
#
#					#--to_probability \
#                    #--print_vehicles_per_time_step_in_file april26_avg_3_speeds_krauss_idm_even \
#				let J=J+1
#				if ((J == 30)); then
#					wait
#					let J=0
#					echo "another batch"
#				fi
#			done
#		done
#	done 
#done

#--history_file_name random_${MARK[$I]}_${MAIN_INFLOW}_${MERGE_INFLOW}_${AVP} \
#>> ${WORKING_DIR}/${MARK[$I]}/merge4_EVAL_${MAIN_INFLOW}_${MERGE_INFLOW}_${AVP}.txt &

				#python3 $VISUALIZER ${TRAIN_DIR[$I]} $CHCKPOINT --render_mode no_render --seed_dir $FLOW_DIR --to_probability --history_file_name random_${MARK[$I]}_${MAIN_INFLOW}_${MERGE_INFLOW}_${AVP} --handset_inflow $MAIN_HUMAN_INFLOW $MAIN_RL_INFLOW $MERGE_INFLOW 

				#python3 $VISUALIZER ${TRAIN_DIR[$I]} $CHCKPOINT --render_mode no_render --seed_dir $FLOW_DIR --to_probability --handset_inflow $MAIN_HUMAN_INFLOW $MAIN_RL_INFLOW $MERGE_INFLOW >> ${WORKING_DIR}/${MARK[$I]}/merge4_EVAL_${MAIN_INFLOW}_${MERGE_INFLOW}_${AVP}.txt &
wait
source ~/notification_zyl.sh
#for I in 4 
#do
#	echo "${TRAIN_DIR[$I]}"
#	mkdir ${WORKING_DIR}/${MARK[$I]}
#	for MAIN_INFLOW in 1650 1850 
#	do
#		for AVP in 30 
#		do
#			let MAIN_RL_INFLOW=MAIN_INFLOW*${AVP}/100
#			let MAIN_HUMAN_INFLOW=MAIN_INFLOW-MAIN_RL_INFLOW
#			echo "evaluate" ${TRAIN_DIR[$I]} ${MARK[$I]} "on AVP ${AVP}"
#			echo $MAIN_HUMAN_INFLOW $MAIN_RL_INFLOW $MERGE_INFLOW
#			python3 $VISUALIZER ${TRAIN_DIR[$I]} $CHCKPOINT --render_mode no_render --seed_dir $FLOW_DIR --avp_to_probability ${AVP} --handset_inflow $MAIN_HUMAN_INFLOW $MAIN_RL_INFLOW $MERGE_INFLOW >> ${WORKING_DIR}/${MARK[$I]}/merge4_EVAL_${MAIN_INFLOW}_${MERGE_INFLOW}_${AVP}.txt &
#		done
#	done
#	
#done

#for I in  4 5
#do
#	echo "${TRAIN_DIR[$I]}"
#	mkdir ${WORKING_DIR}/${MARK[$I]}
#	for MAIN_INFLOW in 1600 1700 1800 1900 2000
#	do
#		for AVP in 1 2 3 4 5 6 7 8 9 10 12 14 16 18 20
#		do
#			let MAIN_RL_INFLOW=MAIN_INFLOW*${AVP}/100
#			let MAIN_HUMAN_INFLOW=MAIN_INFLOW-MAIN_RL_INFLOW
#			echo "evaluate" ${TRAIN_DIR[$I]} ${MARK[$I]} "on AVP ${AVP}"
#			echo $MAIN_HUMAN_INFLOW $MAIN_RL_INFLOW $MERGE_INFLOW
#			python3 $VISUALIZER ${TRAIN_DIR[$I]} $CHCKPOINT --render_mode no_render --seed_dir $FLOW_DIR --avp_to_probability ${AVP} --handset_inflow $MAIN_HUMAN_INFLOW $MAIN_RL_INFLOW $MERGE_INFLOW >> ${WORKING_DIR}/${MARK[$I]}/merge4_EVAL_${MAIN_INFLOW}_${MERGE_INFLOW}_${AVP}.txt &
#		done
#		wait
#	done
#	
#done



#mkdir $WORKING_DIR
#for I in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
#do
#	echo "${TRAIN_DIR[$I]}"
#	mkdir ${WORKING_DIR}/${MARK[$I]}
#	for MAIN_INFLOW in 1600 1650 1700 1750 1800 1850 1900 1950 2000
#	do
#		let MAIN_RL_INFLOW=MAIN_INFLOW*${AVPS[$I]}/100
#		let MAIN_HUMAN_INFLOW=MAIN_INFLOW-MAIN_RL_INFLOW
#		echo "evaluate" ${TRAIN_DIR[$I]} ${MARK[$I]} "on AVP ${AVP}"
#		echo $MAIN_HUMAN_INFLOW $MAIN_RL_INFLOW $MERGE_INFLOW
#		python3 $VISUALIZER ${TRAIN_DIR[$I]} $CHCKPOINT --render_mode no_render --seed_dir $FLOW_DIR --avp_to_probability ${AVPS[$I]} --handset_inflow $MAIN_HUMAN_INFLOW $MAIN_RL_INFLOW $MERGE_INFLOW >> ${WORKING_DIR}/${MARK[$I]}/merge4_EVAL_${MAIN_INFLOW}_$MERGE_INFLOW.txt &
#	done
#	if ((I == 4 || I==8 || I==12)); then
#		wait
#	fi
#done


