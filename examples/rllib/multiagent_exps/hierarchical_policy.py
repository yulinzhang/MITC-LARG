"""Multi-agent highway with ramps example.

Trains a non-constant number of agents, all sharing the same policy, on the
highway with ramps network.
"""
import json
import ray
import argparse
try:
    from ray.rllib.agents.agent import get_agent_class
except ImportError:
    from ray.rllib.agents.registry import get_agent_class
from ray.rllib.agents.ppo.ppo_tf_policy import PPOTFPolicy
from ray import tune
from ray.tune.registry import register_env
from ray.tune import run_experiments

from flow.controllers import RLController, SimCarFollowingController
from flow.core.params import EnvParams, NetParams, InitialConfig, InFlows, \
                             VehicleParams, SumoParams, \
                             SumoCarFollowingParams, SumoLaneChangeParams

from flow.utils.registry import make_create_env
from flow.utils.rllib import FlowParamsEncoder

from flow.envs.multiagent import MultiAgentHighwayPOEnvMerge4Collaborate
#from flow.envs.multiagent import MultiAgentHighwayPOEnvMerge4CollaborateWithVehiclesAhead
from flow.envs.multiagent import MultiAgentHighwayPOEnvMerge4Hierarchy 
from flow.envs.ring.accel import ADDITIONAL_ENV_PARAMS
from flow.networks import MergeNetwork
from flow.networks.merge import ADDITIONAL_NET_PARAMS
from copy import deepcopy
from flow.utils.rllib import get_rllib_config, get_rllib_pkl
from flow.utils.rllib import get_flow_params
from flow.utils.registry import make_create_env
from ray.tune.registry import register_env,get_trainable_cls
try:
    from ray.rllib.agents.agent import get_agent_class
except ImportError:
    from ray.rllib.agents.registry import get_agent_class

from ray.rllib.agents.callbacks import DefaultCallbacks
from flow.envs.multiagent.trained_policy import init_policy_agent

EXAMPLE_USAGE = """
example usage:
    python xxxx.py --attr value
"""
parser = argparse.ArgumentParser( formatter_class=argparse.RawDescriptionHelpFormatter,
    description="[Flow] Evaluates a Flow Garden solution on a benchmark.",
    epilog=EXAMPLE_USAGE)
# optional input parameters
parser.add_argument(
    '--avp',
    type=int,
    help="The percentage of autonomous vehicles. value between 0-100")
parser.add_argument(
    '--num_rl',
    type=int,
    help="The percentage of autonomous vehicles. value between 0-100")
parser.add_argument('--handset_inflow', type=int, nargs="+",help="Manually set inflow configurations, notice the order of inflows when they were added to the configuration")


parser.add_argument('--policy_dir', type=str, default="/home/users/flow_user/ray_results/yulin_multiagent_highway_merge4_Full_Collaborate_lr_schedule_eta1_0.9_eta2_0.1/merge4_highway2000_merge200_avp_10", help="path to the trained policy")

parser.add_argument('--policy_checkpoint', type=str, default="500", help="path to the trained policy")

args=parser.parse_args()

# SET UP PARAMETERS FOR THE SIMULATION

# number of training iterations
N_TRAINING_ITERATIONS = 500
# number of rollouts per training iteration
N_ROLLOUTS = 30 
# number of steps per rollout
HORIZON = 2000
# number of parallel workers
N_CPUS = 11

NUM_RL = 10
if args.num_rl:
    NUM_RL=args.num_rl
# inflow rate on the highway in vehicles per hour
FLOW_RATE = 2000
# inflow rate on each on-ramp in vehicles per hour
MERGE_RATE = 200
# percentage of autonomous vehicles compared to human vehicles on highway
RL_PENETRATION = 0.1 
if args.avp:
    RL_PENETRATION = (args.avp/100.0) 
# Selfishness constant
ETA_1 = 0.9
ETA_2 = 0.1


# SET UP PARAMETERS FOR THE NETWORK
additional_net_params = deepcopy(ADDITIONAL_NET_PARAMS)
additional_net_params["merge_lanes"] = 1
additional_net_params["highway_lanes"] = 1
additional_net_params["pre_merge_length"] = 500



# SET UP PARAMETERS FOR THE ENVIRONMENT

additional_env_params = ADDITIONAL_ENV_PARAMS.copy()



# CREATE VEHICLE TYPES AND INFLOWS
vehicles = VehicleParams()
inflows = InFlows()

# human vehicles
vehicles.add(
    veh_id="human",
    acceleration_controller=(SimCarFollowingController, {}),
    car_following_params=SumoCarFollowingParams(
        speed_mode=9,  # for safer behavior at the merges
        #tau=1.5  # larger distance between cars
    ),
    #lane_change_params=SumoLaneChangeParams(lane_change_mode=1621)
    num_vehicles=5)

# autonomous vehicles
vehicles.add(
    veh_id="rl",
    acceleration_controller=(RLController, {}),
    car_following_params=SumoCarFollowingParams(
        speed_mode=9,
    ),
    num_vehicles=0)

# Vehicles are introduced from both sides of merge, with RL vehicles entering
# from the highway portion as well
inflow = InFlows()
if 1-RL_PENETRATION>0:
    inflow.add(
        veh_type="human",
        edge="inflow_highway",
        vehs_per_hour=(1 - RL_PENETRATION) * FLOW_RATE,
        depart_lane="free",
        depart_speed=10)
if RL_PENETRATION>0:
    inflow.add(
        veh_type="rl",
        edge="inflow_highway",
        vehs_per_hour=RL_PENETRATION * FLOW_RATE,
        depart_lane="free",
        depart_speed=10)
