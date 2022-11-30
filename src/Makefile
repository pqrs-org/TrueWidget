all:
	/usr/bin/python3 ../scripts/update-version.py
	bash run-xcodegen.sh
	xcodebuild -configuration Release -alltargets SYMROOT="$(CURDIR)/build"

clean: purge-swift-package-manager-cache
	rm -rf TrueWidget.xcodeproj
	rm -rf build

purge-swift-package-manager-cache:
	rm -rf ~/Library/Developer/Xcode/DerivedData/TrueWidget-*
	rm -rf ~/Library/Caches/org.swift.swiftpm/repositories/Sparkle-*

xcode:
	open TrueWidget.xcodeproj

run:
	bash ../scripts/codesign.sh build/Release
	open build/Release/TrueWidget.app

swift-format:
	find TrueWidget -name '*.swift' -print0 | xargs -0 swift-format -i

install:
	bash ../scripts/codesign.sh build/Release
	rsync -a --delete build/Release/TrueWidget.app /Applications
