BUILDCONFIGURATION=Release

CWD=$(shell pwd)
ADIUM_FRAMEWORK_PATH=$(CWD)/Frameworks/adium
ADIUM_PATCHES=$(sort $(wildcard *.adium.patch))

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

LIBXML2_CFLAGS=-I/usr/include/libxml2 \
	       -I/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/libxml2

MXML_PATH=$(CWD)/vendor/mxml
MXML_CFLAGS=$(addprefix -I,$(wildcard $(MXML_PATH)))
MXML_LDLAGS=$(addprefix -L,$(wildcard $(MXML_PATH)))

XCODEBUILD?=xcodebuild

all: build-l4a

prepare: prepare-vendor

patch-adium: $(ADIUM_FRAMEWORK_PATH)/.patched
build-adium: $(ADIUM_FRAMEWORK_PATH)/.built
build-carbons: vendor/carbons/build/carbons.a
build-lurch: vendor/lurch/build/lurch.a
build-mxml: vendor/mxml/libmxml.a

build-l4a: build/$(BUILDCONFIGURATION)/Lurch4Adium.AdiumLibpurplePlugin
build/%/Lurch4Adium.AdiumLibpurplePlugin: Lurch4Adium.xcodeproj/project.pbxproj \
	$(ADIUM_FRAMEWORK_PATH)/.built \
	vendor/carbons/build/carbons.a \
	vendor/lurch/build/lurch.a \
	Lurch4Adium/Lurch4Adium.h \
	Lurch4Adium/Lurch4Adium.m
	$(XCODEBUILD) -project Lurch4Adium.xcodeproj -configuration $(BUILDCONFIGURATION) build

$(ADIUM_FRAMEWORK_PATH)/Makefile: prepare-vendor
vendor/lurch/Makefile: prepare-vendor
vendor/carbons/Makefile: prepare-vendor
prepare-vendor: vendor/.updated
vendor/.updated:
	git submodule update --init --recursive
	touch $@

Frameworks/:
	mkdir -p $@

$(ADIUM_FRAMEWORK_PATH)/.patched: $(ADIUM_PATCHES) $(ADIUM_FRAMEWORK_PATH)/Makefile
	for PATCH in $(ADIUM_PATCHES); do \
		cat $${PATCH} | git -C $(ADIUM_FRAMEWORK_PATH)/ am; \
	done
	touch $@
$(ADIUM_FRAMEWORK_PATH)/.built: $(ADIUM_FRAMEWORK_PATH)/.patched
	$(MAKE) -C $(ADIUM_FRAMEWORK_PATH) adium
	touch $@

vendor/carbons/build/carbons.a: vendor/carbons/Makefile $(ADIUM_FRAMEWORK_PATH)/Frameworks/libpurple.framework/libpurple
	$(MAKE) -C vendor/carbons \
		"GLIB_CFLAGS=$(GLIB_CFLAGS)" \
		"GLIB_LDFLAGS=$(GLIB_LDFLAGS)" \
		"LIBPURPLE_CFLAGS=$(LIBPURPLE_CFLAGS) -DPURPLE_STATIC_PRPL" \
		"LIBPURPLE_LDFLAGS=$(LIBPURPLE_LDFLAGS)" \
		"XML2_CFLAGS=$(LIBXML2_CFLAGS)" \
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
		"XML2_CFLAGS=$(LIBXML2_CFLAGS)" \
		"XML2_LDFLAGS=" \
		LJABBER= \
		build/lurch.a

vendor/mxml/libmxml.a: vendor/mxml/Makefile
	$(MAKE) -C vendor/mxml libmxml.a
vendor/mxml/Makefile:
	cd vendor/mxml; ./configure --disable-shared --disable-threads --disable-debug

clean: clean-adium clean-carbons clean-l4a clean-lurch clean-mxml
clean-adium:
	test ! -e $(ADIUM_FRAMEWORK_PATH)/.built || $(MAKE) -C $(ADIUM_FRAMEWORK_PATH) clean
	rm -f $(ADIUM_FRAMEWORK_PATH)/.built
	test ! -e $(ADIUM_FRAMEWORK_PATH)/.patched || git -C $(ADIUM_FRAMEWORK_PATH)/ checkout HEAD~$(words $(ADIUM_PATCHES))
	rm -rf /Users/omehani/src/Lurch4Adium/.git/modules/Frameworks/adium/rebase-apply/
	rm -f $(ADIUM_FRAMEWORK_PATH)/.patched
clean-carbons:
	test ! -f vendor/carbons/Makefile || $(MAKE) -C vendor/carbons clean
clean-l4a:
	rm -rf build/
clean-lurch:
	test ! -f vendor/lurch/Makefile || $(MAKE) -C vendor/lurch clean-all
clean-mxml:
	test ! -f vendor/mxml/Makefile || $(MAKE) -C vendor/mxml clean

real-clean: clean
	git submodule deinit --all --force
	rm -f vendor/.updated

.PHONY: all prepare prepare-vendor build clean real-clean \
	build-adium clean-adium \
	build-carbons clean-carbons \
	build-l4a clean-l4a \
	build-lurch clean-lurch \
	build-mxml clean-mxml
