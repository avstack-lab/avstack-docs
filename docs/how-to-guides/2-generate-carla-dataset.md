# Generate CARLA Datasets

To effectively run models in a full-stack environment in Carla and/or to be able to evaluate Carla scenarios offline, we'll need to create a datasets of sensor and truth data from Carla. This guide will walk us through how to do so and exactly what configuration knobs one can change to alter the composition of the dataset.


## Preparation

### Scenario Configuration

We'll want to create a custom scenario configuration file. This configuration file will most importantly define the density of other objects in the scene, the parameters for the truth recorder, and the sensor configurations.

#### Consideration: Sensor Setup

Let's say we wish to capture camera and LiDAR data from an ego. We want the cameras to be spaced out around the ego vehicle so we can get diverse viewing angles of the scene. We'll need to define a set of camera attributes including:
- `sensor_tick`: the interval between sensor captures
- `fov`: field of view of the sensor
- `location`: ego-relative sensor placement
- `rotation`: ego-relative sensor rotation

for all sensors. Also:
- `image_size_x`, `image_size_y` for cameras
- `channels`, `rotation_frequency` for LiDAR

Importantly, the LiDAR's `rotation_frequency` should be the same as the client rate parameter in the same YAML file.

#### Consideration: Occlusion

One of the MAJOR shortcomings to native Carla, in my opinion, is that, given an ego vehicle and an npc character with a bounding box, there is no way to know whether that npc character is viewable by the ego vehicle. To put it more concretely, there is no way to tell if, e.g., there is a building blocking the view of the npc from the ego's point of view. If I'm mistaken here, PLEASE someone let me know, as this would greatly simply a few things...

Anyway, this is actually a very important fact for the generation of a Carla dataset. Specificly, we need to know when training and evaluating our perception algorithms which objects are viewable by the ego or are partially or (more importantly) completely occluded by some element of the scene. To do so, we need to do one of two things: (option 1): include a LiDAR sensor with 360 degree coverage. In post-processing, use the number of LiDAR points inside the bounding box to determine the level of occlusion (i.e., objects behind buildings will have no points in them). This could work except for the fact that it is difficult, nigh impossible, to determine the *level* of occlusion (e.g., unoccluded, partial, most, etc.). Instead, we could do (option 2): include a camera depth sensor at the exact same position as a regular RGB camera. Use the depth image to determine what fraction of the depth values in the object's 2D bounding box projection appear to be at the right depth according to the 3D bounding box. The benefit of this approach is that we can get a much more granular picture of the occlusion of objects. The downside is that, instead of just a centrally mounted LiDAR, we need enough cameras to cover the entire 360 degree field of view. (Has anyone tried a 360 degree field of view camera?). To do so, we take the approach of placing depth cameras at the position of every RGB camera.

#### Consideration: Simulation Speed

We want to be able to execute this data collection as fast as we can. To reduce the burden on the cpus and gpus, we'll disable the pygame display. You may still be able to observe a few things in the Carla docker, but good luck finding the ego vehicle!

#### Putting This Together

All together, we may get a configuration file of something like:

```
---
client:
  rate: 20

display:
  enabled: false

world:
  n_random_vehicles: 300
  n_random_walkers: 0

recorder:
  record_truth: true
  format_as: ['avstack']

infrastructure:
  # use defaults...

ego:
  idx_spawn: 'randint'
  idx_vehicle: 'lincoln'
  idx_destination: null
  roaming: false
  autopilot: true
  respawn_on_done: true
  max_speed: 30
  sensors:
    - camera 0:
        name: 'CAM_FRONT'
        attributes:
          sensor_tick: 0.10
          fov: 90
          image_size_x: 1600
          image_size_y: 900
        save: true
        noise: {}
        transform:
          location:
            x: 1.6
            y: 0
            z: 1.6
          rotation:
            pitch: 0
            yaw: 0
            roll: 0
    - depthcam 0:
        name: 'CAM_FRONT_DEPTH'
        attributes:
          sensor_tick: 0.10
          fov: 90
          image_size_x: 1600
          image_size_y: 900
        save: true
        noise: {}
        transform:
          location:
            x: 1.6
            y: 0
            z: 1.6
          rotation:
            pitch: 0
            yaw: 0
            roll: 0
    - lidar 0:
        name: 'LIDAR_TOP'
        save: true
        attributes:
          sensor_tick: 0.10
          channels: 32
          rotation_frequency: 20  # needs to be the same as sim rate
          range: 100.0
        noise: {}
        transform:
          location:
            x: -0.5
            y: 0
            z: 1.8
```

### EgoVehicleStack Configuration

This is the easy part. For generating a dataset, we just need an autopilot vehicle! We'll want the ego vehicle to explore the town thoroughly and follow most traffic rules. As a result, we can simply invoke the `PassthroughAutopilotVehicle`.

## Running

We'll create a run script that looks like this:
```
#!/usr/bin/env bash

VERSION=${1:-0.9.13}
N_SCENARIOS=${2:-20}
MAX_SCENARIO_LEN=${3:-20}

python exec_standard.py \
    --n_scenarios $N_SCENARIOS \
    --max_scenario_len $MAX_SCENARIO_LEN \
	--config_avstack 'PassthroughAutopilotVehicle' \
	--config_carla 'scenarios/data_capture.yml' \
	--seed 1 \
	--version $VERSION
```

You'll notice that there are a could more parameters, including `N_SCENARIOS` and `MAX_SCENARIO_LEN`. To encourage diversity of scenes and prevent traffic stops from dominating the retained data, we include a max scenario length parameter. Once the scenario hits this number of "simulation-world-seconds", it will restart the simulation entirely, spawning at a new location for the ego and npcs. Similarly, we can set a maximum number of scenarios to capture so that, if you step away from your machine, you don't exhaust the hard drive.


## Postprocessing

After we run the data capture, our results will be saved in a folder called `sim-results` with a subfolder as `run_YYYY_MM_DD_HH:MM:SS`, filling in the start time of the data capture, for each of the scenario runs. More runs will yield more timestamped subfolders. 

To prepare this as a tried and true dataset that respects occlusions and has labels associated with sensor data, we'll need a postprocessing script. Within the `lib-avstack-api` repository, we've included a file called `postprocess_carla_objects.py`. Running this script by passing in the location of the `sim-results` folder will initiate postprocessing on all of the scenes.

For instance, if you are at the location `carla-sandbox/submodules/lib-avstack-api` and you just ran `run_capture_data_random.sh` from the `carla-sandbox/examples` folder, then to perform postprocessing on the newly-generated Carla data, you can run (from a poetry shell or by prepending `poetry run`, of course)
```
python postprocess_carla_objects.py ../../examples/sim-results
```

This postprocessing will do a few things. Specifically, it will:
- Put npc coordinates into an ego-relative coordinate frame
- For each sensor, create a truth file for npcs
- To populate each truth file, filter objects to those within the field of view of each sensor
- On filtered objects, run either lidar-based or depth-image-based occlusion finding and filter objects by occlusion levels.
- Save to a folder called `objects_sensor`

Once you've postprocessed, move your `sim-results` folder to a safe location and call it something else - "my-amazing-carla-dataset" will do... Now, you can manage that dataset just like the KITTI or nuScenes datasets with [`avapi`][avstack-api]. The [`CarlaScenesManager`][carla-dataset] will work like a charm!

[avstack-api]: https://github.com/avstack-lab/lib-avstack-api
[carla-dataset]: https://github.com/avstack-lab/lib-avstack-api/blob/main/avapi/carla/dataset.py