TARGET := iphone:clang:latest:14.0
ARCHS := arm64
DEBUG := 0
FINALPACKAGE := 1

THEOS_PACKAGE_SCHEME := rootless

TWEAK_NAME := WhamRaptor

WhamRaptor_FILES := \
	Tweak/Bootstrap.m \
	Tweak/Core/WRPaths.m \
	Tweak/Core/WRContainer.m \
	Tweak/Core/WRContainerStore.m \
	Tweak/Core/WRHomeRedirect.m \
	Tweak/Core/WRAppRelaunch.m \
	Tweak/Spoof/WRDeviceIdentity.m \
	Tweak/Spoof/WRDeviceSpoof.m \
	Tweak/Spoof/WRLocaleSpoof.m \
	Tweak/Spoof/WRTimezoneSpoof.m \
	Tweak/Spoof/WRLocationSpoof.m \
	Tweak/Spoof/WRHardening.m \
	Tweak/Spoof/WRKeychainHook.m \
	Tweak/Spoof/WRPrefsHook.m \
	Tweak/Spoof/WRAppGroupHook.m \
	Tweak/Spoof/WRPasteboardHook.m \
	Tweak/UI/WRFloatingButton.m \
	Tweak/UI/WRPanelVC.m \
	Tweak/UI/WRCreateVC.m \
	Tweak/UI/WRMapPickerVC.m \
	Tweak/UI/WRListPickerVC.m \
	Tweak/UI/WRGlass.m \
	Tweak/UI/WRTheme.m \
	Tweak/UI/WRL10n.m \
	Tweak/UI/WRActionSheet.m \
	Tweak/Util/WRLaunchGuard.m \
	Tweak/Util/WRDiagnostics.m \
	vendor/fishhook/fishhook.c

WhamRaptor_CFLAGS := -fobjc-arc -fobjc-arc-exceptions -Ivendor/fishhook -ITweak -ITweak/Core -ITweak/Spoof -ITweak/UI -ITweak/Util -Wno-deprecated-declarations -Wno-unused-function -Wno-objc-protocol-method-implementation -Wno-nullability-completeness -Wno-nullability-completeness-on-arrays
WhamRaptor_FRAMEWORKS := UIKit Foundation CoreLocation MapKit QuartzCore CoreGraphics Security
WhamRaptor_PRIVATE_FRAMEWORKS :=
WhamRaptor_LDFLAGS := -weak_framework CoreLocation -weak_framework MapKit

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
