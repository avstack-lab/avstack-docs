# Spinning Up

If you're first starting out with AVstack, you'll be wondering...*where do I begin?* Here, we'll walk you through the high-level structure of the AVstack family of repositories. Finally, we'll describe some common use-cases when AVstack can help accelerate autonomous vehicle development; for more use-case details, see the how-to guides at the left.

## Core

The core library is data-source agnostic. We say "data-source" because AVstack is compatible with datasets, simulators, and hardware. For this reason, AVstack has designed data-source agnostic data structures that capture many of the most common use cases for autonomy.

Find the high-level organization below.
```
<ego>
    vehicle
    drone
<environment>
    lights
    objects
    signs
    traffic
<geometry>
    bbox
    coordinates
    datastructs
    planes
    refchoc
    transformations
<modules>
    <control>
    <fusion>
    <localization>
    <perception>
    <planning>
    <prediction>
    <tracking>
    assignment
<utils>
calibration
datastructs
exceptions
maskfilters
messages
sensors
```
As a result of the data-source agnostic design decision, we will not be invoking any dataset or simulator in particular when describing the core functionality. On the other hand, the documentation for the API has plenty of source-specific examples.

## Core + API

The API library provides a consistent interface for interacting with AV data of all types. It can easily be extended for forward-compatibility. 

```
<carla>
    dataset
    <simulator>
<evaluation>
    perception
    prediction
    tracking
    trades
<kitti>
<mot15>
<nuimages>
<nuscenes>
<opv2v>
<visualize>
_dataset
```

#### Datasets
All datasets base on the base dataset class.

#### Evaluation
Evaluation provides useful data managers for performing binary analysis (TP, FP, FN, TN) with assignment algorithms to compare e.g., detections with truths. It also integrates third-party metrics to obtain a deeper level of insight on module performance.

#### Visualize
Visualization allows for replay of sensor data along with ground-truth or detection-outcome overlays. It's incredibly useful for debugging and validating module outcomes.


## Core + API + Carla

Perhaps one of the most frustration-liberating contributions of AVstack is that it streamlines and simplifies the process of using the CARLA simulator. The CARLA team provides [an API][carla-api], but their API is lacking many important features. It's planning "algorithms" have *deeply baked* dependencies on ground-truth data. And regarding perception...well there isn't any! There's no clear way *at all* to run DNN-based perception on the CARLA simulator. Instead, the [carla API][carla-api] moreso serves as the bare-bones "type-hinting" for you to go off and make your own code. But that's crazy! We needed something standardized.

With pre-bundled python egg files, running CARLA can be accomplished in just a few minutes, if you have enough computation capabilities. Even better, you can use the exact same AVstack routines for both datasets and simulators. 


## Use Cases

You would want to use AVstack in, but not limited to, the following cases:

- Analyze a new algorithm on AV datasets
- Perform trade-studies of sensor fusion designs
- Transition algorithms from datasets to simulators
- Train a new perception algorithm on AV data
- Have a *much* better experience using AV simulators
- Generate your own dataset using AV simulators
- Dig into collaborative (vehicle-to-vehicle, vehicle-to-infrastructure) scenarios
- Set up multi-agent case studies in AV simulators

<br/><br/>

[carla-api]: https://github.com/carla-simulator/carla/tree/master/PythonAPI