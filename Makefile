ADIUM_VERSION=adium-1.5.10.4

HG=hg
HGRC=~/.hgrc

all: prepare

prepare: prepare-adium prepare-vendor

prepare-vendor:
	git submodule update --init --recursive

prepare-adium: Frameworks/adium/.built

fix-hg-conf:
	grep -q hg.adium.im:minimumprotocol $(HGRC) 2>/dev/null \
		|| (echo '[hostsecurity]'; echo 'hg.adium.im:minimumprotocol=tls1.0') >> $(HGRC)

Frameworks/adium/.built: Frameworks/adium/.checkout
	cd Frameworks/adium/; $(MAKE) adium
	touch $@

Frameworks/adium/.checkout: Frameworks/
	$(MAKE) fix-hg-conf
	cd $<; $(HG) clone https://hg.adium.im/adium
	cd $</adium; $(HG) checkout $(ADIUM_VERSION)
	touch $@

Frameworks/:
	mkdir -p $@

clean: clean-adium
clean-adium:
	cd Frameworks/adium; make clean
clean-lurch:
	cd vendor/lurch; make clean
clean-carbon:
	cd vendor/carbon; make clean

real-clean:
	rm -rf Frameworks/

.PHONY: all prepare prepare-vendor clean real-clean \
	prepare-lurch clean-lurch \
	prepare-carbons clean-carbons \
	fix-hg-conf prepare-adium clean-adium \
