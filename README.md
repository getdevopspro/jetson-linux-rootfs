# Jetson Linux RootFS Container Image

A minimal container image based on NVIDIA's official Linux for Tegra (L4T) sample root filesystem. Designed for Jetson-based robotics applications, this image provides a clean starting point for building and customizing ARM64 root filesystems in containerized environments.

Ideal for developers targeting **Jetson Nano**, **Xavier**, **Orin**, and other NVIDIA Jetson devices.

---

## 🚀 Key Features

- Based on official L4T sample rootfs.
- Easily extendable using multi-stage Docker builds.
- Supports QEMU for x86_64 → ARM64 emulation.
- CI/CD friendly for automated builds.

---

## 🛠️ Usage

To customize the root filesystem:

1. Use `ghcr.io/<YOUR_ORG>/jetson-linux-rootfs` as your base image.
2. Add your tools, configs, or binaries.
3. Export the result to a local `./rootfs` directory.

If you're building on an `amd64` host, install [QEMU](https://docs.docker.com/build/building/multi-platform/#install-qemu-manually) and set the platform to `linux/arm64`.

### 🔧 Example: Adding `tcpdump`

```dockerfile
docker build . -t ghcr.io/<YOUR_ORG>/jetson-linux-rootfs:dev -o ./rootfs \
  --platform linux/arm64 -f - << "EOF"
FROM ghcr.io/<YOUR_ORG>/jetson-linux-rootfs:36.5.0

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y tcpdump
EOF
```

---

## 🧱 Image Variants

In addition to the default sample rootfs, this repository also provides three additional root filesystem variants based on NVIDIA's official L4T scripts:

1. **[minimal](https://docs.nvidia.com/jetson/archives/r36.5.0/DeveloperGuide/SD/RootFileSystem.html#minimal-flavor-root-file-system)** – smallest footprint with only essential components
2. **[basic](https://docs.nvidia.com/jetson/archives/r36.5.0/DeveloperGuide/SD/RootFileSystem.html#basic-flavor-root-file-system)** – includes minimal plus common runtime libraries and tools
3. **[desktop](https://docs.nvidia.com/jetson/archives/r36.5.0/DeveloperGuide/SD/RootFileSystem.html#desktop-flavor-root-file-system)** – includes GUI and desktop-related components

These are built following the script and process described in the [Jetson documentation](https://docs.nvidia.com/jetson/archives/r36.5.0/DeveloperGuide/SD/RootFileSystem.html#manually-generate-a-root-file-system)

Image naming convention:

`ghcr.io/<YOUR_ORG>/jetson-linux-rootfs-<variant>:<L4T_VERSION>`

Examples:

- `ghcr.io/<YOUR_ORG>/jetson-linux-rootfs-minimal:36.5.0`
- `ghcr.io/<YOUR_ORG>/jetson-linux-rootfs-basic:36.5.0`
- `ghcr.io/<YOUR_ORG>/jetson-linux-rootfs-desktop:36.5.0`

Choose the appropriate variant depending on your application's requirements.

### 🔑 SSH host keys

Variant archives and images built from this version of the repository contain
no SSH host keys. Installing `openssh-server` while the sample rootfs is built
generates them, and every system built from the same archive would share them,
so `scripts/remove-ssh-host-keys.sh` removes them after the build. Images
published before this change, including dated `<L4T_VERSION>-<YYYYMMDDhhmm>`
tags, still contain shared keys. Remove them in your build with
`RUN rm -f /etc/ssh/ssh_host_*`.

`sshd` does not start without host keys. Generate them on each system's first
boot, before `sshd` starts, for example with this service:

```ini
# /etc/systemd/system/ssh-host-keys.service
[Unit]
Description=Generate SSH host keys
Before=ssh.service
ConditionPathExists=!/etc/ssh/ssh_host_ed25519_key

[Service]
Type=oneshot
ExecStart=/usr/bin/ssh-keygen -A

[Install]
WantedBy=multi-user.target
```

Enable it in the image with `systemctl enable ssh-host-keys.service`. The
service runs only while the image has no host keys. A build step that installs,
upgrades or reconfigures `openssh-server`, such as `apt-get upgrade`, creates
them again, so delete them in the same `RUN` step, for example
`apt-get upgrade -y && rm -f /etc/ssh/ssh_host_*`.

---

## 📦 Image Tags

Images are published to GitHub Container Registry (GHCR):

👉 `ghcr.io/<YOUR_ORG>/jetson-linux-rootfs`

👉 `ghcr.io/<YOUR_ORG>/jetson-linux-rootfs-minimal`

👉 `ghcr.io/<YOUR_ORG>/jetson-linux-rootfs-basic`

👉 `ghcr.io/<YOUR_ORG>/jetson-linux-rootfs-desktop`

Tag format: `L4T_VERSION`, e.g., `36.5.0`

## Build Versions

Set `JETSON_VERSION_PAIRS` to choose the L4T and Ubuntu release pairs that Make
and Docker Buildx Bake should build. Keep the newest pair first because it gets
the `latest` tag.

```bash
JETSON_VERSION_PAIRS="36.5.0,jammy 36.4.3,jammy" docker buildx bake build
JETSON_VERSION_PAIRS="36.5.0,jammy 36.4.3,jammy" make build-rootfs-variants
```

Docker Buildx Bake accepts `JETSON_SAMPLEFS_FLAVORS` as a comma-separated list,
for example `JETSON_SAMPLEFS_FLAVORS="minimal,basic,desktop"`.

The Make targets also need GNU tar and bzip2 on the build host, because
`scripts/remove-ssh-host-keys.sh` runs there after the container build.

---

## 🙌 Contributing

Contributions are welcome! Whether it's a bug report, feature request, or a pull request — we'd love your input to make this project better.

## 🙏 Acknowledgements

This project references and uses software from officially and publicly available resources provided by NVIDIA, including the Jetson Linux L4T release packages and associated tools. It also relies on Ubuntu and other open source components.
While this container is designed to simplify the use of these tools, it is not an official NVIDIA project and is not affiliated with or endorsed by NVIDIA.

All trademarks and registered trademarks are the property of their respective owners.
