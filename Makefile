.PHONY: all web desktop desktop-common linux windows windows-portable clean

CFGDIR ?= configs/sc

all: desktop

YARN ?= yarnpkg


-include release.mk


web:
	cp $(CFGDIR)/config.json element-web/
	$(YARN) --cwd element-web dist

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

windows: desktop-common
	$(YARN) --cwd element-desktop run build64windows

windows-portable: desktop-common
	$(YARN) --cwd element-desktop run build64windows-portable

clean:
	$(YARN) --cwd matrix-js-sdk clean
	$(YARN) --cwd matrix-react-sdk clean
	$(YARN) --cwd element-web clean
	$(YARN) --cwd element-desktop clean
