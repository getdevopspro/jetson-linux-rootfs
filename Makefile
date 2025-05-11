UID := $(shell id -u)
JETSON_VERSIONS ?= 36.4.3 35.6.1
JETSON_VERSION ?= $(firstword $(JETSON_VERSIONS))
JETSON_LINUX_BUILDER_IMAGE_FROM ?= ghcr.io/getdevopspro/jetson-linux-builder:$(JETSON_VERSION)
JETSON_SAMPLEFS_ABI ?= aarch64
JETSON_SAMPLEFS_DISTRO ?= ubuntu
JETSON_SAMPLEFS_FLAVOR ?= minimal
JETSON_SAMPLEFS_VERSION ?= jammy

build-rootfs-variant:
	docker run -it --rm \
		--privileged \
		--network host \
		-v $(PWD):/workspace/shared \
		--workdir /workspace/tools/samplefs \
		ghcr.io/getdevopspro/jetson-linux-builder:$(JETSON_VERSION) bash -c \
			'sed -i "s@arch | grep .*@arch | grep \"$$(arch)\")\"@" nv_build_samplefs.sh; \
			sudo ./nv_build_samplefs.sh \
			--abi $(JETSON_SAMPLEFS_ABI) \
			--distro $(JETSON_SAMPLEFS_DISTRO) \
			--flavor $(JETSON_SAMPLEFS_FLAVOR) \
			--version $(JETSON_SAMPLEFS_VERSION); \
			chown $(UID) sample_fs.tbz2; \
			cp -p sample_fs.tbz2 /workspace/shared/sample_fs-$(JETSON_VERSION)-$(JETSON_SAMPLEFS_FLAVOR).tbz2'

build-rootfs-variants: ## Build all rootfs variants
	for version in $(JETSON_VERSIONS); do $(MAKE) build-rootfs-variant JETSON_VERSION=$$version; done
