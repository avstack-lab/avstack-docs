# Understanding Objects and Classes

As we begin, it will be helpful to understand important classes and objects

## Physical Objects

#### Object State

A base `ObjectState` class defines physical objects in the 3D world. Commonly found objects such as vehicles, pedestrians, and cyclists each have classes that base on `ObjectState`. Each defines object-specific quantitites that are useful for representing the world.

#### 3D Bounding Box

Objects in physical space can be localized with a 3D bounding box. This box is specified as a tuple of `(h, w, l, x, q, ref)` where `(h, w, l)` are box dimensions, `x=(x, y, z)` is a `Position` object describing the box center relative to the reference frame, `q` is an `Attitude` object describing the box center rotation relative to the reference frame, and `ref` is the `ReferenceFrame` object that describes the position and orientation of the coordinates. AVstack makes use of the 3D bounding box often in perception, tracking, motion prediction, and planning.

#### 2D Bounding Box

Similarly, it is common to find a two-dimensional projection of AV data - e.g., camera is a front-view projection; bird's-eye view is a top-down projection. In these cases, a 2D bounding box is an appropriate representation of an object. 2D bounding boxes are specified as a tuple of `(x_min, y_min, x_max, y_max, calibration)` where the first four elements describe the bounding box in pixel space and `calibration` is a `CameraCalibration` object that contains intrinsic and reference frame attributes of the camera used.

#### 2D Segmentation Mask

Finally, a segmentation mask can be used for pixel-level or point-wise classification and identification. AVstack makes use of segmentation masks in perception to obtain high-quality object locations. The segmentation mask data structure is implemented but it is not yet fully settled on the best data structure.

## Ego Vehicles

The ego vehicle (main character) is composed of a physical and a software component. On the physical side, the state of the ego vehicle is represented as a `VehicleState`. On the software side, the interworkings of communication networks and AV algorithms are represented with a a `VehicleEgoStack`. Derived classes from `VehicleEgoStack` define what data the AV ingests, how inference is performed on data, and how this information is used to control the vehicle through the environment. A major contribution of AVstack is that the ego's algorithms are flexible - they can be stitched together to easily create different realizations of ego behavior.

## Sensor Data

We found that the best way to integrate a diverse array of datasets and simulators was to standardize the representation of sensor data. Furthermore, it is often overlooked that a key component of data is the calibration information associated with the sensor when data were captured. Prior efforts at integrating multiple datasets failed to realize that the most important part of modularity is understanding calibration transformations. As a result, our data classes are made up of both the raw sensor data and the sensor calibration information on every single instantiation. 

<br/>