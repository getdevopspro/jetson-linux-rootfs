############ SAMPLE ROOTFS ARTIFACT ############
ARG JETSON_LINUX_SAMPLE_ROOTFS_ARTFIFACT_IMAGE_BASE=docker.io/ubuntu:jammy
FROM ${JETSON_LINUX_SAMPLE_ROOTFS_ARTFIFACT_IMAGE_BASE} AS jetson_linux_sample_rootfs_artfifact

ARG JETSON_VERSION_MAJOR=36
ARG JETSON_VERSION_MINOR=4
ARG JETSON_VERSION_PATCH=3
ARG JETSON_VERSION=${JETSON_VERSION_MAJOR}.${JETSON_VERSION_MINOR}.${JETSON_VERSION_PATCH}
ARG JETSON_LINUX_ROOTFS_URL="https://developer.nvidia.com/downloads/embedded/l4t/r${JETSON_VERSION_MAJOR}_release_v${JETSON_VERSION_MINOR}.${JETSON_VERSION_PATCH}/release/Tegra_Linux_Sample-Root-Filesystem_r${JETSON_VERSION}_aarch64.tbz2"

ENV JETSON_LINUX_ROOTFS_URL=${JETSON_LINUX_ROOTFS_URL}

ADD ${JETSON_LINUX_ROOTFS_URL} /jetson_linux_rootfs.tbz2
WORKDIR /rootfs
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked  \
    apt-get update && apt-get install -y lbzip2 && \
    tar --use-compress-program=lbzip2 -xf /jetson_linux_rootfs.tbz2

############ ROOTFS ############
FROM scratch

ARG JETSON_VERSION_MAJOR=36
ARG JETSON_VERSION_MINOR=4
ARG JETSON_VERSION_PATCH=3
ARG JETSON_VERSION=${JETSON_VERSION_MAJOR}.${JETSON_VERSION_MINOR}.${JETSON_VERSION_PATCH}
ARG JETSON_LINUX_ROOTFS_URL="https://developer.nvidia.com/downloads/embedded/l4t/r${JETSON_VERSION_MAJOR}_release_v${JETSON_VERSION_MINOR}.${JETSON_VERSION_PATCH}/release/Tegra_Linux_Sample-Root-Filesystem_r${JETSON_VERSION}_aarch64.tbz2"

ENV JETSON_VERSION_MAJOR=${JETSON_VERSION_MAJOR} \
    JETSON_VERSION_MINOR=${JETSON_VERSION_MINOR} \
    JETSON_VERSION_PATCH=${JETSON_VERSION_PATCH} \
    JETSON_VERSION=${JETSON_VERSION} \
    JETSON_LINUX_ROOTFS_URL=${JETSON_LINUX_ROOTFS_URL}

COPY --from=jetson_linux_sample_rootfs_artfifact /rootfs /

LABEL org.opencontainers.image.title="NVIDIA Jetson Linux Sample RootFS" \
      org.opencontainers.image.version="${JETSON_VERSION}" \
