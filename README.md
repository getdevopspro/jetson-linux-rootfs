# Jetson Linux RootFS Container Image

A minimal container image based on NVIDIA's official Linux for Tegra (L4T) sample root filesystem. Designed for Jetson-based robotics applications, this image provides a clean starting point for building and customizing ARM64 root filesystems in containerized environments.

Ideal for developers targeting **Jetson Nano**, **Xavier**, **Orin**, and other NVIDIA Jetson devices.

---

## 🚀 Key Features

* Based on official L4T sample rootfs.
* Easily extendable using multi-stage Docker builds.
* Supports QEMU for x86\_64 → ARM64 emulation.
* CI/CD friendly for automated builds.

---

## 🛠️ Usage

To customize the root filesystem:

1. Use `ghcr.io/getdevopspro/jetson-linux-rootfs` as your base image.
2. Add your tools, configs, or binaries.
3. Export the result to a local `./rootfs` directory.

If you're building on an `amd64` host, install [QEMU](https://docs.docker.com/build/building/multi-platform/#install-qemu-manually) and set the platform to `linux/arm64`.

### 🔧 Example: Adding `tcpdump`

```dockerfile
docker build . -t ghcr.io/getdevopspro/jetson-linux-rootfs:dev -o ./rootfs \
  --platform linux/arm64 -f - << "EOF"
FROM ghcr.io/getdevopspro/jetson-linux-rootfs:36.4.3

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y tcpdump
EOF
```

---

## 🧱 Image Variants

In addition to the default sample rootfs, this repository also provides three additional root filesystem variants based on NVIDIA's official L4T scripts:

1. **[minimal](https://docs.nvidia.com/jetson/archives/r36.4.3/DeveloperGuide/SD/RootFileSystem.html#minimal-flavor-root-file-system)** – smallest footprint with only essential components
2. **[basic](https://docs.nvidia.com/jetson/archives/r36.4.3/DeveloperGuide/SD/RootFileSystem.html#basic-flavor-root-file-system)** – includes minimal plus common runtime libraries and tools
3. **[desktop](https://docs.nvidia.com/jetson/archives/r36.4.3/DeveloperGuide/SD/RootFileSystem.html#desktop-flavor-root-file-system)** – includes GUI and desktop-related components

These are built following the script and process described in the [Jetson documentation](https://docs.nvidia.com/jetson/archives/r36.4.3/DeveloperGuide/SD/RootFileSystem.html#manually-generate-a-root-file-system)

Image naming convention:

`ghcr.io/getdevopspro/jetson-linux-rootfs-\<variant>:<L4T_VERSION>`

Examples:

* `ghcr.io/getdevopspro/jetson-linux-rootfs-minimal:36.4.3`
* `ghcr.io/getdevopspro/jetson-linux-rootfs-basic:36.4.3`
* `ghcr.io/getdevopspro/jetson-linux-rootfs-desktop:36.4.3`

Choose the appropriate variant depending on your application's requirements.

---

## 📦 Image Tags

Images are published to GitHub Container Registry (GHCR):

👉 [`ghcr.io/getdevopspro/jetson-linux-rootfs`](https://ghcr.io/getdevopspro/jetson-linux-rootfs)

👉 [`ghcr.io/getdevopspro/jetson-linux-rootfs-minimal`](https://ghcr.io/getdevopspro/jetson-linux-rootfs-minimal)

👉 [`ghcr.io/getdevopspro/jetson-linux-rootfs-basic`](https://ghcr.io/getdevopspro/jetson-linux-rootfs-basic)

👉 [`ghcr.io/getdevopspro/jetson-linux-rootfs-desktop`](https://ghcr.io/getdevopspro/jetson-linux-rootfs-desktop)

Tag format: `L4T_VERSION`, e.g., `36.4.3`

---

## 🙌 Contributing

Contributions are welcome! Whether it's a bug report, feature request, or a pull request — we'd love your input to make this project better.

## 🙏 Acknowledgements

This project references and uses software from officially and publicly available resources provided by NVIDIA, including the Jetson Linux L4T release packages and associated tools. It also relies on Ubuntu and other open source components.
While this container is designed to simplify the use of these tools, it is not an official NVIDIA project and is not affiliated with or endorsed by NVIDIA.

All trademarks and registered trademarks are the property of their respective owners.
