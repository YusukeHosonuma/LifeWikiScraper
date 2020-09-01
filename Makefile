build:
	swift build

test:
	swift test --enable-test-discovery

run:
	.build/debug/Scraper

xcode:
	swift package generate-xcodeproj
