UID := $(shell id -u)
ARCH ?= $(shell uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')
JETSON_VERSION_PAIRS ?= 36.4.3,jammy 35.6.1,focal
JETSON_VERSION_PAIR ?= $(firstword $(JETSON_VERSION_PAIRS))
JETSON_SAMPLEFS_FLAVORS ?= minimal basic desktop
JETSON_VERSION ?= $(shell echo $(JETSON_VERSION_PAIR) | cut -d, -f1)
JETSON_LINUX_BUILDER_IMAGE_FROM ?= ghcr.io/getdevopspro/jetson-linux-builder:$(JETSON_VERSION)
JETSON_SAMPLEFS_ABI ?= aarch64a
JETSON_SAMPLEFS_DISTRO ?= ubuntu
JETSON_SAMPLEFS_FLAVOR ?= $(firstword $(JETSON_SAMPLEFS_FLAVORS))
JETSON_SAMPLEFS_VERSION ?= $(shell echo $(JETSON_VERSION_PAIR) | cut -d, -f2)

build-rootfs-variant: ## Build a rootfs variant
	docker run --rm \
		--name build-rootfs-$(JETSON_VERSION)-$(JETSON_SAMPLEFS_FLAVOR) \
		--privileged \
		--network host \
		-v $(PWD)/.shared:/workspace/shared \
		--workdir /workspace/tools/samplefs \
		--platform linux/$(ARCH) \
		ghcr.io/getdevopspro/jetson-linux-builder:$(JETSON_VERSION) bash -c \
			'sed -i "s@arch | grep .*@arch | grep \"$$(arch)\")\"@" nv_build_samplefs.sh; \
			sudo bash -x ./nv_build_samplefs.sh \
			--abi $(JETSON_SAMPLEFS_ABI) \
			--distro $(JETSON_SAMPLEFS_DISTRO) \
			--flavor $(JETSON_SAMPLEFS_FLAVOR) \
			--version $(JETSON_SAMPLEFS_VERSION); \
			chown $(UID) sample_fs.tbz2; \
			cp -p sample_fs.tbz2 /workspace/shared/sample_fs-$(JETSON_SAMPLEFS_VERSION)-$(JETSON_SAMPLEFS_FLAVOR).tbz2'

build-rootfs-variants: ## Build all rootfs variants
	for jetson_version in $(JETSON_VERSION_PAIRS); do \
		for jetson_samplefs_flavor in $(JETSON_SAMPLEFS_FLAVORS); do \
			$(MAKE) build-rootfs-variant \
				JETSON_VERSION=$$(echo $$jetson_version | cut -d, -f1) \
				JETSON_SAMPLEFS_VERSION=$$(echo $$jetson_version | cut -d, -f2) \
				JETSON_SAMPLEFS_FLAVOR=$$jetson_samplefs_flavor; \
		done; \
	done;
