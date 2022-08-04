"""Multi-agent highway with ramps example.

Trains a non-constant number of agents, all sharing the same policy, on the
highway with ramps network.
"""
import json
import ray
import argparse
import sys
try:
    from ray.rllib.agents.agent import get_agent_class
except ImportError:
    from ray.rllib.agents.registry import get_agent_class
from ray.rllib.agents.ppo.ppo_tf_policy import PPOTFPolicy
from ray import tune
from ray.tune.registry import register_env
from ray.tune import run_experiments

from flow.controllers import IDMController, RLController, SimCarFollowingController
from flow.controllers import SimLaneChangeController
from flow.core.params import EnvParams, NetParams, InitialConfig, InFlows, \
                             VehicleParams, SumoParams, \
                             SumoCarFollowingParams, SumoLaneChangeParams

from flow.utils.registry import make_create_env
from flow.utils.rllib import FlowParamsEncoder

from flow.envs import multiagent
from flow.envs.multiagent import LeftLaneHeadwayControlledMultiAgentEnv, SingleLaneController, BehindCurrentAheadSingleLaneController, MultiAgentMerge4ShadowHeadwayPOEnvParameterizedWindowSizeCollaborate

from flow.envs.ring.accel import ADDITIONAL_ENV_PARAMS
from flow.networks import MergeNetwork
from flow.networks.merge import ADDITIONAL_NET_PARAMS
from copy import deepcopy
from flow.visualize.visualizer_util import reset_inflows, set_argument
from IPython.core.debugger import set_trace
import inspect

args=set_argument()

# SET UP PARAMETERS FOR THE SIMULATION

# number of training iterations
N_TRAINING_ITERATIONS = 1 
# number of rollouts per training iteration
N_ROLLOUTS = 30 
# number of steps per rollout
HORIZON = 2000
if args.horizon:
    discount = args.horizon / HORIZON
    HORIZON = args.horizon
    N_TRAINING_ITERATIONS = N_TRAINING_ITERATIONS / discount
    if args.num_training_iterations:
        N_TRAINING_ITERATIONS = min(N_TRAINING_ITERATIONS, args.num_training_iterations)

# number of parallel workers
N_CPUS = 40
if args.cpu:
    N_CPUS=args.cpu

NUM_RL = 10
#if args.num_rl:
#    NUM_RL=args.num_rl
# inflow rate on the highway in vehicles per hour
FLOW_RATE = 2000
# inflow rate on each on-ramp in vehicles per hour
MERGE_RATE = 200
# percentage of autonomous vehicles compared to human vehicles on highway
RL_PENETRATION = 0.1 
#if args.avp:
#    RL_PENETRATION = (args.avp/100.0) 
# Selfishness constant
ETA_1 = 0.9 
if args.eta1 is not None: # default to be 0.9
    ETA_1 = args.eta1
ETA_2 = 1 - ETA_1
ETA_3 = 0
if args.eta3 is not None:
    ETA_3 = args.eta3


# SET UP PARAMETERS FOR THE NETWORK
additional_net_params = deepcopy(ADDITIONAL_NET_PARAMS)
additional_net_params["merge_lanes"] = 1
additional_net_params["highway_lanes"] = 1
additional_net_params["pre_merge_length"] = 500

if args.window_size is not None:
    window_size=tuple(args.window_size)
else:
    window_size = [400, 400]


if args.highway_len is not None:
    pre_merge_len = args.highway_len - 200
    additional_net_params["pre_merge_length"] = pre_merge_len
    
# SET UP PARAMETERS FOR THE ENVIRONMENT

additional_env_params = ADDITIONAL_ENV_PARAMS.copy()


mark=""
if args.exp_folder_mark:
    mark = args.exp_folder_mark + "_"

exp_tag_str = 'shadow_single_lane_' + mark + 'accel_eta1_{:.2f}_eta2_{:.2f}_eta3_{:.2f}'.format(ETA_1, ETA_2, ETA_3)

#exp_tag_str = mark+'i696_window_size_{}_{}'.format(window_size[0], window_size[1])

lateral_resolution=3.2
if args.lateral_resolution:
        lateral_resolution=args.lateral_resolution

flow_params = dict(
    exp_tag=exp_tag_str,
    env_name=MultiAgentMerge4ShadowHeadwayPOEnvParameterizedWindowSizeCollaborate, #SingleLaneController, # SingleLaneController, #LeftLaneHeadwayControlledMultiAgentEnv #DoubleLaneController
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
        lateral_resolution=lateral_resolution, # determines lateral discretization of lanes
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
            "eta3": ETA_3,
            "window_size": window_size,
        },
    ),

    net=NetParams(
        inflows=None,
        additional_params=additional_net_params,
    ),

    veh=None,
    initial=InitialConfig(),
)
reset_inflows(args, flow_params)
print("class path", multiagent.__file__)
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

    create_env, env_name = make_create_env(params=flow_params, version=0)

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
            'policy_mapping_fn': tune.function(policy_mapping_fn),
            'policies_to_train': ['av']
        }
    })

    return alg_run, env_name, config


# RUN EXPERIMENT

if __name__ == '__main__':
    alg_run, env_name, config = setup_exps(flow_params)
    ray.init(num_cpus=N_CPUS + 1)

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

