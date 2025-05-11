UID := $(shell id -u)
JETSON_VERSION_PAIRS ?= 36.4.3,jammy 35.6.1,focal
JETSON_SAMPLEFS_VERSIONS ?= jammy focal
JETSON_VERSION ?= $(shell echo $(JETSON_VERSION_PAIRS) | cut -d, -f1)
JETSON_LINUX_BUILDER_IMAGE_FROM ?= ghcr.io/getdevopspro/jetson-linux-builder:$(JETSON_VERSION)
JETSON_SAMPLEFS_ABI ?= aarch64
JETSON_SAMPLEFS_DISTRO ?= ubuntu
JETSON_SAMPLEFS_FLAVOR ?= minimal
# first item of JETSON_VERSIONS_AND_SAMPLEFS_VERSION and after comma
JETSON_SAMPLEFS_VERSION ?= $(word 2,$(subst , ,$(firstword $(JETSON_VERSIONS_AND_SAMPLEFS_VERSION))))

build-rootfs-variant: ## Build a rootfs variant
	docker run --rm \
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
	for version_pair in $(JETSON_VERSION_PAIRS); do $(MAKE) build-rootfs-variant JETSON_VERSION=$${version_pair%%,*} JETSON_SAMPLEFS_VERSION=$${version_pair#*,}; done
