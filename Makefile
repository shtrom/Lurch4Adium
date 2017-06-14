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

LIBGCRYPT_FRAMEWORK_PATH=$(ADIUM_FRAMEWORK_PATH)/Frameworks/libgcrypt.framework
LIBGCRYPT_CFLAGS=$(addprefix -I,$(wildcard $(LIBGCRYPT_FRAMEWORK_PATH)/Headers) \
		$(wildcard $(LIBGPGPERROR_FRAMEWORK_PATH)/Headers))
LIBGCRYPT_LDFLAGS=$(wildcard $(LIBGCRYPT_FRAMEWORK_PATH)/lib*) \
		  $(wildcard $(LIBGPGPERROR_FRAMEWORK_PATH)/lib*)

MXML_PATH=$(CWD)/vendor/mxml
MXML_CFLAGS=$(addprefix -I,$(wildcard $(MXML_PATH)))
MXML_LDLAGS=$(addprefix -L,$(wildcard $(MXML_PATH)))

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
build-lurch: vendor/lurch/build/lurch.a
build-mxml: vendor/mxml/libmxml.a

build-l4a: build/$(BUILDCONFIGURATION)/Lurch4Adium.AdiumLibpurplePlugin
build/%/Lurch4Adium.AdiumLibpurplePlugin: Lurch4Adium.xcodeproj/project.pbxproj \
	$(ADIUM_FRAMEWORK_PATH)/build/Release-Debug/AIUtilities.framework/AIUtilities \
	$(ADIUM_FRAMEWORK_PATH)/build/Release-Debug/Adium.framework/AIUtilities \
	$(ADIUM_FRAMEWORK_PATH)/build/Release-Debug/AdiumLibpurple.framework/AIUtilities \
	vendor/carbons/build/carbons.a \
	vendor/lurch/build/lurch.a \
	Lurch4Adium/Lurch4Adium.h \
	Lurch4Adium/Lurch4Adium.m
	$(XCODEBUILD) -project Lurch4Adium.xcodeproj -configuration $(BUILDCONFIGURATION) build

vendor/lurch/Makefile: prepare-vendor
vendor/carbon/Makefile: prepare-vendor
prepare-vendor: vendor/.updated
vendor/.updated:
	git submodule update --init --recursive
	touch $@

fix-hg-conf:
	grep -q hg.adium.im:minimumprotocol $(HGRC) 2>/dev/null \
		|| (echo '[hostsecurity]'; echo 'hg.adium.im:minimumprotocol=tls1.0') >> $(HGRC)

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
	$(MAKE) Frameworks fix-hg-conf # Don't want to rebuild on those targets
	$(HG) clone https://hg.adium.im/adium $(ADIUM_FRAMEWORK_PATH)
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

vendor/lurch/build/lurch.a: vendor/lurch/Makefile $(ADIUM_FRAMEWORK_PATH)/Frameworks/libpurple.framework/libpurple vendor/mxml/libmxml.a
	$(MAKE) -C vendor/lurch \
		"GLIB_CFLAGS=$(GLIB_CFLAGS)" \
		"GLIB_LDFLAGS=$(GLIB_LDFLAGS)" \
		"LIBPURPLE_CFLAGS=$(LIBPURPLE_CFLAGS)" \
		"LIBPURPLE_LDFLAGS=$(LIBPURPLE_LDFLAGS)" \
		"LIBGCRYPT_CFLAGS=$(LIBGCRYPT_CFLAGS)" \
		"LIBGCRYPT_LDFLAGS=$(LIBGCRYPT_LDFLAGS)" \
		"MXML_CFLAGS=$(MXML_CFLAGS)" \
		"MXML_LDFLAGS=$(MXML_LDFLAGS)" \
		"XML2_CFLAGS=-I/usr/include/libxml2" \
		"XML2_LDFLAGS=" \
		LJABBER= \
		build/lurch.a

vendor/mxml/libmxml.a: vendor/mxml/Makefile
	$(MAKE) -C vendor/mxml libmxml.a
vendor/mxml/Makefile:
	cd vendor/mxml; ./configure --disable-shared --disable-threads --disable-debug

clean: clean-adium clean-carbons clean-lurch clean-l4a
clean-carbons:
	$(MAKE) -C vendor/carbons clean
clean-adium:
	(test -d Frameworks/adium && $(MAKE) -C Frameworks/adium Frameworks/adium clean) || true
clean-l4a:
	rm -rf build/
clean-lurch:
	$(MAKE) -C vendor/lurch clean-all
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
