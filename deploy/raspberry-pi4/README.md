# Raspberry Pi 4 RTSP recognizer container

This image targets the 32-bit Raspberry Pi OS userspace (`linux/arm/v7`) and
uses the SDK's Raspbian ARMv7 library. TensorRT, NPU, OpenVINO, GUI preview,
and GPIO-trigger support are disabled in this container profile. Debian
packages are pinned to a Bullseye snapshot so an identical image remains
buildable after Bullseye packages rotate off the normal mirrors.

```bash
# Edit the environment values in deploy/raspberry-pi4/compose.yml first.
sudo install -d -o 10001 -g 10001 /home/parksmart/anpr/images
docker compose -f deploy/raspberry-pi4/compose.yml pull
docker compose -f deploy/raspberry-pi4/compose.yml up -d
docker compose -f deploy/raspberry-pi4/compose.yml logs -f --tail=100
```

For a 64-bit Raspberry Pi OS installation, this ARMv7 image can normally run
when the kernel has 32-bit compatibility enabled. Otherwise use a 32-bit OS,
because this repository only contains a Raspberry Pi ARMv7 SDK library.

The RTSP password and license token are stored directly in `compose.yml`; do
not commit real credentials to a public repository.

## Build and publish the controller image

Log in to GitHub Container Registry, then run the supplied Buildx script:

```bash
echo "$GHCR_TOKEN" | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
ORG=parksmart-tech deploy/raspberry-pi4/build-controller-image.sh
```

By default, it publishes
`ghcr.io/parksmart-tech/parksmart-anpr:rpi-vYYYYMMDD`. Override the tag date with
`VERSION`, for example `VERSION=20261020`.
The script also updates the Compose deployment tag
`ghcr.io/parksmart-tech/parksmart-anpr:rpi-latest`.
