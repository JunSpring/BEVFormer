#!/bin/bash

LOCAL_MMDET3D_PATH="$HOME/mmdetection3d"
LOCAL_BEVFORMER_PATH="$HOME/BEVFormer"

IMAGE_NAME="junspring/bevformer:latest"

docker run --gpus all -it --rm \
    --shm-size=16gb \
    --env=LOCAL_USER_ID="$(id -u)" \
    -v $LOCAL_MMDET3D_PATH:/mmdetection3d \
    -v $LOCAL_BEVFORMER_PATH:/BEVFormer \
    -v /media/junspring/JunSpring/Dataset/nuScenes:/media/junspring/JunSpring/Dataset/nuScenes \
    $IMAGE_NAME /bin/bash
