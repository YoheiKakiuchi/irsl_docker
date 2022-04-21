#!/bin/bash

OPT=${DOCKER_OPTION} ## -it --cpuset-cpus 0-2
iname=${DOCKER_IMAGE:-"___docker_image___"} ##
cname=${DOCKER_CONTAINER:-"run_by_irsl_scripts"} ## name of container (should be same as in exec.sh)

DEFAULT_USER_DIR="$(pwd)"
mtdir=${MOUNTED_DIR:-$DEFAULT_USER_DIR}

userdir=${USER_DIR:-/userdir}

VAR=${@:-"bash"}
if [ $# -eq 0 -a -z "$OPT" ]; then
    OPT=-it
fi

if [ "$NO_GPU" = "" ]; then
    GPU_OPT='--gpus all,"capabilities=compute,graphics,utility,display"'
else
    GPU_OPT=""
fi

## --net=mynetworkname
## docker inspect -f '{{.NetworkSettings.Networks.mynetworkname.IPAddress}}' container_name
## docker inspect -f '{{.NetworkSettings.Networks.mynetworkname.Gateway}}'   container_name

NET_OPT="--net=host"
# for gdb
#NET_OPT="--net=host --env=DOCKER_ROS_IP --env=DOCKER_ROS_MASTER_URI --cap-add=SYS_PTRACE --security-opt=seccomp=unconfined"

_ENVIRONMENT_VAR=${DOCKER_ENVIRONMENT_VER:-""}

##xhost +local:root
xhost +si:localuser:root

docker rm ${cname}

docker run ${OPT}    \
    --privileged     \
    ${GPU_OPT}       \
    ${NET_OPT}       \
    ${_ENVIRONMENT_VAR} \
    --env="DISPLAY"  \
    --env="QT_X11_NO_MITSHM=1" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --name=${cname} \
    --volume="${mtdir}:${userdir}" \
    -w="${userdir}" \
    ${iname} ${VAR}

##xhost -local:root

## capabilities
# compute	CUDA / OpenCL アプリケーション
# compat32	32 ビットアプリケーション
# graphics	OpenGL / Vulkan アプリケーション
# utility	nvidia-smi コマンドおよび NVML
# video		Video Codec SDK
# display	X11 ディスプレイに出力
# all

## ___docker_image___
## VAR=${@:-"bash"}
## DOCKER_ENVIRONMENT_VAR=""
