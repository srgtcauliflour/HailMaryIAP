TARGET = iphone:clang:latest:14.0
ARCHS = arm64 arm64e

TWEAK_NAME = UniversalIAPCracker
UniversalIAPCracker_FILES = Tweak.xm
UniversalIAPCracker_CFLAGS = -fobjc-arc -fvisibility=hidden
UniversalIAPCracker_LDFLAGS = -dynamiclib

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/library.mk
