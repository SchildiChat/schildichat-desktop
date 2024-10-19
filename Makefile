.PHONY: all setup regenerate-i18n web desktop-common linux debian rpm pacman local-pkgbuild local-pkgbuild-install windows windows-portable
.PHONY: web-release debian-release rpm-release pacman-release windows-setup-release windows-unpacked-release windows-portable-release windows-release
.PHONY: macos-common macos macos-mas macos-release macos-mas-release icns
.PHONY: container-build-debian container-build-fedora container-build-windows
.PHONY: container-web-release container-debian-release container-rpm-release container-appimage-release container-windows-release container-release container-local-pkgbuild
.PHONY: clean undo_setup fixup
.PHONY: fix_yarn_cache

CFGDIR ?= configs/sc

all: web

YARN ?= yarnpkg
CONTAINER_ENGINE ?= podman
NODE_VERSION ?= 22

VERSION := $(shell grep version element-desktop/package.json | sed 's|.*: \"\(.*\)\",|\1|')
#WEB_APP_NAME :=  $(shell grep '"name"' element-web/package.json | head -n 1 | sed 's|.*: \"\(.*\)\",|\1|')
WEB_APP_NAME := element
DESKTOP_APP_NAME :=  $(shell grep '"name"' element-desktop/package.json | head -n 1 | sed 's|.*: \"\(.*\)\",|\1|')
PRODUCT_NAME :=  $(shell grep '"productName"' element-desktop/package.json | sed 's|.*: \"\(.*\)\",|\1|')

WEB_OUT := element-web/dist
WEB_OUT_DIST_VERSION := $(VERSION)
OUT_WEB := $(WEB_OUT)/$(WEB_APP_NAME)-$(WEB_OUT_DIST_VERSION).tar.gz

DESKTOP_OUT := element-desktop/dist
OUT_DEB64 := $(DESKTOP_OUT)/$(DESKTOP_APP_NAME)_$(VERSION)_amd64.deb
OUT_RPM64 := $(DESKTOP_OUT)/$(DESKTOP_APP_NAME)-$(VERSION).x86_64.rpm
OUT_PAC64 := $(DESKTOP_OUT)/$(DESKTOP_APP_NAME)-$(VERSION).pacman
OUT_APPIMAGE64 := $(DESKTOP_OUT)/$(PRODUCT_NAME)-$(VERSION).AppImage
OUT_TARXZ64 := $(DESKTOP_OUT)/$(DESKTOP_APP_NAME)-$(VERSION).tar.xz
OUT_WIN64 := $(DESKTOP_OUT)/$(PRODUCT_NAME)\ Setup\ $(VERSION).exe
OUT_WIN64_PORTABLE := $(DESKTOP_OUT)/$(PRODUCT_NAME)\ $(VERSION).exe
OUT_WIN64_BETTER_NAME := $(PRODUCT_NAME)_Setup_v$(VERSION).exe
OUT_WIN64_UNPACKED_BETTER_NAME := $(PRODUCT_NAME)_win-unpacked_v$(VERSION).zip
OUT_WIN64_PORTABLE_BETTER_NAME := $(PRODUCT_NAME)_win-portable_v$(VERSION)
OUT_MACOS := $(DESKTOP_OUT)/$(PRODUCT_NAME)-$(VERSION)-universal.dmg
OUT_MACOS_MAS := $(DESKTOP_OUT)/mas-universal/$(PRODUCT_NAME).app

CONTAINER_IMAGE_DEBIAN := schildichat-desktop-containerbuild-debian
CONTAINER_IMAGE_FEDORA := schildichat-desktop-containerbuild-fedora
CONTAINER_IMAGE_WINDOWS := schildichat-desktop-containerbuild-windows

RELEASE_DIR := release
CURRENT_RELEASE_DIR := $(RELEASE_DIR)/$(VERSION)

# macOS Codesigning
CSC_IDENTITY_AUTO_DISCOVERY ?= false
NOTARIZE_APPLE_ID ?=
CSC_NAME ?=

-include release.mk

setup:
	./setup.sh

