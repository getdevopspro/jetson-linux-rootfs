# jetson-linux-rootfs

## Repository guidance

- This repository packages NVIDIA L4T sample root filesystems as ARM64 images,
  including `minimal`, `basic`, and `desktop` variants.
- `Dockerfile` downloads and extracts the NVIDIA sample filesystem.
  `Dockerfile.variants` consumes archives generated under `.shared/`.
  `docker-bake.hcl` defines the `build` and `build-variants` targets.
- Keep L4T/Ubuntu version pairs aligned across `Makefile`, `docker-bake.hcl`,
  `.github/workflows/build-variants.yml`, and `README.md`. The newest pair
  comes first and supplies `latest` tags.
- `JETSON_VERSION_PAIRS` is space-separated. Flavor lists are space-separated
  in Make and comma-separated in Bake; preserve the distinction.
- `VERSION` in `Makefile` is the repository release version, distinct from
  the L4T image versions. Keep generated filesystem archives out of source edits.

## Validation and build boundaries

- Inspect build configuration with
  `docker buildx bake --print build build-variants`; inspect the rootfs command
  with `make -n build-rootfs-variant`. These render plans, not image builds.
- There is no dedicated test or lint target. Validate changed Dockerfiles,
  Bake settings, workflows, and documentation together.
- `make build-rootfs-variant` and `make build-rootfs-variants` run privileged
  containers with host networking and a writable `.shared` mount. Run them
  only for explicitly authorized rootfs builds, not documentation checks.
- Image build and release workflows publish artifacts; do not trigger publication
  as validation.
