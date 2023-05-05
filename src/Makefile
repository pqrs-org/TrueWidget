all:
	/usr/bin/python3 ../scripts/update-version.py
	bash run-xcodegen.sh
	xcodebuild -configuration Release -alltargets SYMROOT="$(CURDIR)/build"
# Copy embedded.provisionprofile
	cp TrueWidget/embedded.provisionprofile build/Release/TrueWidget.app/Contents
	$(MAKE) codesign
	$(MAKE) -C .. clean-launch-services-database

clean: purge-swift-package-manager-cache
	rm -rf TrueWidget.xcodeproj
	rm -rf build

codesign:
# Helper
	bash ../scripts/codesign.sh 'build/Release/TrueWidget.app/Contents/XPCServices/TrueWidget Helper.xpc' $(CURDIR)/Helper/Helper.entitlements
# DeprecatedOpenAtLoginHelper
	bash ../scripts/codesign.sh 'build/Release/TrueWidget.app/Contents/XPCServices/TrueWidget DeprecatedOpenAtLoginHelper.xpc' $(CURDIR)/DeprecatedOpenAtLoginHelper/DeprecatedOpenAtLoginHelper.entitlements
# Sparkle
	bash ../scripts/codesign.sh build/Release/TrueWidget.app/Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Installer.xpc
	bash ../scripts/codesign.sh build/Release/TrueWidget.app/Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Downloader.xpc $(CURDIR)/org.sparkle-project.Downloader.entitlements
	bash ../scripts/codesign.sh build/Release/TrueWidget.app/Contents/Frameworks/Sparkle.framework/Versions/B/Autoupdate
	bash ../scripts/codesign.sh build/Release/TrueWidget.app/Contents/Frameworks/Sparkle.framework/Versions/B/Updater.app
	bash ../scripts/codesign.sh build/Release/TrueWidget.app/Contents/Frameworks/Sparkle.framework
# TrueWidget
	bash ../scripts/codesign.sh build/Release/TrueWidget.app $(CURDIR)/TrueWidget/TrueWidget.entitlements

purge-swift-package-manager-cache:
	rm -rf ~/Library/Developer/Xcode/DerivedData/TrueWidget-*
	rm -rf ~/Library/Caches/org.swift.swiftpm/repositories/Sparkle-*

xcode:
	open TrueWidget.xcodeproj

run:
	open build/Release/TrueWidget.app

swift-format:
	find . -name '*.swift' -print0 | xargs -0 swift-format -i

install:
	rsync -a --delete build/Release/TrueWidget.app /Applications
