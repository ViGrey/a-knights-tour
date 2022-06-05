# Copyright (C) 2020, Vi Grey
# All rights reserved.

PKG_NAME := a-knights-tour
CURRENTDIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

all:
	mkdir -p $(CURRENTDIR)bin; \
	cd $(CURRENTDIR)src; \
	asm $(PKG_NAME).asm ../bin/$(PKG_NAME).nes; \

clean:
	rm -f -- $(CURRENTDIR)bin/$(PKG_NAME).nes*; \
	rm -rf -- $(CURRENTDIR)bin/build; \

setup:
	$(CURRENTDIR)proto-date; \

zip:
	mkdir -p $(CURRENTDIR)bin; \
	mkdir -p $(CURRENTDIR)bin/build; \
	rm -f -- $(CURRENTDIR)bin/$(PKG_NAME).nes*; \
	rm -f -- $(CURRENTDIR)bin/build/*; \
	rm -rf -- /tmp/$(PKG_NAME); \
	cp -r $(CURRENTDIR) /tmp/$(PKG_NAME); \
	cp -r /tmp/$(PKG_NAME) $(CURRENTDIR)bin/build/./; \
	rm -rf -- $(CURRENTDIR)bin/build/$(PKG_NAME)/bin/demo; \
	cd $(CURRENTDIR)bin/build; \
  zip -r $(PKG_NAME).zip $(PKG_NAME); \
	cd $(CURRENTDIR)src; \
	asm $(PKG_NAME).asm ../bin/build/$(PKG_NAME).nes; \
	cd $(CURRENTDIR)bin/build; \
	cat $(PKG_NAME).nes > $(PKG_NAME)-build.nes; \
	cat $(PKG_NAME).zip >> $(PKG_NAME)-build.nes; \
	zip -F $(PKG_NAME)-build.nes --out $(PKG_NAME)-final.zip; \
	cp $(PKG_NAME)-final.zip ../$(PKG_NAME).nes; \

save:
	cp $(CURRENTDIR)bin/$(PKG_NAME).nes $(CURRENTDIR)bin/demo/$(PKG_NAME)-$$(head -c 10 $(CURRENTDIR)current.txt).nes; \
