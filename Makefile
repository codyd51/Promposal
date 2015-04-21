ARCHS = armv7 arm64
GO_EASY_ON_ME=1
include theos/makefiles/common.mk

TWEAK_NAME = Spring
Spring_FILES = Tweak.xm
Spring_FRAMEWORKS = UIKit CoreGraphics QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard; killall -9 Messages; killall -9 backboardd"
