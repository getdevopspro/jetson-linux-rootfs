# Jetson Linux RootFS Container Image

A minimal container image based on NVIDIA's official Linux for Tegra (L4T) sample root filesystem. Designed for Jetson-based robotics applications, this image provides a clean starting point for building and customizing ARM64 root filesystems in containerized environments.

Ideal for developers targeting **Jetson Nano**, **Xavier**, **Orin**, and other NVIDIA Jetson devices.

---

## 🚀 Key Features

* Based on official L4T sample rootfs.
* Ready-to-use base image for ARM64 containers.
* Easily extendable using multi-stage Docker builds.
* Supports QEMU for x86\_64 → ARM64 emulation.

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

## 📦 Image Tags

Images are published to GitHub Container Registry (GHCR):
👉 [`ghcr.io/getdevopspro/jetson-linux-rootfs`](https://ghcr.io/getdevopspro/jetson-linux-rootfs)

Tag format: `L4T_VERSION`, e.g., `36.4.3`

---

## 🙌 Contributing

Contributions are welcome! Whether it's a bug report, feature request, or a pull request — we'd love your input to make this project better.
