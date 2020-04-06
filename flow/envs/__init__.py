"""Contains all callable environments in Flow."""
from flow.envs.base import Env
from flow.envs.bay_bridge import BayBridgeEnv
from flow.envs.bottleneck import BottleneckAccelEnv, BottleneckEnv, \
    BottleneckDesiredVelocityEnv
from flow.envs.traffic_light_grid import TrafficLightGridEnv, \
    TrafficLightGridPOEnv, TrafficLightGridTestEnv
from flow.envs.ring.lane_change_accel import LaneChangeAccelEnv, \
    LaneChangeAccelPOEnv
from flow.envs.ring.accel import AccelEnv
from flow.envs.ring.wave_attenuation import WaveAttenuationEnv, \
    WaveAttenuationPOEnv, WaveAttenuationPOEnvNoisy, WaveAttenuationPOEnvSpeedreward, WaveAttenuationPOEnvAvgSpeedreward, WaveAttenuationEnvAvgSpeedreward, WaveAttenuationPORadiusEnv, WaveAttenuationPORadius1Env, WaveAttenuationPORadius2Env, \
      WaveAttenuationPOEnvSmallAccelPenalty, \
      WaveAttenuationPOEnvMediumAccelPenalty, \
      WaveAttenuationPORadiusEnvAvgSpeedNormalized, \
      WaveAttenuationPORadius1EnvAvgSpeedNormalized, \
      WaveAttenuationPORadius2EnvAvgSpeedNormalized  
from flow.envs.merge import MergePOEnv, MergePORadius2Env, MergePORadius4Env, MergePORadius7Env
from flow.envs.test import TestEnv
from flow.envs.merge_no_headway import MergePOEnv_noheadway
from flow.envs.merge_noheadway_encourageRLmove import MergePOEnv_noheadway_encourageRLmove
# deprecated classes whose names have changed
from flow.envs.bottleneck_env import BottleNeckAccelEnv
from flow.envs.bottleneck_env import DesiredVelocityEnv
from flow.envs.green_wave_env import PO_TrafficLightGridEnv
from flow.envs.green_wave_env import GreenWaveTestEnv


__all__ = [
    'Env',
    'AccelEnv',
    'LaneChangeAccelEnv',
    'LaneChangeAccelPOEnv',
    'TrafficLightGridTestEnv',
    'MergePOEnv',
    'MergePOEnv_noheadway',
    'MergePOEnv_noheadway_encourageRLmove',
    'BottleneckEnv',
    'BottleneckAccelEnv',
    'WaveAttenuationEnv',
    'WaveAttenuationPOEnv',
    'TrafficLightGridEnv',
    'TrafficLightGridPOEnv',
    'BottleneckDesiredVelocityEnv',
    'TestEnv',
    'BayBridgeEnv',
    'MergePORadius2Env', 
    'MergePORadius4Env', 
    'MergePORadius7Env',
    # deprecated classes
    'BottleNeckAccelEnv',
    'DesiredVelocityEnv',
    'PO_TrafficLightGridEnv',
    'GreenWaveTestEnv',
    'WaveAttenuationPOEnvNoisy', 
    'WaveAttenuationPOEnvSpeedreward',
    'WaveAttenuationPOEnvAvgSpeedreward', 
    'WaveAttenuationEnvAvgSpeedreward',
    'WaveAttenuationPORadiusEnv', 
    'WaveAttenuationPORadius1Env',
    'WaveAttenuationPORadius2Env', 
    'WaveAttenuationPOEnvSmallAccelPenalty',
    'WaveAttenuationPOEnvMediumAccelPenalty',
    'WaveAttenuationPORadiusEnvAvgSpeedNormalized', 
    'WaveAttenuationPORadius1EnvAvgSpeedNormalized',
    'WaveAttenuationPORadius2EnvAvgSpeedNormalized',
]
