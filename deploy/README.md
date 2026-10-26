# Controller deployment

Choose exactly one controller profile:

- `jetson-nano`: Jetson Nano with JetPack 4.4.1 / L4T R32 and TensorRT.
- `raspberry-pi4`: Raspberry Pi 4 using the supplied 32-bit ARMv7 SDK.

Each directory contains `Dockerfile`, `compose.yml`, and device-specific
instructions. Edit the camera, server, and token values directly under the
Compose service's `environment` section. Run Compose commands from the
repository root and always pass the selected file with `-f`.

Because the token and RTSP password are stored in `compose.yml`, do not commit
real credentials to a public repository.

Do not run the legacy `anpr.service` and the Docker container simultaneously;
they would open the same streams twice. Validate with `docker compose run`
first, then stop the legacy service immediately before `docker compose up -d`.

## Publish controller images to GHCR

After logging in to GHCR, publish one platform or both from the repository
root:

```bash
ORG=parksmart-tech ./build.sh
```

The root command builds and pushes both images. To publish only one platform:

```bash
ORG=parksmart-tech ./build.sh rpi
ORG=parksmart-tech ./build.sh nano
```

The lower-level commands remain available:

```bash
ORG=parksmart-tech deploy/build-controller-images.sh rpi
ORG=parksmart-tech deploy/build-controller-images.sh nano
ORG=parksmart-tech deploy/build-controller-images.sh all
```

The default version is the current date (`YYYYMMDD`). Set `VERSION` to choose
another version. These scripts use the deployment-specific Dockerfiles, so
the reference controller repository's `MAKE` and `baseArch` arguments are not
needed here.

Each build also updates a platform-specific deployment tag:

- `ghcr.io/parksmart-tech/parksmart-anpr:rpi-latest`
- `ghcr.io/parksmart-tech/parksmart-anpr:jetson-nano-jp441-latest`

The Compose files pull these prebuilt images. Controllers therefore do not
need compilers, OpenCV, Boost, cpprest, or other application dependencies on
the host. Install only Docker on Pi. Jetson also requires the NVIDIA container
runtime included with/supported by its JetPack installation.

## Generate a device runtime key

The images include the SDK's `runtimeKey` utility. Run it on the target device
because the resulting key is bound to that controller's hardware:

```bash
sudo docker compose run --rm --no-deps \
  --entrypoint /opt/ultimatealpr/bin/runtimeKey anpr \
  --json true --assets /opt/ultimatealpr/assets
```

On Jetson Nano this command requires the NVIDIA container runtime. Confirm that
Docker has registered it before generating the key:

```bash
sudo docker info --format '{{json .Runtimes}}'
command -v nvidia-container-runtime
```

If Docker reports `Unknown runtime specified nvidia`, repair the JetPack/NVIDIA
container-runtime installation first, then restart Docker:

```bash
sudo apt-get update
sudo apt-get install --reinstall nvidia-container-runtime
sudo systemctl restart docker
sudo docker info --format '{{json .Runtimes}}'
```

Do not remove `runtime: nvidia` from the Jetson Compose service. The Jetson SDK
loads its TensorRT plugin while generating the hardware key; without the NVIDIA
runtime the container cannot access `libcuda.so` or `libnvinfer.so.7`.

Submit the printed runtime key to the Doubango activation service/portal with
your licensed master or one-time slave activation key. The returned base64
token goes in Compose as `TOKEN_DATA`. A runtime key is not itself a token;
the token cannot be generated locally without activation credentials and the
activation server URL supplied by the license vendor.

## Run the benchmark

Both images include `/opt/ultimatealpr/bin/benchmark`. Run it with Compose by
overriding the normal recognizer entrypoint. On Jetson use TensorRT; on Pi keep
TensorRT, NPU, and OpenVINO disabled. Stop the live ANPR service first if you
want uncontended and comparable performance measurements.
