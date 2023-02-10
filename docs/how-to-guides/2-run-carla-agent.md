# Run CARLA Agent

Many users of `AVstack` will find that the expanded API for the [Carla][carla] simulator is one of its best contributions. While Carla does provide its users with a [Python API][carla-api], we found it to be lacking in many essential features. Among those shortcomings were a lack of direction about running perception, ambiguous and non-standard coordinate conventions, hard-coding ground-truth information into "planning" algorithms, and others. Our [Carla sandbox][carla-sandbox] brings together the [avstack][avstack-core] and [avapi][avstack-api] libraries.


## Getting Started

### Requirements

If you plan to run the software directly on your machine, you'll need a Linux machine. We are actively working on a docker container so that the sandbox code can be run through docker. In the sandbox, the Carla simulator will always run through a docker container, so there is no requirement there, other than a GPU and [`nvidia-container-toolkit`][nvidia-toolkit].

### Installation

Follow the installation instructions at the [sandbox README][carla-sandbox] to install the sandbox, necessary dependencies, and necessary submodules. Instructions are in the [sandbox README][carla-sandbox].

### Quickstart

One you've completed the installation, you can run a quick built-in example with the folowing procedure via two terminal windows.

In terminal 1, start up the Carla 0.9.13 Docker container:
```
cd run_carla
./run_carla_0913.sh
```

In terminal 2, run an agent, making sure to activate a [`poetry`][poetry] shell first.
```
poetry shell
cd examples
./run_autopilot.sh
```

You should now see a pygame window appear and the ego should be moving around in an environment on autopilot mode.


## More Pre-built Configurations

Of course, we will want to run more than just an autopilot vehicle. Here, we descibe additional pre-baked configurations we have made for a few different use cases. The following assume you have already run `poetry shell` and are in the `examples` folder.

### Carla's Provided Manual Control

In terminal 2, run: `python manual_control.py`. This uses the carla-provided manual control script and allows you to control the ego vehicle with your keyboard.

### Autopilot With Perception

In terminal 2, run: `./run_autopilot_camera_perception.sh`. This runs autopilot and has a camera perception process running alongside it.

### Go-Straight Ego Vehicle

In terminal 2, run `./run_go_straight_agent.sh`. As it sounds, this agent is only capable of planning to go straight.

## Building a Custom Configuration

Now we'll describe how to create your own AV configurations to open up endless possibilities!

### Step 1: Create carla scenario file

To run a scenario, you need a carla scenario file. This is a YAML file that describes the client, world, display, recording, infrastructure, npc, and ego configurations. There are many options for how to configure an ego agent with sensors, so refer to some existing examples. Some example configuration files are located in the [AVstack Carla config folder][avstack-api-carla-config]. A base configuration for a scenario may look like this:
```
# base_av.yml
---
client:
  rate: 20

display:
  # use defaults...

world:
  n_random_vehicles: 200
  n_random_walkers: 0

recorder:
  record_truth: false

infrastructure:
  # use defaults...

ego:
  idx_spawn: 'random'
  idx_vehicle: 'lincoln'
  idx_vehicle: 0
  idx_destination: 'random'
  roaming: true
  autopilot: false
  respawn_on_done: true
  max_speed: 20  # m/s
  sensors:
    - camera 0:
        name: 'camera-0'
        save: false
    - gnss 0:
        name: 'gnss-0'
        save: false
    - imu 0:
        name: 'imu-0'
        save: false
```
Here, we have created a client that will output sensor data and process ego ticks at 20 Hz. In synchronous mode, this means that whenever we call a `tick()`, we'll get a 0.05 second progression in the world. Our world will spawn at most 200 "other" vehicles in random positions in the world. As for our ego, we'll start in a random location and nominally have a random destination (although some egos do not take a destination at all; this depends on their planning). We'll allocate three sensors for this scenario file. The scenario file's top-level keys (i.e., "client", "display", "world", etc.) are all pre-initialized with a set of default values. Their default configurations are also in the [AVstack Carla config folder][avstack-api-carla-config] - you should take a look at these closely to understand which settings you want.

