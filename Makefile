.PHONY: all setup regenerate-i18n reskindex web desktop-common linux debian pacman local-pkgbuild local-pkgbuild-install windows windows-portable
.PHONY: web-release debian-release pacman-release windows-setup-release windows-unpacked-release windows-portable-release windows-release
.PHONY: clean

CFGDIR ?= configs/sc

all: web

YARN ?= yarnpkg

VERSION := $(shell grep version element-desktop/package.json | sed 's|.*: \"\(.*\)\",|\1|')
WEB_APP_NAME :=  $(shell grep '"name"' element-web/package.json | head -n 1 | sed 's|.*: \"\(.*\)\",|\1|')
DESKTOP_APP_NAME :=  $(shell grep '"name"' element-desktop/package.json | head -n 1 | sed 's|.*: \"\(.*\)\",|\1|')
PRODUCT_NAME :=  $(shell grep '"productName"' element-desktop/package.json | sed 's|.*: \"\(.*\)\",|\1|')

WEB_OUT := element-web/dist
WEB_OUT_DIST_VERSION := $(VERSION)
OUT_WEB := $(WEB_OUT)/$(WEB_APP_NAME)-$(WEB_OUT_DIST_VERSION).tar.gz

DESKTOP_OUT := element-desktop/dist
OUT_DEB64 := $(DESKTOP_OUT)/$(DESKTOP_APP_NAME)_$(VERSION)_amd64.deb
OUT_PAC64 := $(DESKTOP_OUT)/$(DESKTOP_APP_NAME)-$(VERSION).pacman
OUT_APPIMAGE64 := $(DESKTOP_OUT)/$(PRODUCT_NAME)-$(VERSION).AppImage
OUT_TARXZ64 := $(DESKTOP_OUT)/$(DESKTOP_APP_NAME)-$(VERSION).tar.xz
OUT_WIN64 := $(DESKTOP_OUT)/$(PRODUCT_NAME)\ Setup\ $(VERSION).exe
OUT_WIN64_PORTABLE := $(DESKTOP_OUT)/$(PRODUCT_NAME)\ $(VERSION).exe
OUT_WIN64_BETTER_NAME := $(PRODUCT_NAME)_Setup_v$(VERSION).exe
OUT_WIN64_UNPACKED_BETTER_NAME := $(PRODUCT_NAME)_win-unpacked_v$(VERSION).zip
OUT_WIN64_PORTABLE_BETTER_NAME := $(PRODUCT_NAME)_win-portable_v$(VERSION)
OUT_MACOS := $(DESKTOP_OUT)/$(PRODUCT_NAME)-$(VERSION).dmg

RELEASE_DIR := release
CURRENT_RELEASE_DIR := $(RELEASE_DIR)/$(VERSION)


-include release.mk

setup:
	if [ ! -L "element-desktop/webapp" ]; then ./setup.sh; fi

regenerate-i18n: setup
	./regenerate_i18n.sh

reskindex: setup
	$(YARN) --cwd matrix-react-sdk reskindex
	$(YARN) --cwd element-web reskindex

web: export DIST_VERSION=$(WEB_OUT_DIST_VERSION)
web: setup reskindex
	cp $(CFGDIR)/config.json element-web/
	$(YARN) --cwd element-web dist
	echo "$(VERSION)" > element-web/webapp/version

desktop-common: web
	$(YARN) --cwd element-desktop run fetch --cfgdir ''
	$(YARN) --cwd element-desktop run build:native

linux: desktop-common
	$(YARN) --cwd element-desktop run build:64 --linux deb pacman tar.xz

debian: desktop-common
	$(YARN) --cwd element-desktop run build:64 --linux deb

pacman: desktop-common
	$(YARN) --cwd element-desktop run build:64 --linux pacman

appimage: desktop-common
	$(YARN) --cwd element-desktop run build:64 --linux AppImage

windows: desktop-common
	$(YARN) --cwd element-desktop run build:64 --windows nsis

windows-portable: desktop-common
	$(YARN) --cwd element-desktop run build:64 --windows portable

macos: desktop-common
	$(YARN) --cwd element-desktop run build --mac dmg -c.mac.identity=null

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

clean:
	$(YARN) --cwd matrix-js-sdk clean
	$(YARN) --cwd matrix-react-sdk clean
	$(YARN) --cwd element-web clean
	$(YARN) --cwd element-desktop clean
	rm -f element-desktop/webapp
	rm -rf element-web/dist
	rm -rf local-pkgbuild
