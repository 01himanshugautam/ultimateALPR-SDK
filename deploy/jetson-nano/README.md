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
ORG=parksmart-tech deploy/jetson-nano/build-controller-image.sh
```

This publishes
`ghcr.io/parksmart-tech/parksmart-anpr:jetson-nano-jp441-vYYYYMMDD`.
It also updates the Compose deployment tag
`ghcr.io/parksmart-tech/parksmart-anpr:jetson-nano-jp441-latest`.
