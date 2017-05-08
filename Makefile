ADIUM_VERSION=adium-1.5.10.4
BUILDCONFIGURATION=Release

CWD=$(shell pwd)
ADIUM_FRAMEWORK_PATH=$(CWD)/Frameworks/adium
LIBPURPLE_FRAMEWORK_PATH=$(ADIUM_FRAMEWORK_PATH)/Frameworks/libpurple.framework
LIBPURPLE_FRAMEWORK_CFLAGS=$(addprefix -I,$(wildcard $(ADIUM_FRAMEWORK_PATH)/Frameworks/libpurple.framework/Headers))
LIBPURPLE_FRAMEWORK_LIBS=$(wildcard $(ADIUM_FRAMEWORK_PATH)/Frameworks/lib*.framework/lib*)

HG=hg
HGRC=~/.hgrc

XCODEBUILD?=xcodebuild

all: build-l4a

prepare: prepare-vendor build-adium build-lurch build-carbons build-l4a

build-adium:
	$(ADIUM_FRAMEWORK_PATH)/build/Release-Debug/AIUtilities.framework/AIUtilities \
	$(ADIUM_FRAMEWORK_PATH)/build/Release-Debug/Adium.framework/AIUtilities \
	$(ADIUM_FRAMEWORK_PATH)/build/Release-Debug/AdiumLibpurple.framework/AIUtilities
build-carbons: vendor/carbons/build/carbons.a
build-lurch: vendor/lurch/build/lurch.a
build-mxml: vendor/mxml/libmxml.a

build-l4a: build/$(BUILDCONFIGURATION)/Lurch4Adium.AdiumPlugin
build/%/Lurch4Adium.AdiumPlugin: Lurch4Adium.xcodeproj/project.pbxproj \
	$(ADIUM_FRAMEWORK_PATH)/build/Release-Debug/AIUtilities.framework/AIUtilities \
	$(ADIUM_FRAMEWORK_PATH)/build/Release-Debug/Adium.framework/AIUtilities \
	$(ADIUM_FRAMEWORK_PATH)/build/Release-Debug/AdiumLibpurple.framework/AIUtilities \
	vendor/carbons/build/carbons.a \
	vendor/lurch/build/lurch.a \
	Lurch4Adium.h \
	Lurch4Adium.m
	$(XCODEBUILD) -project Lurch4Adium.xcodeproj -configuration $(BUILDCONFIGURATION) build

prepare-vendor:
	git submodule update --init --recursive

fix-hg-conf:
	grep -q hg.adium.im:minimumprotocol $(HGRC) 2>/dev/null \
		|| (echo '[hostsecurity]'; echo 'hg.adium.im:minimumprotocol=tls1.0') >> $(HGRC)

Frameworks/:
	mkdir -p $@

$(ADIUM_FRAMEWORK_PATH)/build/Release-Debug/AIUtilities.framework/AIUtilities: $(ADIUM_FRAMEWORK_PATH)/.built
$(ADIUM_FRAMEWORK_PATH)/build/Release-Debug/Adium.framework/AIUtilities: $(ADIUM_FRAMEWORK_PATH)/.built
$(ADIUM_FRAMEWORK_PATH)/build/Release-Debug/AdiumLibpurple.framework/AIUtilities: $(ADIUM_FRAMEWORK_PATH)/.built
$(ADIUM_FRAMEWORK_PATH)/.built: $(ADIUM_FRAMEWORK_PATH)/.checkout
	cd $(ADIUM_FRAMEWORK_PATH)/; $(MAKE) adium
	touch $(ADIUM_FRAMEWORK_PATH)/.built

$(ADIUM_FRAMEWORK_PATH)/Frameworks/libpurple.framework/libpurple: $(ADIUM_FRAMEWORK_PATH)/.checkout
$(ADIUM_FRAMEWORK_PATH)/.checkout:
	$(MAKE) Frameworks fix-hg-conf # Don't want to rebuild on those targets
	$(HG) clone https://hg.adium.im/adium $(ADIUM_FRAMEWORK_PATH)
	cd $(ADIUM_FRAMEWORK_PATH); $(HG) checkout $(ADIUM_VERSION)
	touch $(ADIUM_FRAMEWORK_PATH)/.checkout

vendor/lurch/build/lurch.a: $(ADIUM_FRAMEWORK_PATH)/Frameworks/libpurple.framework/libpurple
	$(MAKE) -C vendor/lurch "LIBPURPLE_CFLAGS=$(LIBPURPLE_FRAMEWORK_CFLAGS)" "LIBPURPLE_LDFLAGS=$(LIBPURPLE_FRAMEWORK_LIBS)" LJABBER= build/lurch.a

vendor/carbons/build/carbons.a: $(ADIUM_FRAMEWORK_PATH)/Frameworks/libpurple.framework/libpurple
	$(MAKE) -C vendor/carbons "LIBPURPLE_CFLAGS=$(LIBPURPLE_FRAMEWORK_CFLAGS)" "LIBPURPLE_LDFLAGS=$(LIBPURPLE_FRAMEWORK_LIBS)" LJABBER= build/carbons.a

vendor/mxml/libmxml.a: vendor/mxml/Makefile
	$(MAKE) -C vendor/mxml libmxml.a
vendor/mxml/Makefile:
	cd vendor/mxml; ./configure --disable-shared --disable-threads --disable-debug

clean: clean-adium clean-carbons clean-lurch clean-l4a
clean-carbons:
	cd vendor/carbons; $(MAKE) clean
clean-adium:
	(test -d Frameworks/adium && cd Frameworks/adium && $(MAKE) clean) || true
clean-l4a:
	rm -rf build/
clean-lurch:
	cd vendor/lurch; $(MAKE) clean
clean-mxml:
	$(MAKE) -C vendor/mxml clean

real-clean: clean
	rm -rf Frameworks/
	rm -rf vendor/*/* vendor/*/.*

.PHONY: all prepare prepare-vendor build clean real-clean \
	fix-hg-conf build-adium clean-adium \
	build-carbons clean-carbons \
	build-l4a clean-l4a \
	build-lurch clean-lurch \
	build-mxml clean-mxml