inflow.add(
    veh_type="human",
    edge="inflow_merge",
    vehs_per_hour=MERGE_RATE,
    depart_lane="free",
    depart_speed=7.5)


ray.init(num_cpus=N_CPUS + 1,object_store_memory=2*1024*1024*1024)
# restore the trained policy as an acceleration controller and give it to the environment
result_dir=args.policy_dir    
print("result_dir:", result_dir)
#flow_params['env'].additional_params['trained_dir']=result_dir
#flow_params['env'].additional_params['env_name']=env_name
checkpoint_dir = result_dir + '/checkpoint_' + args.policy_checkpoint+"/"+'checkpoint-' + args.policy_checkpoint
#trained_agent_ref=init_policy_agent(result_dir, checkpoint_dir)

#flow_params['env'].additional_params['checkpoint']=checkpoint_dir

flow_params = dict(
    exp_tag='yulin_hierarchy_eta1_{}_eta2_{}'.format(ETA_1, ETA_2),

    env_name=MultiAgentHighwayPOEnvMerge4Hierarchy,
    network=MergeNetwork,
    simulator='traci',

    #env=EnvParams(
    #    horizon=HORIZON,
    #    warmup_steps=200,
    #    sims_per_step=1,  # do not put more than one #FIXME why do not put more than one
    #    additional_params=additional_env_params,
    #),

    sim=SumoParams(
        restart_instance=True,
        sim_step=0.5,
        render=False,
    ),


    # environment related parameters (see flow.core.params.EnvParams)
    env=EnvParams(
        horizon=HORIZON,
        sims_per_step=1,
        warmup_steps=0,
        additional_params={
            "max_accel": 2.6,
            "max_decel": 4.5,
            "target_velocity": 30,
            "num_rl": NUM_RL,
            "eta1": ETA_1,
            "eta2": ETA_2,
            "max_headway": 50,
            "trained_dir":result_dir,
            #"env_name":MultiAgentHighwayPOEnvMerge4Hierarchy,
            "checkpoint":checkpoint_dir,
            #"trained_agent_ref":trained_agent_ref,
        },
    ),

    net=NetParams(
        inflows=inflow,
        additional_params=additional_net_params,
    ),

    veh=vehicles,
    initial=InitialConfig(),
)

if args.handset_inflow:
    flow_params['env'].additional_params['handset_inflow']=args.handset_inflow

# SET UP EXPERIMENT
def setup_exps(flow_params):
    """Create the relevant components of a multiagent RLlib experiment.

    Parameters
    ----------
    flow_params : dict
        input flow-parameters

    Returns
    -------
    str
        name of the training algorithm
    str
        name of the gym environment to be trained
    dict
        training configuration parameters
    """
    alg_run = 'PPO'
    agent_cls = get_agent_class(alg_run)
    config = agent_cls._default_config.copy()
    config['num_workers'] = N_CPUS
    config['train_batch_size'] = HORIZON * N_ROLLOUTS
    config['sgd_minibatch_size'] = 4096
    #config['simple_optimizer'] = True
    config['gamma'] = 0.998  # discount rate
    config['model'].update({'fcnet_hiddens': [100, 50, 25]})
    #config['lr'] = tune.grid_search([5e-4, 1e-4])
    config['lr_schedule'] = [
            [0, 5e-4],
            [1000000, 1e-4],
            [4000000, 1e-5],
            [8000000, 1e-6]]
    config['horizon'] = HORIZON
    config['clip_actions'] = False
    config['observation_filter'] = 'NoFilter'
    config["use_gae"] = True
    config["lambda"] = 0.95
    config["shuffle_sequences"] = True
    config["vf_clip_param"] = 1e8
    config["num_sgd_iter"] = 10
    #config["kl_target"] = 0.003
    config["kl_coeff"] = 0.01
    config["entropy_coeff"] = 0.001
    config["clip_param"] = 0.2
    config["grad_clip"] = None
    config["use_critic"] = True
    config["vf_share_layers"] = True
    config["vf_loss_coeff"] = 0.5


    # save the flow params for replay
    flow_json = json.dumps(
        flow_params, cls=FlowParamsEncoder, sort_keys=True, indent=4)
    config['env_config']['flow_params'] = flow_json
    config['env_config']['run'] = alg_run
    
    #flow_params['env'].additional_params['trained_agent_ref']=trained_agent_ref
    create_env, env_name = make_create_env(params=flow_params, version=0)
    print(env_name)

    # register as rllib env
    register_env(env_name, create_env)

    # multiagent configuration
    temp_env = create_env()
    policy_graphs = {'av': (PPOTFPolicy,
                            temp_env.observation_space,
                            temp_env.action_space,
                            {})}
    def policy_mapping_fn(_):
        return 'av'

    config.update({
        'multiagent': {
            'policies': policy_graphs,
            'policy_mapping_fn': policy_mapping_fn,
            'policies_to_train': ['av']
        }
    })


    return alg_run, env_name, config


# RUN EXPERIMENT

if __name__ == '__main__':

    alg_run, env_name, config = setup_exps(flow_params)

    run_experiments({
        flow_params['exp_tag']: {
            'run': alg_run,
            'env': env_name,
            'checkpoint_freq': 5,
            'max_failures': 999,
            'checkpoint_at_end': True,
            'stop': {
                'training_iteration': N_TRAINING_ITERATIONS
            },
            'config': config,
            'num_samples':1,
        },
    })