### Step 2: Create avstack ego AV

To create an ego vehicle, you must subclass from the `VehicleEgoStack`. The high-level requirements are that this class must implement `_initialize_modules()` and `_tick_modules()` methods. This desribes how to initialize the ego vehicle and how to evaluate the ego on each frame, respectively. The `GoStraightEgo` could look something like this, if it lived in the [vehicle ego file][avstack-ego]: 
```
class GoStraightEgo(VehicleEgoStack):
    """A silly ego vehicle that just goes straight"""

    def _initialize_modules(self, *args, **kwargs):
        self.plan = modules.planning.WaypointPlan()
        self.planning = modules.planning.vehicle.GoStraightPlanner()
        ctrl_lat = {"K_P": 1.2, "K_D": 0.1, "K_I": 0.02}
        ctrl_lon = {"K_P": 1.0, "K_D": 0.2, "K_I": 0.2}
        self.control = modules.control.vehicle.VehiclePIDController(ctrl_lat, ctrl_lon)

    def _tick_modules(
        self, frame, timestamp, data_manager, ground_truth, *args, **kwargs
    ):
        ego_state = ground_truth.ego_state
        self.plan = self.planning(self.plan, ego_state)
        ctrl = self.control(ego_state, self.plan)
        return ctrl

    def set_destination(self, *args, **kwargs):
        print('This ego does not take a destination')
```

Notice here that we only need planning and control components for this ego. We don't even need to bother implementing perception. We could implement localization, but instead, we'll just use the ground truth ego position.


### Step 3: Create run script

The run script must specify the location of the scenario file (relative to the [default config folder][avstack-api-carla-config]). It also must specify the name of the specific ego implementation and must be located in the [avstack ego folder][avstack-ego]. An example run script might look like the following:

```
#!/usr/bin/env bash
# ---- this is run_go_straight_agent.sh located in carla-sandbox/examples

source setup_for_standard.bash

python exec_standard.py \
    --config_avstack 'GoStraightEgo' \
    --config_carla 'scenarios/base_av.yml' \
    --seed 1 \
    --remove_data
```

### Step 4: Run!

Run through the terminal with e.g., `./run_go_straight_agent.sh`. 

## Shortcomings (For Now)

There are a few important shortcomings that we should highlight.

- Functional Examples: There are a limited number of "functional" example full-stack egos because we are not experts in planning and thus have few planning algorithms implemented. We would appreciate if development efforts could be focused on improving the planning modules.
- Minimal Threading: The execution speed is significantly slowed when data is to be saved (using the "recorder" configuration). It would help speeds a great deal if this recording could be done in a multi-threaded fashion.
- Slow Execution Rates: Depending on your desired AV configuration, the execution rate of the simulation and system may not be great (whatever your definition of this may be). This can be due to many factors, some of which include: the computation overhead of computing reference frame transformations, minimal threading, lack of multi-processing, high-resource-using algorithms, etc.. I hope we can all work to improve this in the future! One important note: don't try to feed too many objects to a tracking module. The assignment algorithm will be quite slow, and it's pretty unnecessary to track objects more than a certain distance away for most applications.


[carla]: https://carla.org/
[carla-api]: https://github.com/carla-simulator/carla/tree/master/PythonAPI
[avstack-core]: https://github.com/avstack-lab/lib-avstack-core
[avstack-api]: https://github.com/avstack-lab/lib-avstack-api
[carla-sandbox]: https://github.com/avstack-lab/carla-sandbox
[nvidia-toolkit]: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html
[poetry]: https://github.com/python-poetry/poetry
[avstack-api-carla-config]: https://github.com/avstack-lab/lib-avstack-api/tree/main/avapi/carla/config
[avstack-ego]: https://github.com/avstack-lab/lib-avstack-core/blob/main/avstack/ego/vehicle.py
