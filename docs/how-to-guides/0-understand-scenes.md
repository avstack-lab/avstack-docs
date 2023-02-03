# Understanding Scenes

Now that we understand objects, let's discuss the scenes that those objects compose. 

## Data As Longitudinal Scenes

One of the most frustrating characteristic of some benchmark datasets is that they treat scenes as isolated snapshots of data rather than as longitudinal sequences. When we first started working with AV datasets, [KITTI][kitti-dataset] was king. But to our dismay, it was a rarity to find developers using [KITTI][kitti-dataset] as longitudinal sequences (i.e., using the [raw dataset][kitti-raw]).

We started our AVstack as a simple way to leverage the KITTI raw dataset for perception, tracking, and motion prediction. After developing a set of useful classes for managing AV data, we found the approach easily generalized to other AV datasets. Next, we describe the most important commonalities of data as longitudinal scenes.

### Object States

Each object in the scene comes with ground-truth object information. This is a non-negotiable. Think of objects in the scene as Markovian: next-states are a function of a transition function over current states. Fully specifying this relationship requires a detailled treatment of object state - more detailled than the basic APIs for [KITTI][kitti-dataset] will give you.

### Ego State

Each scene also specifies the state of the ego, if possible. Some datasets are ego-relative while others provide coordinates in a semi-global frame (e.g., relative to a fixed starting point). Incorporating the ego state is useful and must be done for an accurate treatment of object dynamics.

### Sensor Data

As previously described, it is important to bestow sensor data with as much calibration data as is possible. This is essential for understanding how to relate information between different sensor platforms, between sensor modalities, across individual frames, or across entire scenes. 

## Managing Scenes

With an understanding of data as a longitudinal scene, we now describe the implementation details on how we choose to represent scenes. At a high-level, each dataset is allocated a `SceneManager` which manages the spawning of `SceneDatasets` representing a single, continuous longitudinal capture. 

### Scene Manager

We integrate nuScenes, KITTI, and CARLA with a common `SceneManager` class. This manager handles metadata over individual scenes and helps us to select a scene for analysis based on a set of our desired characteristics (e.g., choose a night scene, a scene with many objects). 

### Scene Dataset

A `SceneManager` will spawn a `SceneDataset` instance that handles frames of object states, ego state, and sensor data over a longitudinal sequence. All scene datasets across the different integrated datasets utilize the same base `SceneDataset` class. This greatly simplifies the process of integrating other datasets and simulators.


[kitti-dataset]: https://www.cvlibs.net/datasets/kitti/
[kitti-raw]: https://www.cvlibs.net/datasets/kitti/raw_data.php