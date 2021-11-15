.DEFAULT := help
.PHONY: build help

help:
	@echo 'targets'
	@echo
	@echo '		build			build the project and install to /usr/local/bin'
	@echo
	@echo ' 	help			show this message'
	@echo

build:
	xcodebuild -scheme mp4SearchAndWrite build
