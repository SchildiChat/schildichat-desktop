.PHONY: all web desktop desktop-common linux windows

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

windows: desktop-common
	$(YARN) --cwd element-desktop run build64windows
