APP_NAME = activeApp
APP_BINARY = build/$(APP_NAME)
BUILD_DIR = build
PKG_NAME = $(APP_NAME).pkg
INSTALL_PATH = /usr/local/bin
IDENTIFIER = com.etsy.$(APP_NAME)

all: $(PKG_NAME)

$(APP_BINARY): main.swift
	mkdir -p $(BUILD_DIR)
	swiftc -o $(APP_BINARY) main.swift

$(PKG_NAME): $(APP_BINARY)
	mkdir -p $(BUILD_DIR)/payload$(INSTALL_PATH)
	cp $(APP_BINARY) $(BUILD_DIR)/payload$(INSTALL_PATH)/$(APP_NAME)
	pkgbuild \
		--root $(BUILD_DIR)/payload \
		--identifier $(IDENTIFIER) \
		--install-location / \
		$(PKG_NAME)

clean:
	rm -rf $(BUILD_DIR) $(PKG_NAME)

