# Jetson Nano RTSP recognizer container

This packages the ParkSmart RTSP recognizer for Jetson Nano / JetPack 4.4.1.
The executable is linked exactly like the currently deployed build and uses
the JetPack 4.4.1 TensorRT plugin at runtime. Camera credentials and license
tokens are runtime configuration stored in the Compose file and are not baked
into the image.

## Prepare and build on the controller

```bash
# Edit the environment values in deploy/jetson-nano/compose.yml first.
sudo install -d -o 10001 -g 10001 /home/parksmart/anpr/images
deploy/jetson-nano/prepare-models.sh
docker compose -f deploy/jetson-nano/compose.yml pull
```

## Automatic storage cleanup

Install the daily cleanup timer on space-constrained Jetson controllers:

```bash
sudo install -m 0755 deploy/jetson-nano/cleanup-storage.sh \
  /usr/local/sbin/ultimatealpr-storage-cleanup
sudo install -m 0644 deploy/jetson-nano/ultimatealpr-storage-cleanup.service \
  deploy/jetson-nano/ultimatealpr-storage-cleanup.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now ultimatealpr-storage-cleanup.timer
```

The defaults retain seven days of captured ANPR images and run daily around
03:15. Under 1 GiB free, the script also cleans package caches, stopped
containers, unused Docker images older than seven days, and old build cache,
then reduces captured-image retention to one day if necessary. It never
prunes Docker volumes or images used by a container. Override settings in
`/etc/default/ultimatealpr-storage-cleanup`.
Preview image deletions and pressure cleanup without changing anything:

```bash
sudo DRY_RUN=true /usr/local/sbin/ultimatealpr-storage-cleanup
```

Validate without replacing the live systemd service:

```bash
docker compose -f deploy/jetson-nano/compose.yml run --rm anpr
```

After validation, stop the old `anpr.service` before starting the compose
service so two recognizers do not consume the same RTSP streams. Roll back by
stopping compose and starting `anpr.service` again.

The container mounts `/run/udev` and `/dev` read-only because the SDK license
manager derives its runtime key from host hardware. The default configuration
uses `TOKEN_DATA` directly. Do not commit a real token to a public repository.

TensorRT plans are hardware/runtime-specific and are therefore generated on
the controller and mounted read-only rather than baked into the image. The
helper detects L4T R32 directly; it does not depend on `apt-cache` metadata,
which may be missing on minimized controller images.

## Build and publish the controller image

```bash
ORG=himanshu-parksmart deploy/jetson-nano/build-controller-image.sh
```

This publishes
`ghcr.io/himanshu-parksmart/parksmart-anpr:jetson-nano-jp441-vYYYYMMDD`.
It also updates the Compose deployment tag
`ghcr.io/himanshu-parksmart/parksmart-anpr:jetson-nano-jp441-latest`.
