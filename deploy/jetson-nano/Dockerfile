FROM nvcr.io/nvidia/l4t-base:r32.4.4 AS build

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    g++ libboost-system-dev libboost-thread-dev libcpprest-dev \
    libcurl4-openssl-dev libopencv-dev libssl-dev rapidjson-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /src/recognizer
COPY c++/ultimateALPR-SDK-API-PUBLIC.h /src/c++/
COPY samples/c++/stb_image.h /src/stb_image.h
COPY samples/c++/recognizer/recognizer.cxx /src/recognizer/recognizer.cxx
COPY samples/c++/alpr_utils.h /src/alpr_utils.h
COPY binaries/jetson/aarch64/libultimate_alpr-sdk.so /src/lib/

RUN g++ /src/recognizer/recognizer.cxx -O3 -pthread -DJETSON \
    -I/src/c++ -L/src/lib -Wl,-rpath,/opt/ultimatealpr/lib \
    -lultimate_alpr-sdk $(pkg-config opencv --cflags --libs) \
    -lcurl -lboost_system -lboost_thread -latomic -lcpprest -lssl -lcrypto \
    -o /src/recognizer/recognizer

FROM nvcr.io/nvidia/l4t-base:r32.4.4

ENV DEBIAN_FRONTEND=noninteractive \
    LD_LIBRARY_PATH=/opt/ultimatealpr/lib
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl gnupg \
 && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://repo.download.nvidia.com/jetson/jetson-ota-public.asc \
      | apt-key add - \
 && echo "deb https://repo.download.nvidia.com/jetson/t210 r32.4 main" \
      > /etc/apt/sources.list.d/nvidia-l4t-r32.4.list \
 && echo "deb https://repo.download.nvidia.com/jetson/common r32.4 main" \
      >> /etc/apt/sources.list.d/nvidia-l4t-r32.4.list \
 && apt-get update && apt-get install -y --no-install-recommends \
    libboost-system1.65.1 libboost-thread1.65.1 \
    libcpprest2.10 libcurl4 libopencv-core3.2 libopencv-highgui3.2 \
    libopencv-imgcodecs3.2 libopencv-imgproc3.2 libopencv-videoio3.2 \
    libssl1.1 udev \
    cuda-nvrtc-10-2=10.2.89-1 \
    libnvinfer7=7.1.3-1+cuda10.2 \
    libnvinfer-plugin7=7.1.3-1+cuda10.2 \
    libnvparsers7=7.1.3-1+cuda10.2 \
    libnvonnxparsers7=7.1.3-1+cuda10.2 \
 && rm -rf /var/lib/apt/lists/*

COPY --from=build /src/recognizer/recognizer /opt/ultimatealpr/bin/recognizer
COPY binaries/linux/aarch64/benchmark /opt/ultimatealpr/bin/benchmark
COPY binaries/jetson/aarch64/runtimeKey /opt/ultimatealpr/bin/runtimeKey
COPY binaries/jetson/aarch64/libultimate_alpr-sdk.so /opt/ultimatealpr/lib/
COPY binaries/jetson/aarch64/libonehot.so.7.1 /opt/ultimatealpr/lib/
COPY binaries/jetson/aarch64/libultimatePluginTensorRT.so.4.4.1 /opt/ultimatealpr/lib/
COPY assets /opt/ultimatealpr/assets
COPY deploy/jetson-nano/entrypoint.sh /usr/local/bin/ultimatealpr-entrypoint

RUN chmod 0755 /opt/ultimatealpr/bin/recognizer /opt/ultimatealpr/bin/benchmark /opt/ultimatealpr/bin/runtimeKey /usr/local/bin/ultimatealpr-entrypoint \
 && ln -s libultimatePluginTensorRT.so.4.4.1 /opt/ultimatealpr/lib/libultimatePluginTensorRT.so \
 && useradd --system --uid 10001 --create-home anpr \
 && mkdir -p /home/parksmart/anpr/images \
 && chown -R anpr:anpr /home/parksmart/anpr

WORKDIR /opt/ultimatealpr/lib
USER anpr
ENTRYPOINT ["/usr/local/bin/ultimatealpr-entrypoint"]
