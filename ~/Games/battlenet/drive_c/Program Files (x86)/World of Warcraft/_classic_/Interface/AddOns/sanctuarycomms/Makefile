ADDON_NAME := SanctuaryComms
VERSION := $(shell sed -n 's/^## Version: *//p' $(ADDON_NAME).toc)
ZIP_NAME := $(ADDON_NAME)-v$(VERSION).zip

ADDON_FILES := $(wildcard *.toc *.lua *.xml)
DIST_FILES := README.md $(ADDON_FILES)

.PHONY: all clean

all: $(ZIP_NAME)

$(ZIP_NAME): $(DIST_FILES)
	zip -r $@ $(DIST_FILES)

clean:
	rm -f $(ZIP_NAME)