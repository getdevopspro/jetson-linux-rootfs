// docker-bake.hcl
variable "IMAGE_NAME" {
  default = "ghcr.io/getdevopspro/jetson-linux-rootfs"
}

variable "JETSON_VERSION_PAIRS" {
  # IMPORTANT: latest always be the first element in the list
  default = ["36.4.3,jammy", "35.6.1,focal"]
}

function "jetson_version" {
  params = [jetson_version_pair]
  result = split(",", jetson_version_pair)[0]
}

function "jetson_ubuntu_release" {
  params = [jetson_version_pair]
  result = split(",", jetson_version_pair)[1]
}

target "docker-metadata-action" {}

target "build" {
  inherits   = ["docker-metadata-action"]
  context    = "./"
  dockerfile = "Dockerfile"
  name       = "${replace(sanitize(IMAGE_NAME), "_", "-")}-${replace(sanitize(jetson_version(jetson_version_pair)), "_", "-")}"
  platforms = [
    "linux/arm64",
  ]
  matrix = {
    jetson_version_pair = JETSON_VERSION_PAIRS
  }
  args = {
    JETSON_VERSION                   = jetson_version(jetson_version_pair),
    JETSON_VERSION_MAJOR             = split(".", jetson_version(jetson_version_pair))[0],
    JETSON_VERSION_MINOR             = split(".", jetson_version(jetson_version_pair))[1],
    JETSON_VERSION_PATCH             = split(".", jetson_version(jetson_version_pair))[2],
    JETSON_LINUX_RELEASE_URI         = split(".", jetson_version(jetson_version_pair))[0] == "35" ? "https://developer.nvidia.com/downloads/embedded/l4t/r35_release_v${split(".", jetson_version(jetson_version_pair))[1]}.${split(".", jetson_version(jetson_version_pair))[2]}" : null
    JETSON_LINUX_ROOTFS_PACKAGE_NAME = split(".", jetson_version(jetson_version_pair))[0] == "35" ? "tegra_linux_sample-root-filesystem_r35.${split(".", jetson_version(jetson_version_pair))[1]}.${split(".", jetson_version(jetson_version_pair))[2]}_aarch64.tbz2" : null,
    JETSON_LINUX_ROOTFS_PACKAGE_URL  = split(".", jetson_version(jetson_version_pair))[0] == "35" ? "https://developer.nvidia.com/downloads/embedded/l4t/r35_release_v${split(".", jetson_version(jetson_version_pair))[1]}.${split(".", jetson_version(jetson_version_pair))[2]}/tegra_linux_sample-root-filesystem_r35.${split(".", jetson_version(jetson_version_pair))[1]}.${split(".", jetson_version(jetson_version_pair))[2]}_aarch64.tbz2" : null,
  }
  tags = concat(
    jetson_version_pair == JETSON_VERSION_PAIRS[0] ? ["${IMAGE_NAME}:latest"] : [],
    [
      "${IMAGE_NAME}:${split(".", jetson_version(jetson_version_pair))[0]}",
      "${IMAGE_NAME}:${split(".", jetson_version(jetson_version_pair))[0]}.${split(".", jetson_version(jetson_version_pair))[1]}",
      "${IMAGE_NAME}:${jetson_version(jetson_version_pair)}",
      "${IMAGE_NAME}:${jetson_version(jetson_version_pair)}-${formatdate("YYYYMMDDhhmm", timestamp())}",
    ]
  )
  labels = {
    "manifest:org.opencontainers.image.version" : jetson_version(jetson_version_pair)
    "org.opencontainers.image.version" = jetson_version(jetson_version_pair)
  }
}

target "build-variants" {
  inherits   = ["docker-metadata-action"]
  context    = "./"
  dockerfile = "Dockerfile.variants"
  name       = "${replace(sanitize(IMAGE_NAME), "_", "-")}-${replace(sanitize(jetson_version(jetson_version_pair)), "_", "-")}-${replace(sanitize(samplefs_variant), "_", "-")}"
  platforms = [
    "linux/arm64",
  ]
  matrix = {
    jetson_version_pair = JETSON_VERSION_PAIRS
    samplefs_variant    = ["minimal", "basic", "desktop"]
  }
  args = {
    JETSON_VERSION          = jetson_version(jetson_version_pair),
    JETSON_VERSION_MAJOR    = split(".", jetson_version(jetson_version_pair))[0],
    JETSON_VERSION_MINOR    = split(".", jetson_version(jetson_version_pair))[1],
    JETSON_VERSION_PATCH    = split(".", jetson_version(jetson_version_pair))[2],
    JETSON_SAMPLEFS_ABI     = "aarch64",
    JETSON_SAMPLEFS_DISTRO  = "ubuntu",
    JETSON_SAMPLEFS_FLAVOR  = samplefs_variant,
    JETSON_SAMPLEFS_VERSION = jetson_ubuntu_release(jetson_version_pair),
  }
  tags = concat(
    jetson_version_pair == JETSON_VERSION_PAIRS[0] ? ["${IMAGE_NAME}-${samplefs_variant}:latest"] : [],
    [
      "${IMAGE_NAME}-${samplefs_variant}:${split(".", jetson_version(jetson_version_pair))[0]}",
      "${IMAGE_NAME}-${samplefs_variant}:${split(".", jetson_version(jetson_version_pair))[0]}.${split(".", jetson_version(jetson_version_pair))[1]}",
      "${IMAGE_NAME}-${samplefs_variant}:${jetson_version(jetson_version_pair)}",
      "${IMAGE_NAME}-${samplefs_variant}:${jetson_version(jetson_version_pair)}-${formatdate("YYYYMMDDhhmm", timestamp())}",
    ]
  )
  labels = {
    "manifest:org.opencontainers.image.version" : jetson_version(jetson_version_pair)
    "org.opencontainers.image.version" = jetson_version(jetson_version_pair)
  }
}
