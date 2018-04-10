ADIUM_VERSION=adium-1.5.10.4
BUILDCONFIGURATION=Release

CWD=$(shell pwd)
ADIUM_FRAMEWORK_PATH=$(CWD)/Frameworks/adium

GLIB_FRAMEWORK_PATH=$(ADIUM_FRAMEWORK_PATH)/Frameworks/libglib.framework
GLIB_CFLAGS=$(addprefix -I,$(wildcard $(GLIB_FRAMEWORK_PATH)/Headers))

LIBPURPLE_FRAMEWORK_PATH=$(ADIUM_FRAMEWORK_PATH)/Frameworks/libpurple.framework
LIBPURPLE_CFLAGS=$(addprefix -I,$(wildcard $(LIBPURPLE_FRAMEWORK_PATH)/Headers))
LIBPURPLE_LDFLAGS=$(wildcard $(ADIUM_FRAMEWORK_PATH)/Frameworks/lib*.framework/lib*)

LIBGPGPERROR_FRAMEWORK_PATH=$(ADIUM_FRAMEWORK_PATH)/Frameworks/libgpgerror.framework

HG=hg
HGRC=~/.hgrc

XCODEBUILD?=xcodebuild

all: build-l4a

prepare: prepare-vendor

build-adium:
	$(ADIUM_FRAMEWORK_PATH)/build/Release-Debug/AIUtilities.framework/AIUtilities \
	$(ADIUM_FRAMEWORK_PATH)/build/Release-Debug/Adium.framework/AIUtilities \
	$(ADIUM_FRAMEWORK_PATH)/build/Release-Debug/AdiumLibpurple.framework/AIUtilities
build-carbons: vendor/carbons/build/carbons.a

build-l4a: build/$(BUILDCONFIGURATION)/Carbons4Adium.AdiumLibpurplePlugin
build/%/Carbons4Adium.AdiumLibpurplePlugin: Carbons4Adium.xcodeproj/project.pbxproj \
	$(ADIUM_FRAMEWORK_PATH)/build/Release-Debug/AIUtilities.framework/AIUtilities \
	$(ADIUM_FRAMEWORK_PATH)/build/Release-Debug/Adium.framework/AIUtilities \
	$(ADIUM_FRAMEWORK_PATH)/build/Release-Debug/AdiumLibpurple.framework/AIUtilities \
	vendor/carbons/build/carbons.a \
	Carbons4Adium/Carbons4Adium.h \
	Carbons4Adium/Carbons4Adium.m
	$(XCODEBUILD) -project Carbons4Adium.xcodeproj -configuration $(BUILDCONFIGURATION) build

vendor/carbon/Makefile: prepare-vendor
prepare-vendor: vendor/.updated
vendor/.updated:
	git submodule update --init --recursive
	touch $@

Frameworks/:
	mkdir -p $@

$(ADIUM_FRAMEWORK_PATH)/build/Release-Debug/AIUtilities.framework/AIUtilities: $(ADIUM_FRAMEWORK_PATH)/.built
$(ADIUM_FRAMEWORK_PATH)/build/Release-Debug/Adium.framework/AIUtilities: $(ADIUM_FRAMEWORK_PATH)/.built
$(ADIUM_FRAMEWORK_PATH)/build/Release-Debug/AdiumLibpurple.framework/AIUtilities: $(ADIUM_FRAMEWORK_PATH)/.built
$(ADIUM_FRAMEWORK_PATH)/.built: $(ADIUM_FRAMEWORK_PATH)/.checkout
	$(MAKE) -C $(ADIUM_FRAMEWORK_PATH) adium
	touch $(ADIUM_FRAMEWORK_PATH)/.built

$(ADIUM_FRAMEWORK_PATH)/Frameworks/libpurple.framework/libpurple: $(ADIUM_FRAMEWORK_PATH)/.checkout
$(ADIUM_FRAMEWORK_PATH)/.checkout:
	$(HG) clone https://bitbucket.org/adium/adium $(ADIUM_FRAMEWORK_PATH)
	cd $(ADIUM_FRAMEWORK_PATH); $(HG) checkout $(ADIUM_VERSION)
	touch $(ADIUM_FRAMEWORK_PATH)/.checkout

vendor/carbons/build/carbons.a: vendor/carbons/Makefile $(ADIUM_FRAMEWORK_PATH)/Frameworks/libpurple.framework/libpurple
	$(MAKE) -C vendor/carbons \
		"GLIB_CFLAGS=$(GLIB_CFLAGS)" \
		"GLIB_LDFLAGS=$(GLIB_LDFLAGS)" \
		"LIBPURPLE_CFLAGS=$(LIBPURPLE_CFLAGS)" \
		"LIBPURPLE_LDFLAGS=$(LIBPURPLE_LDFLAGS)" \
		"XML2_CFLAGS=-I/usr/include/libxml2" \
		"XML2_LDFLAGS=" \
		LJABBER= \
		build/carbons.a

clean: clean-adium clean-carbons clean-l4a
clean-carbons:
	$(MAKE) -C vendor/carbons clean
clean-adium:
	(test -d Frameworks/adium && $(MAKE) -C Frameworks/adium Frameworks/adium clean) || true
clean-l4a:
	rm -rf build/

real-clean: clean
	rm -rf Frameworks/
	rm -rf vendor/*/* vendor/*/.*

.PHONY: all prepare prepare-vendor build clean real-clean \
	build-adium clean-adium \
	build-carbons clean-carbons \
	build-l4a clean-l4a
