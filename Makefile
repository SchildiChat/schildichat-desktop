.PHONY: all setup web desktop desktop-common linux windows windows-portable
.PHONY: web-release debian-release pacman-release windows-setup-release windows-unpacked-release windows-portable-release windows-release release
.PHONY: clean

CFGDIR ?= configs/sc

all: release

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

RELEASE_DIR := release
CURRENT_RELEASE_DIR := $(RELEASE_DIR)/$(VERSION)


-include release.mk

setup:
	if [ ! -L "element-desktop/webapp" ]; then ./setup.sh; fi
	cp $(CFGDIR)/config.json element-web/

web: export DIST_VERSION=$(WEB_OUT_DIST_VERSION)
web: setup
	$(YARN) --cwd element-web dist
	echo "$(VERSION)" > element-web/webapp/version

desktop-common: web
	$(YARN) --cwd element-desktop run fetch --cfgdir ''
	$(YARN) --cwd element-desktop run build:native

desktop: windows linux

linux: desktop-common
	$(YARN) --cwd element-desktop run build64linux

debian: desktop-common
	$(YARN) --cwd element-desktop run build64deb

pacman: desktop-common
	$(YARN) --cwd element-desktop run build64pacman

appimage: desktop-common
	$(YARN) --cwd element-desktop run build64appimage

windows: desktop-common
	$(YARN) --cwd element-desktop run build64windows

windows-portable: desktop-common
	$(YARN) --cwd element-desktop run build64windows-portable

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

release: web-release debian-release pacman-release windows-release

clean:
	$(YARN) --cwd matrix-js-sdk clean
	$(YARN) --cwd matrix-react-sdk clean
	$(YARN) --cwd element-web clean
	$(YARN) --cwd element-desktop clean
	rm -f element-desktop/webapp
	rm -rf element-web/dist
