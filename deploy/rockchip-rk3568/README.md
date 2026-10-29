# Rockchip RK3568 container

This target builds the ParkSmart streaming recognizer on Ubuntu 22.04 ARM64.
The bundled ultimateALPR SDK has no Rockchip RKNN backend or RKNN models, so
the recognizer intentionally uses the generic AArch64/NEON CPU backend. The
RK3568 NPU is not used.

Build and publish from the repository root:

```bash
ORG=himanshu-parksmart ./build.sh rockchip
```

Build and load locally without publishing:

```bash
deploy/rockchip-rk3568/build-controller-image.sh
```

The ParkSmart RK3568 firmware must run this image with its vendor
`rk3568-runc` runtime. This is set in `compose.yml`. Its kernel does not expose
POSIX mqueue support, so standard `runc` fails while creating containers.

Set `PUSH=true` to publish both the dated and `latest` tags when invoking the
platform script directly. Configure camera
URLs and the hardware-bound SDK token in `.env` beside `compose.yml`:

```dotenv
RTSP_URLS=rtsp://camera-one,rtsp://camera-two
SERVER_URLS=127.0.0.1
PORTS=9898
LOG_TYPES=ENTRY,EXIT
DESCRIPTIONS=Entry,Exit
RELAYS=-1,-1
ROIS=0.1,0.1,0.8,0.8;0.1,0.1,0.8,0.8
TOKEN_DATA=replace-with-controller-token
```

Stop the legacy `anpr.service` before starting Compose so both recognizers do
not consume the same RTSP streams:

```bash
sudo systemctl stop anpr.service
docker compose -f deploy/rockchip-rk3568/compose.yml up -d
```
