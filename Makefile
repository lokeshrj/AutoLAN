APP_NAME = AutoLAN
BUILD_DIR = build
APP_BUNDLE = $(BUILD_DIR)/$(APP_NAME).app
CONTENTS = $(APP_BUNDLE)/Contents
MACOS_DIR = $(CONTENTS)/MacOS

.PHONY: build install clean

build:
	@echo "Compiling $(APP_NAME)..."
	mkdir -p $(MACOS_DIR)
	swiftc Sources/main.swift \
		-swift-version 5 \
		-o $(MACOS_DIR)/$(APP_NAME) \
		-framework Cocoa \
		-framework Network \
		-framework CoreWLAN \
		-framework ServiceManagement
	mkdir -p $(CONTENTS)/Resources
	cp Resources/AppIcon.icns $(CONTENTS)/Resources/AppIcon.icns
	cp Info.plist $(CONTENTS)/Info.plist
	codesign --force --sign - $(APP_BUNDLE)
	@echo "Built $(APP_BUNDLE)"

install: build
	@echo "Installing to /Applications/..."
	cp -R $(APP_BUNDLE) /Applications/$(APP_NAME).app
	@echo "Installed."

clean:
	rm -rf $(BUILD_DIR)
	@echo "Cleaned."
