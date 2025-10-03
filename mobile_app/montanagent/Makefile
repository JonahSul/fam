# MontaNAgent Build Automation
# Provides convenient commands for building, testing, and deploying

.PHONY: help install clean test analyze build-android build-ios build-web deploy-web

# Default target
help:
	@echo "MontaNAgent Build Commands:"
	@echo ""
	@echo "Setup and Maintenance:"
	@echo "  make install        - Install dependencies"
	@echo "  make clean          - Clean build artifacts"
	@echo ""
	@echo "Development:"
	@echo "  make test           - Run all tests"
	@echo "  make analyze        - Run static analysis"
	@echo "  make format         - Format code"
	@echo ""
	@echo "Building:"
	@echo "  make build-android  - Build Android APK (release)"
	@echo "  make build-ios      - Build iOS app (release)"
	@echo "  make build-web      - Build web app (release)"
	@echo ""
	@echo "Deployment:"
	@echo "  make deploy-web     - Build and deploy web app to Firebase"
	@echo ""

# Install dependencies
install:
	flutter pub get

# Clean build artifacts
clean:
	flutter clean
	flutter pub get

# Run tests
test:
	flutter test

# Run static analysis
analyze:
	flutter analyze

# Format code
format:
	dart format lib/ test/

# Build Android release APK
build-android:
	@echo "Building Android APK..."
	flutter build apk --release
	@echo "APK built: build/app/outputs/flutter-apk/app-release.apk"

# Build Android App Bundle (for Play Store)
build-android-bundle:
	@echo "Building Android App Bundle..."
	flutter build appbundle --release
	@echo "Bundle built: build/app/outputs/bundle/release/app-release.aab"

# Build iOS release
build-ios:
	@echo "Building iOS app..."
	flutter build ios --release
	@echo "iOS app built in build/ios/iphoneos/"

# Build web release
build-web:
	@echo "Building web app..."
	flutter build web --release
	@echo "Web app built in build/web/"

# Deploy web app to Firebase Hosting
deploy-web: build-web
	@echo "Deploying to Firebase Hosting..."
	firebase deploy --only hosting
	@echo "Deployment complete!"

# Run in development mode
run:
	flutter run

# Run on specific platform
run-web:
	flutter run -d chrome

run-android:
	flutter run -d android

run-ios:
	flutter run -d ios

# Pre-commit checks (run before committing)
pre-commit: format analyze test
	@echo "Pre-commit checks passed!"
