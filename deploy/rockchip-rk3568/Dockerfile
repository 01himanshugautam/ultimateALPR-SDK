FROM ubuntu:22.04 AS build

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    g++ pkg-config libboost-system-dev libboost-thread-dev libcpprest-dev \
    libcurl4-openssl-dev libopencv-dev libssl-dev rapidjson-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /src/recognizer
COPY c++/ultimateALPR-SDK-API-PUBLIC.h /src/c++/
COPY samples/c++/stb_image.h /src/stb_image.h
COPY samples/c++/recognizer/recognizer.cxx /src/recognizer/recognizer.cxx
COPY binaries/linux/aarch64/libultimate_alpr-sdk.so /src/lib/

# RK3568 is ARMv8-A. The SDK has no RKNN plugin, so this build uses its
# generic AArch64/NEON CPU backend.
RUN g++ /src/recognizer/recognizer.cxx -O3 -pthread -march=armv8-a \
    -I/src/c++ -L/src/lib -Wl,-rpath,/opt/ultimatealpr/lib \
    -lultimate_alpr-sdk $(pkg-config opencv4 --cflags --libs) \
    -lcurl -lboost_system -lboost_thread -latomic -lcpprest -lssl -lcrypto \
    -o /src/recognizer/recognizer

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    LD_LIBRARY_PATH=/opt/ultimatealpr/lib
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates libboost-system1.74.0 libboost-thread1.74.0 \
    libcpprest2.10 libcurl4 libopencv-core4.5d libopencv-highgui4.5d \
    libopencv-imgcodecs4.5d libopencv-imgproc4.5d libopencv-videoio4.5d \
    libssl3 \
 && rm -rf /var/lib/apt/lists/*

COPY --from=build /src/recognizer/recognizer /opt/ultimatealpr/bin/recognizer
COPY binaries/linux/aarch64/libultimate_alpr-sdk.so /opt/ultimatealpr/lib/
COPY assets /opt/ultimatealpr/assets
COPY deploy/rockchip-rk3568/entrypoint.sh /usr/local/bin/ultimatealpr-entrypoint

RUN chmod 0755 /opt/ultimatealpr/bin/recognizer /usr/local/bin/ultimatealpr-entrypoint \
 && useradd --system --uid 10001 --create-home anpr \
 && mkdir -p /home/parksmart/anpr/images \
 && chown -R anpr:anpr /home/parksmart/anpr

USER anpr
ENTRYPOINT ["/usr/local/bin/ultimatealpr-entrypoint"]
