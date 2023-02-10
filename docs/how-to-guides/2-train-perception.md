# Train Perception Algorithm

Let's say you want to train a new detection algorithm on a dataset you have. Or, maybe you want to train a model you already have on a new dataset you just generated (perhaps a newly-generated Carla dataset). In that case, you'll be wondering how to run a training process. In this guide, we'll walk you through this process. We make use of the existing training protocols in [MMDetection2D][mmdet-2d] and [MMDetection3D][mmdet-3d].

## Camera-Based 2D Object Detection

In the space of camera-based 2D detection, you'll hear algorithms like faster-rcnn, YOLO, or mask-rcnn. These are time-tested algorithms that have, generally speaking, good performance.

### Dataset Preparation
The first step in training an algorithm is to prepare the dataset of choice. If you're reading this guide, you're likely interested in a dataset compatible with AVstack! If so, that's great, because in our fork of [MMDetection2D][mmdet-2d], we've included an easy set of utilities to convert AVstack-compatible data into the COCO image format. Just check out the [our custom folder][custom-folder]. For example, converting KITTI to the COCO format is as simple as running:
```
python3 convert_any_avstack_labels.py 'kitti' '/data/spencer/KITTI/object'
```
because of the standardized way AVstack handles datasets.

### Model Preparation
To prepare a model, you'll need to generate a config file. We've added a few config files that you might find useful. Check out the config for [`faster-rcnn on CARLA`][faster-rcnn-carla]. Since we convert to the COCO format, we can use the COCO base file.

### Training
Back to our [custom files][custom-folder], we've made simple shell scripts for running the training process. Honestly, you don't even need this custom files. You can just run something like:
```
python tools/train.py configs/kitti/faster_rcnn_r50_fpn_1x_kitti.py
```
from the root of the mmdetection folder (e.g., `lib-avstack-api/third-party/mmdetection/`). 


## LiDAR-Based 3D Object Detection

Coming soon!

## Camera-Based 3D Object Detection (Monocular)

Coming soon!

## Camera-Based 3D Object Detection (Stereo)

Coming soon!


[mmdet-2d]: https://github.com/avstack-lab/mmdetection
[mmdet-3d]: https://github.com/avstack-lab/mmdetection3d
[custom-folder]: https://github.com/avstack-lab/mmdetection/tree/mod-v1/CUSTOM
[faster-rcnn-carla]: https://github.com/avstack-lab/mmdetection/blob/mod-v1/configs/carla/faster_rcnn_r50_fpn_1x_carla.py