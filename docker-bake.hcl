// docker-bake.hcl
variable "IMAGE_NAME" {
  default = "ghcr.io/getdevopspro/jetson-linux-rootfs"
}

target "docker-metadata-action" {}

target "build" {
  inherits   = ["docker-metadata-action"]
  context    = "./"
  dockerfile = "Dockerfile"
  name       = "${replace(sanitize(IMAGE_NAME), "_", "-")}-${replace(sanitize(version), "_", "-")}"
  platforms = [
    "linux/arm64",
  ]
  matrix = {
    version = ["36.4.3", "35.6.1"]
  }
  args = {
    JETSON_VERSION          = version,
    JETSON_VERSION_MAJOR    = split(".", version)[0],
    JETSON_VERSION_MINOR    = split(".", version)[1],
    JETSON_VERSION_PATCH    = split(".", version)[2],
    JETSON_LINUX_ROOTFS_URL = split(".", version)[0] == "35" ? "https://developer.nvidia.com/downloads/embedded/l4t/r35_release_v${split(".", version)[1]}.${split(".", version)[2]}/tegra_linux_sample-root-filesystem_r35.${split(".", version)[1]}.${split(".", version)[2]}_aarch64.tbz2" : null,
  }
  tags = [
    "${IMAGE_NAME}:${split(".", version)[0]}",
    "${IMAGE_NAME}:${split(".", version)[0]}.${split(".", version)[1]}",
    "${IMAGE_NAME}:${version}",
    "${IMAGE_NAME}:${version}-${formatdate("YYYYMMDDhhmm", timestamp())}",
  ]
  labels = {
    "manifest:org.opencontainers.image.version" : version
    "org.opencontainers.image.version" = version
  }
}
