VERSION = `head -n 1 version`

all:
	$(MAKE) gitclean
	$(MAKE) clean
	./make-package.sh

build:
	$(MAKE) -C src

clean:
	$(MAKE) -C src clean
	rm -f *.dmg

gitclean:
	git clean -f -x -d

notarize:
	xcrun notarytool \
		submit TrueWidget-$(VERSION).dmg \
		--keychain-profile "pqrs.org notarization" \
		--wait
	$(MAKE) staple
	say "notarization completed"

staple:
	xcrun stapler staple TrueWidget-$(VERSION).dmg

check-staple:
	@xcrun stapler validate TrueWidget-$(VERSION).dmg

swift-format:
	$(MAKE) -C src swift-format
