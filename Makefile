export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:14.0

INSTALL_TARGET_PROCESSES = PoolGame

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AimAssist

AimAssist_FILES = Tweak.xm AimAssistOverlay.mm AimAssistMenu.mm AimAssistSettings.mm
AimAssist_CFLAGS = -fobjc-arc
AimAssist_FRAMEWORKS = UIKit CoreGraphics QuartzCore OpenGLES
AimAssist_PRIVATE_FRAMEWORKS = AppSupport

include $(THEOS_MAKE_PATH)/tweak.mk
