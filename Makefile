.PHONY: all web desktop

all: desktop

web:
	yarn --cwd element-web dist

desktop: web
	yarn --cwd element-desktop run fetch --cfgdir ''
	yarn --cwd element-desktop run build:native
	yarn --cwd element-desktop run build
