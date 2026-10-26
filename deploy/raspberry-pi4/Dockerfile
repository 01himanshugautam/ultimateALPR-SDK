FROM debian:bullseye-20241223-slim AS build

ENV DEBIAN_FRONTEND=noninteractive
RUN sed -i \
    -e 's|http://deb.debian.org/debian-security|http://snapshot.debian.org/archive/debian-security/20250101T000000Z|g' \
    -e 's|http://deb.debian.org/debian|http://snapshot.debian.org/archive/debian/20250101T000000Z|g' \
      /etc/apt/sources.list \
 && printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99snapshot
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    g++ libboost-system-dev libboost-thread-dev libcpprest-dev \
    libcurl4-openssl-dev libopencv-dev libssl-dev rapidjson-dev pkg-config \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /src/recognizer
COPY c++/ultimateALPR-SDK-API-PUBLIC.h /src/c++/
COPY samples/c++/stb_image.h /src/stb_image.h
COPY samples/c++/recognizer/recognizer.cxx /src/recognizer/recognizer.cxx
COPY binaries/raspbian/armv7l/libultimate_alpr-sdk.so /src/lib/

RUN g++ /src/recognizer/recognizer.cxx -O3 -pthread -DLEGACY_OPENCV_VIDEOIO \
    -I/src/c++ -L/src/lib -Wl,-rpath,/opt/ultimatealpr/lib \
    -lultimate_alpr-sdk $(pkg-config opencv4 --cflags --libs) \
    -lcurl -lboost_system -lboost_thread -latomic -lcpprest -lssl -lcrypto \
    -o /src/recognizer/recognizer

FROM debian:bullseye-20241223-slim

ENV DEBIAN_FRONTEND=noninteractive \
    LD_LIBRARY_PATH=/opt/ultimatealpr/lib
RUN sed -i \
    -e 's|http://deb.debian.org/debian-security|http://snapshot.debian.org/archive/debian-security/20250101T000000Z|g' \
    -e 's|http://deb.debian.org/debian|http://snapshot.debian.org/archive/debian/20250101T000000Z|g' \
      /etc/apt/sources.list \
 && printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99snapshot
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    ca-certificates libboost-system1.74.0 libboost-thread1.74.0 \
    libcpprest2.10 libcurl4 libopencv-core4.5 libopencv-highgui4.5 \
    libopencv-imgcodecs4.5 libopencv-imgproc4.5 libopencv-videoio4.5 \
    libssl1.1 udev \
 && rm -rf /var/lib/apt/lists/*

COPY --from=build /src/recognizer/recognizer /opt/ultimatealpr/bin/recognizer
COPY binaries/raspbian/armv7l/benchmark /opt/ultimatealpr/bin/benchmark
COPY binaries/raspbian/armv7l/runtimeKey /opt/ultimatealpr/bin/runtimeKey
COPY binaries/raspbian/armv7l/libultimate_alpr-sdk.so /opt/ultimatealpr/lib/
COPY assets /opt/ultimatealpr/assets
COPY deploy/jetson-nano/entrypoint.sh /usr/local/bin/ultimatealpr-entrypoint

RUN chmod 0755 /opt/ultimatealpr/bin/recognizer /opt/ultimatealpr/bin/benchmark /opt/ultimatealpr/bin/runtimeKey /usr/local/bin/ultimatealpr-entrypoint \
 && useradd --system --uid 10001 --create-home anpr \
 && mkdir -p /home/parksmart/anpr/images \
 && chown -R anpr:anpr /home/parksmart/anpr

WORKDIR /opt/ultimatealpr/lib
USER anpr
ENTRYPOINT ["/usr/local/bin/ultimatealpr-entrypoint"]
