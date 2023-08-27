# syntax=docker/dockerfile:1-labs
FROM amd64/ubuntu:latest AS base

ENTRYPOINT ["/init"]

ENV TERM="xterm" LANG="C.UTF-8" LC_ALL="C.UTF-8" TZ="UTC"
ENV EMAILADDR="you@SomeDomain.net" COUNTRY="US" DASHBOARDURL="https://YourDashboard.net" PORT="17000"
ENV CALLSIGN="M17-???" MODULES="ABCD" SPONSOR="My ham club" MULTICLIENT="true" BOOTSTRAP="xrf757.openquad.net"
ENV MREFD_CONFIG_DIR=/config MREFD_CONFIG_TMP_DIR=/config_tmp
ARG MREFD_INST_DIR=/src/mrefd OPENDHT_INST_DIR=/src/opendht DEBUG="false" DHT="true"
ARG ARCH=x86_64 S6_OVERLAY_VERSION=3.1.5.0 S6_RCD_DIR=/etc/s6-overlay/s6-rc.d S6_LOGGING=1 S6_KEEP_ENV=1

# install dependencies
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt update && \
    apt upgrade -y && \
    apt install -y \
        apache2 \
        build-essential \
        cmake \
        libargon2-0-dev \
        libasio-dev \
        libcppunit-dev \
        libcurl4-gnutls-dev \
        libfmt-dev \
        libgnutls28-dev \
        libhttp-parser-dev \
        libjsoncpp-dev \
        libmsgpack-dev \
        libncurses5-dev \
        libreadline-dev \
        libssl-dev \
        lsof \
        nettle-dev \
        pkg-config

# Setup directories
RUN mkdir -p \
    ${OPENDHT_INST_DIR} \
    ${MREFD_CONFIG_DIR} \
    ${MREFD_CONFIG_TMP_DIR} \
    ${MREFD_INST_DIR}

# Fetch and extract S6 overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${ARCH}.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-${ARCH}.tar.xz

# Clone OpenDHT repository
#ADD --keep-git-dir=true https://github.com/savoirfairelinux/opendht.git#master ${OPENDHT_INST_DIR}
ADD --keep-git-dir=true https://github.com/savoirfairelinux/opendht.git#v2.5.5 ${OPENDHT_INST_DIR}

# Clone mrefd repository
ADD --keep-git-dir=true https://github.com/n7tae/mrefd.git#master ${MREFD_INST_DIR}

# Copy in source code (use local sources if repositories go down)
#COPY src/ /

# Compile and install OpenDHT
RUN cd ${OPENDHT_INST_DIR} && \
    mkdir -p build && \
    cd build && \
    cmake -DOPENDHT_PYTHON=OFF -DCMAKE_INSTALL_PREFIX=/usr .. && \
    make && \
    make install

# Perform pre-compiliation configurations (remove references to systemctl from Makefiles)
RUN sed -i "s/\(^[[:space:]]*[[:print:]]*..systemd*\)/#\1/" ${MREFD_INST_DIR}/Makefile && \
    sed -i "s/\(^[[:space:]]*systemctl*\)/#\1/" ${MREFD_INST_DIR}/Makefile && \
    cp ${MREFD_INST_DIR}/example.mk ${MREFD_INST_DIR}/mrefd.mk && \
    cp ${MREFD_INST_DIR}/example.cfg ${MREFD_INST_DIR}/mrefd.cfg && \
    sed -i "s/\(^USESYMLINK[[:blank:]]*\=[[:blank:]]*\)[[:print:]]*/\1false/g" ${MREFD_INST_DIR}/mrefd.mk && \
    sed -i "s'\(^CFGDIR[[:blank:]]*\=[[:blank:]]*\)[[:print:]]*'\1${MREFD_CONFIG_DIR}'g" ${MREFD_INST_DIR}/mrefd.mk && \
    sed -i "s/\(^DEBUG[[:blank:]]*\=[[:blank:]]*\)[[:print:]]*/\1${DEBUG}/g" ${MREFD_INST_DIR}/mrefd.mk && \
    sed -i "s/\(^DHT[[:blank:]]*\=[[:blank:]]*\)[[:print:]]*/\1${DHT}/g" ${MREFD_INST_DIR}/mrefd.mk

# Compile and install mrefd
RUN cd ${MREFD_INST_DIR}/ && \
    cp config/* . && \
    make && \
    make install

# Install configuration files
RUN cp -v ${MREFD_INST_DIR}/config/* ${MREFD_CONFIG_TMP_DIR}/ && \
    cp -v ${MREFD_INST_DIR}/mrefd.* ${MREFD_CONFIG_TMP_DIR}/

# Copy in s6 service definitions and scripts
COPY root/ /

# Cleanup
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt -y purge \
        build-essential \
        cmake \
        pkg-config && \
    apt -y autoremove && \
    apt -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/* && \
    rm -rf /src

#UDP port 17000 (M17 protocol)
EXPOSE 17000/udp
#UDP port 17171 for DHT
EXPOSE 17171/udp

HEALTHCHECK --interval=5s --timeout=2s --retries=20 CMD /healthcheck.sh || exit 1