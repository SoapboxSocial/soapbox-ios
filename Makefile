.PHONY: protobuf setup format test lint autocorrect clean build release

APP="Soapbox"

# Apple
ifeq ($(shell uname),Darwin)
	PLATFORM=apple
	XCPRETTY_STATUS=$(shell xcpretty -v &>/dev/null; echo $$?)
	ifeq ($(XCPRETTY_STATUS),0)
		XCPRETTY=xcpretty
	else
		XCPRETTY=cat
	endif
endif

install_deps:
	rm -rf WebRTC.xcframework
	curl https://github.com/stasel/WebRTC/releases/download/90.0.0/WebRTC-M90.xcframework.zip -O -J -L
	unzip WebRTC-M90.xcframework.zip

setup: install_deps
        tuist generate -P

clean:
	rm -rf .build $(APP).xcodeproj $(APP).xcworkspace Package.pins Pods

release: clean setup
	fastlane release

test: clean setup install_deps
	set -o pipefail && swift test | $(XCPRETTY)

build: clean setup install_deps
	set -o pipefail && swift build | $(XCPRETTY)

lint:
	swiftlint

autocorrect:
	swiftlint autocorrect

linuxmain:
	swift test --generate-linuxmain

format:
	swiftformat .

protobuf:
ifdef BRANCH
	buf generate https://github.com/soapboxsocial/protobufs.git#branch=$(BRANCH) --path soapbox/v1/room.proto --path soapbox/v1/signal.proto
else
	buf generate https://github.com/soapboxsocial/protobufs.git --path soapbox/v1/room.proto --path soapbox/v1/signal.proto
endif
