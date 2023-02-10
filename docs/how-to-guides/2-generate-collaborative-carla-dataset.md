# Generate Collaborative CARLA Dataset

Few autonomous-driving datasets have access to sensor data from collaborative agents. Those collaborative agents could be other vehicles (in a vehicle-to-vehicle configuration) or infrastructure sensing equipment (in a vehicle-to-infrastructure configuration). These multi-agent, collaborative sensing scenarios are very important to the survivability and ultimate safety of autonomous vehicles in our society. You may also see this called "connected vehicles", and by and large, this is considered an essential next-generation target for AVs. [Don't just take my word for it!][avs-connected]. 

Since there are not many options out in the research world for collaborative/connected-vehicle datasets, we wanted to open up a way to generate your own. If you've generated a regular ego-based dataset (previous guide), generating a collaborative dataset won't be much additional work. It will just require additionally specifying the configuration of the collaborative sensors.

## Configuring Collaborative Sensors

There are at least two options worthe considering for configuring a collaborative sensing suite. The first is to place sensors at static places in the environment to model "infrastructure" sensing and awareness. The second is to place them on mobile platforms, i.e., npcs, to model vehicle-to-vehicle configurations. These options are not mutually exclusive whatsoever - they can (and ultimately should) be done in tandem! We solely consider infrastructure-based sensors because the number of moving parts (quite literally) are reduced in a static configuration.

### Option 1: Infrastructure-Based Sensors

In this case, we'll (finally) include an `infrastructure` section in our scenario YAML file. That section could look like this:
```
infrastructure:
  cameras:
    n_spawn: 5
    save: true
    attributes:
      sensor_tick: 0.1  # faster to capture data
  depthcams:
    n_spawn: 5
    save: true
    attributes:
      sensor_tick: 0.1  # faster to capture data
  lidars:
    n_spawn: 5
    save: true
    attributes:
      sensor_tick: 0.1  # faster to capture data
```
where we've specified the number of infrastructure sensors we wish to include. The sensors will spawn in order from a "spawn index list", so their locations will be repeated every time, unless this list is changed.

Don't be fooled by the *apparent* simplicity of this top-level scenario configuration file. There are PLENTY of configuration options to be tweaked. If you want to be able to modify more options, just look at the `default_infrastructure.yml` file. For example, the camera has configuration options default to:
```
cameras:
  n_spawn: 0
  sensor_name: 'camera'
  name_prefix: 'CAM_INFRASTRUCTURE'
  idx_spawn: 'in_order'
  idx_spawn_list: [1, 10, 20, 5, 8, 15]
  spawn_loc: 'anywhere'
  comm_range: 50
  position_uncertainty:
    x: 0.0001
    y: 0.0001
    z: 0.0001
  save: false
  attributes:
    sensor_tick: 0.5
    fov: 90
    image_size_x: 1600
    image_size_y: 900
  noise: {}
  transform:
    location:
      x: 0
      y: 0
      z: 15  # up in the air
    rotation:
      pitch: -30
      yaw: 0
      roll: 0
```

A few points of note: the infrastructure sensors are programmed to have limited communication range. Thus, an AV may only be able to hear from a select few infrastructure sensors at a time. Also, the default placement of the infrastructure sensors is "up in the air" to model as if they were on a traffic light, power line, or cell tower, for example.

All of these configuration options can be changed in your top-level scenario YAML file. Only change the `default_infrastructure.yml` file is you are able to justify that a configuration change should be a new default.


### Option 2: Vehicle-Based Sensors

To be explored in a future iteration!

## Run Script

The run script for this configuration is nearly identical to the case for the "regular" carla dataset. In this case, we just change the scenario file. So we'll have, for, say, `run_capture_data_infrastructure.sh`, we'll have:
```
#!/usr/bin/env bash

VERSION=${1:-0.9.13}
N_SCENARIOS=${2:-20}
MAX_SCENARIO_LEN=${3:-20}

source setup_for_standard.bash

python exec_standard.py \
    --n_scenarios $N_SCENARIOS \
    --max_scenario_len $MAX_SCENARIO_LEN \
    --config_avstack 'PassthroughAutopilotVehicle' \
    --config_carla 'scenarios/collaborative_capture_data.yml' \
    --image_dump_time 25 \
    --seed 1 \
    --version $VERSION
```

**NOTE OF CAUTION:** When you run this, best practice would either be to include the parameter flag `--remove_data` to remove the previous `sim-results` or to just move the previous `sim-results` somewhere else. If you don't do one of these, you risk mixing scenes that were not meant to be mixed (i.e., scene 1 is non-collaborative, scene 2 is collaborative). This could screw things up down the line, so make sure you manage your data appropriately.


## Postprocessing

The same postprocessing applies to the collaborative dataset as to the regular dataset. Follow the guidelines from the previous how-to guide. Postprocessing will take a bit more time in this case since we have many more sensors than in the ego-only case.


[avs-connected]: https://www.transportation.gov/sites/dot.gov/files/2021-01/USDOT_AVCP.pdf