element-desktop/build/SchildiChat.xcassets/SchildiChat.iconset: $(wildcard element-desktop/build/SchildiChat.xcassets/SchildiChat.iconset/*)

element-desktop/build/icon.icns: element-desktop/build/SchildiChat.xcassets/SchildiChat.iconset
	iconutil -c icns -o $@ $<

element-desktop/build/SchildiChat.xcassets/SchildiChatDMG.iconset: $(wildcard element-desktop/build/SchildiChat.xcassets/SchildiChatDMG.iconset/*)

element-desktop/build/dmg.icns: element-desktop/build/SchildiChat.xcassets/SchildiChatDMG.iconset
	iconutil -c icns -o $@ $<

icns: element-desktop/build/icon.icns element-desktop/build/dmg.icns

regenerate-i18n: setup
	./regenerate_i18n.sh

web: export DIST_VERSION=$(WEB_OUT_DIST_VERSION)
web: setup
	cp $(CFGDIR)/config.json element-web/
	$(YARN) --cwd element-web dist
	echo "$(VERSION)" > element-web/webapp/version

desktop-common: web
	$(YARN) --cwd element-desktop run fetch --cfgdir ''
	SQLCIPHER_BUNDLED=1 $(YARN) --cwd element-desktop run build:native

macos-common: web icns
	$(YARN) --cwd element-desktop run fetch --cfgdir ''
	$(YARN) --cwd element-desktop run build:native:universal

linux: desktop-common
	$(YARN) --cwd element-desktop run build:64 --linux deb pacman tar.xz

debian: desktop-common
	$(YARN) --cwd element-desktop run build:64 --linux deb

rpm: desktop-common
	$(YARN) --cwd element-desktop run build:64 --linux rpm

pacman: desktop-common
	$(YARN) --cwd element-desktop run build:64 --linux pacman

appimage: desktop-common
	$(YARN) --cwd element-desktop run build:64 --linux AppImage

windows: desktop-common
	$(YARN) --cwd element-desktop run build:64 --windows nsis

windows-portable: desktop-common
	$(YARN) --cwd element-desktop run build:64 --windows portable

macos: macos-common
	export CSC_IDENTITY_AUTO_DISCOVERY
	export NOTARIZE_APPLE_ID
	export CSC_NAME
	$(YARN) --cwd element-desktop run build:universal --mac dmg

macos-mas: macos-common
	export NOTARIZE_APPLE_ID
	export CSC_NAME
	$(YARN) --cwd element-desktop run build:universal --mac mas

local-pkgbuild: debian
	./create_local_pkgbuild.sh $(VERSION) $(DESKTOP_APP_NAME) $(PRODUCT_NAME) $(OUT_DEB64)

local-pkgbuild-install: local-pkgbuild
	cd local-pkgbuild; makepkg --install

web-release: web
	mkdir -p $(CURRENT_RELEASE_DIR)
	cp $(OUT_WEB) $(CURRENT_RELEASE_DIR)

debian-release: debian
	mkdir -p $(CURRENT_RELEASE_DIR)
	cp $(OUT_DEB64) $(CURRENT_RELEASE_DIR)

rpm-release: rpm
	mkdir -p $(CURRENT_RELEASE_DIR)
	cp $(OUT_RPM64) $(CURRENT_RELEASE_DIR)

pacman-release: pacman
	mkdir -p $(CURRENT_RELEASE_DIR)
	cp $(OUT_PAC64) $(CURRENT_RELEASE_DIR)

appimage-release: appimage
	mkdir -p $(CURRENT_RELEASE_DIR)
	cp $(OUT_APPIMAGE64) $(CURRENT_RELEASE_DIR)

windows-setup-release: windows
	mkdir -p $(CURRENT_RELEASE_DIR)
	cp $(OUT_WIN64) $(CURRENT_RELEASE_DIR)/$(OUT_WIN64_BETTER_NAME)

windows-unpacked-release: windows
	mkdir -p $(CURRENT_RELEASE_DIR)
	cd element-desktop/dist/win-unpacked && zip -r ../../../$(CURRENT_RELEASE_DIR)/$(OUT_WIN64_UNPACKED_BETTER_NAME) *

windows-portable-release: windows-portable
	./windowsportable.sh $(OUT_WIN64_PORTABLE) $(OUT_WIN64_PORTABLE_BETTER_NAME) $(CURRENT_RELEASE_DIR) $(VERSION)

windows-release: windows-setup-release windows-unpacked-release windows-portable-release

macos-release: macos
	mkdir -p $(CURRENT_RELEASE_DIR)
	cp $(OUT_MACOS) $(CURRENT_RELEASE_DIR)

macos-mas-release: macos-mas
	mkdir -p $(CURRENT_RELEASE_DIR)
	cp $(OUT_MACOS_MAS) $(CURRENT_RELEASE_DIR)

container-build-debian:
	$(CONTAINER_ENGINE) build --security-opt seccomp=unconfined --security-opt label=disable -t $(CONTAINER_IMAGE_DEBIAN) -f Containerfile.debian --build-arg NODE_VERSION=$(NODE_VERSION) .

container-build-fedora:
	$(CONTAINER_ENGINE) build --security-opt seccomp=unconfined --security-opt label=disable -t $(CONTAINER_IMAGE_FEDORA) -f Containerfile.fedora --build-arg NODE_VERSION=$(NODE_VERSION) .

container-build-windows: container-build-debian
	$(CONTAINER_ENGINE) build --security-opt seccomp=unconfined --security-opt label=disable -t $(CONTAINER_IMAGE_WINDOWS) -f Containerfile.windows --build-arg CONTAINER_IMAGE_DEBIAN=$(CONTAINER_IMAGE_DEBIAN) .

container-web-release: container-build-debian
	$(CONTAINER_ENGINE) run --rm -ti -v $(PWD):/project --security-opt seccomp=unconfined --security-opt label=disable $(CONTAINER_IMAGE_DEBIAN):latest make web-release

container-debian-release: container-build-debian
	$(CONTAINER_ENGINE) run --rm -ti -v $(PWD):/project --security-opt seccomp=unconfined --security-opt label=disable $(CONTAINER_IMAGE_DEBIAN):latest make debian-release

container-rpm-release: container-build-fedora
	$(CONTAINER_ENGINE) run --rm -ti -v $(PWD):/project --security-opt seccomp=unconfined --security-opt label=disable $(CONTAINER_IMAGE_FEDORA):latest make rpm-release

container-appimage-release: container-build-debian
	$(CONTAINER_ENGINE) run --rm -ti -v $(PWD):/project --security-opt seccomp=unconfined --security-opt label=disable $(CONTAINER_IMAGE_DEBIAN):latest make appimage-release

container-windows-release: container-build-windows
	$(CONTAINER_ENGINE) run --rm -ti -v $(PWD):/project --security-opt seccomp=unconfined --security-opt label=disable $(CONTAINER_IMAGE_WINDOWS):latest make windows-release

container-release: container-build-windows #container-build-fedora
	$(CONTAINER_ENGINE) run --rm -ti -v $(PWD):/project --security-opt seccomp=unconfined --security-opt label=disable $(CONTAINER_IMAGE_WINDOWS):latest make web-release debian-release appimage-release rpm-release windows-setup-release windows-portable-release
	#$(CONTAINER_ENGINE) run --rm -ti -v $(PWD):/project --security-opt seccomp=unconfined --security-opt label=disable $(CONTAINER_IMAGE_FEDORA):latest make rpm-release

container-local-pkgbuild: container-build-debian
	$(CONTAINER_ENGINE) run --rm -ti -v $(PWD):/project --security-opt seccomp=unconfined --security-opt label=disable $(CONTAINER_IMAGE_DEBIAN):latest make local-pkgbuild

bom.lock: element-desktop/yarn.lock element-web/yarn.lock matrix-js-sdk/yarn.lock matrix-react-sdk/yarn.lock
	./build-bom.sh
bom: bom.lock

fix_yarn_cache:
	$(YARN) cache list || $(YARN) cache clean

clean:
	$(YARN) --cwd matrix-js-sdk clean
	$(YARN) --cwd matrix-react-sdk clean
	$(YARN) --cwd element-web clean
	$(YARN) --cwd element-desktop clean
	rm -f element-desktop/webapp
	rm -rf element-web/dist
	rm -rf local-pkgbuild
	rm -f bom.lock

undo_setup:
	rm -rf element-desktop/node_modules element-web/node_modules matrix-react-sdk/node_modules matrix-js-sdk/node_modules i18n-helper/node_modules element-desktop/.hak

fixup: undo_setup fix_yarn_cache
	make setup
	make clean
	make setup
