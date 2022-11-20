all:
	/usr/bin/python3 ../scripts/update-version.py
	xcodegen generate --spec project.yml
	xcodebuild -configuration Release -alltargets SYMROOT="$(CURDIR)/build"

clean:
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

swiftformat:
	find . -name '*.swift' -print0 | xargs -0 swiftformat

install:
	bash ../scripts/codesign.sh build/Release
	rsync -a --delete build/Release/TrueWidget.app /Applications
