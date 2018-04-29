#!/bin/bash

# remove snapcraft since it is being used from source

# libcurl is removed because of this bug
# https://bugs.launchpad.net/ubuntu/+source/curl/+bug/1668741
sudo apt remove snapcraft libcurl4-gnutls-dev libcurl4-openssl-dev -y

# Install snapcraft dependencies and packages removed from libcurl
sudo apt install gcc g++ make python3-dev python3-venv libffi-dev \
libsodium-dev libapt-pkg-dev libarchive13 squashfs-tools patchelf \
build-essential liblzma-dev  libffi6 libmagic1 libsodium18 xdelta3 libssl-dev \
gettext libbz2-dev  libdb-dev liblz4-dev zlib1g-dev texinfo \
ros-kinetic-desktop-full libdap-dev libgdal-dev libhdf4-alt-dev libnetcdf-dev \
libpcl-dev libvtk6-dev libvtk6-qt-dev ros-kinetic-base-local-planner \
ros-kinetic-camera-calibration ros-kinetic-carrot-planner \
ros-kinetic-clear-costmap-recovery \
ros-kinetic-compressed-depth-image-transport \
ros-kinetic-compressed-image-transport ros-kinetic-costmap-2d \
ros-kinetic-cv-bridge ros-kinetic-depth-image-proc \
ros-kinetic-dwa-local-planner ros-kinetic-global-planner \
ros-kinetic-image-cb-detector ros-kinetic-image-geometry \
ros-kinetic-image-pipeline ros-kinetic-image-proc ros-kinetic-image-publisher \
ros-kinetic-image-rotate ros-kinetic-image-transport-plugins \
ros-kinetic-image-view ros-kinetic-laser-cb-detector \
ros-kinetic-laser-ortho-projector \
ros-kinetic-laser-scan-matcher ros-kinetic-move-base \
ros-kinetic-move-slow-and-clear ros-kinetic-nav-core \
ros-kinetic-navfn ros-kinetic-navigation ros-kinetic-opencv3 \
ros-kinetic-pcl-conversions ros-kinetic-pcl-ros ros-kinetic-perception \
ros-kinetic-perception-pcl ros-kinetic-rotate-recovery \
ros-kinetic-rqt-common-plugins ros-kinetic-rqt-image-view \
ros-kinetic-stereo-image-proc ros-kinetic-theora-image-transport \
ros-kinetic-vision-opencv ros-kinetic-desktop-full \
ros-kinetic-gazebo-ros-control ros-kinetic-hector-gazebo-plugins -y

# chown on files that might be owned by root from using snapcraft with sudo
sudo chown `whoami` -R ~/.cache/snapcraft
sudo chown `whoami` -R ~/.ros

mkdir -p `pwd`/venv/snapcraft
python3 -m venv `pwd`/venv/snapcraft
source `pwd`/venv/snapcraft/bin/activate

pip install wheel
pip install -r requirements.txt .

sudo echo """#!/bin/bash

source `pwd`/venv/snapcraft/bin/activate
python3 `pwd`/bin/snapcraft \$@
deactivate
""" > snapcraft.sh
sudo mv snapcraft.sh /usr/bin/snapcraft
sudo chmod +x /usr/bin/snapcraft
