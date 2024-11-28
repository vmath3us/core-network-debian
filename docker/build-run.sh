#!/bin/bash
### podman build . -t debian-core-gui  --format=docker --layers=true
docker build . -t debian-core-gui --progress=plain
export PASS=$(uuidgen)
docker run \
    --name debian-core-gui \
    --env PASS="${PASS}" \
    --privileged \
    --name debian-core-gui \
    -v debian-core-gui-home:/home/debian \
    -p 127.0.0.1:15000:15000 \
    -d \
    debian-core-gui
docker logs -f debian-core-gui
