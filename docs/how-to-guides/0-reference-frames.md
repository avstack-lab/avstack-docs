# Reference (Coordinate) Frames

AV dataset providers often overlook reference frame consistency when providing usable APIs. While it is clear each sensor has its own transformation to the vehicle origin, dataset providers put the burden on the developer to perform tedious and error-prone reference frame transformations when comparing information from multiple sensors. Furthermore, coordinates historically tended to be centered at an ego-relative frame. Howevever, when you start introducing global vehicle localization algorithms and multi-agent collaboration, you no longer have a centralized ego vehicle to reference on. Moreover, dynamical models of object trajectories are not valid in an accelerating reference frame. Therefore, if we are considering an ego-relative coordinate frame and attempting to track object trajectories, our dynamical models will fail.


## Reference Frame Chain of Command

The AVstack team designed the Reference Frame Chain of Command (`refchoc`) to maintain a computationally-efficient trail of reference frame history. Through the `refchoc`, we maintain that raw sensor data, object states, detections, tracks, and all physically-oriented data structures base their information on standardized reference frames.


### Transforming Reference Frames

Here we provide examples describing how to use `refchoc` to transform the coordinate system of an object. An example of transforming a position datastructure is:

```
import numpy as np
import avstack

# the base reference frame of x=[0,0,0], q=[1,0,0,0]
RB = avstack.geometry.GlobalOrigin3D

# a new reference frame based on RB
R1 = avstack.geometry.ReferenceFrame(x=np.random.rand(3), q=np.quaternion(1), reference=RB)
R2 = avstack.geometry.ReferenceFrame(x=np.random.rand(3), q=np.quaternion(1), reference=RB)

# position initially defined in R1 coordinate system
position = avstack.geometry.Position(x=np.random.rand(3), reference=R1)
print(position)

# convert that same position to the new coordinate frame
position.change_reference(R2, inplace=True)
print(position)
```
Check out the [core library reference frame tests][core-ref-tests] for more examples.

### Optimizations

We have implemented several optimizations that help the `refchoc` system reduce computational overhead. We will fill this in with details later...


[core-ref-tests]: https://github.com/avstack-lab/lib-avstack-core/blob/main/tests/geometry/test_refchoc.py