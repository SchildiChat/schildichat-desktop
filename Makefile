.PHONY: all web desktop desktop-common linux windows

all: desktop

web:
	yarn --cwd element-web dist

desktop-common: web
	yarn --cwd element-desktop run fetch --cfgdir ''
	yarn --cwd element-desktop run build:native

desktop: windows linux

linux: desktop-common
	yarn --cwd element-desktop run build64linux

windows: desktop-common
	yarn --cwd element-desktop run build64windows

-include release.mk
