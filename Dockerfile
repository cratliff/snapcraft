FROM ubuntu:xenial

# Enable multiverse as snapcraft cleanbuild does.
RUN sed -i 's/ universe/ universe multiverse/' /etc/apt/sources.list

RUN apt-get update && \
  apt-get dist-upgrade --yes && \
  apt-get autoclean --yes && \
  apt-get clean --yes

# Install snapcraft dependencies
RUN apt-get install git sudo libslang2-dev python-pip python3-pip gcc g++ make python3-dev python3-venv libffi-dev \
  libsodium-dev libapt-pkg-dev libarchive13 squashfs-tools patchelf --yes && \
  apt-get autoclean --yes && \
  apt-get clean --yes

ADD ./ /snapcraft

RUN mkdir -p /venv/snapcraft && \
python3 -m venv /venv/snapcraft && \
. /venv/snapcraft/bin/activate && \
pip --no-cache-dir install wheel && \
pip --no-cache-dir install -r /snapcraft/requirements.txt


ADD docker-files/snapcraft /bin/snapcraft

RUN echo  "deb [trusted=yes] http://aptly:8080 xenial main" > /etc/apt/sources.list
# Required by click.
ENV LC_ALL=C.UTF-8 SNAPCRAFT_SETUP_CORE=1
# Produce manifest file
ENV SNAPCRAFT_BUILD_INFO=1
