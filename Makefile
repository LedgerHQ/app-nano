#*******************************************************************************
#   Ledger App
#   (c) 2017 Ledger
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#*******************************************************************************

ifeq ($(BOLOS_SDK),)
$(error Environment variable BOLOS_SDK is not set)
endif

include $(BOLOS_SDK)/Makefile.target

########################################
#        Mandatory configuration       #
########################################
# Application name
APPNAME = "Boilerplate"

# Application version
APPVERSION_M = 1
APPVERSION_N = 3
APPVERSION_P = 0
APPVERSION = "$(APPVERSION_M).$(APPVERSION_N).$(APPVERSION_P)"

# Application source files
APP_SOURCE_PATH += src

# Application icons following guidelines:
# https://developers.ledger.com/docs/embedded-app/design-requirements/#device-icon
ICON_NANOX = icons/$(COIN)_14px.gif
ICON_NANOSP = icons/$(COIN)_14px.gif
ICON_NANOS = icons/$(COIN)_16px.gif
#ICON_STAX = icons/app_boilerplate_32px.gif
#ICON_FLEX = icons/app_boilerplate_40px.gif
ICON_BLUE = icons/${COIN}_50px.gif
#ICON_APEX_P = icons/app_boilerplate_32px_apex.png

# Setting to allow building variant applications
# - <VARIANT_PARAM> is the name of the parameter which should be set
#   to specify the variant that should be build.
# - <VARIANT_VALUES> a list of variant that can be build using this app code.
#   * It must at least contains one value.
#   * Values can be the app ticker or anything else but should be unique.
VARIANT_PARAM = COIN
VARIANT_VALUES = nano banano nos

# Enabling DEBUG flag will enable PRINTF and disable optimizations
#DEBUG = 1

########################################
#     Application custom permissions   #
########################################
# See SDK `include/appflags.h` for the purpose of each permission
#HAVE_APPLICATION_FLAG_DERIVE_MASTER = 1
#HAVE_APPLICATION_FLAG_GLOBAL_PIN = 1
#HAVE_APPLICATION_FLAG_BOLOS_SETTINGS = 1
#HAVE_APPLICATION_FLAG_LIBRARY = 1

########################################
# Application communication interfaces #
########################################
ENABLE_BLUETOOTH = 1
#ENABLE_NFC = 1
ENABLE_NBGL_FOR_NANO_DEVICES = 0

########################################
#         NBGL custom features         #
########################################
#ENABLE_NBGL_QRCODE = 1
#ENABLE_NBGL_KEYBOARD = 1
#ENABLE_NBGL_KEYPAD = 1

########################################
#          Features disablers          #
########################################
# These advanced settings allow to disable some feature that are by
# default enabled in the SDK `Makefile.standard_app`.
#DISABLE_STANDARD_APP_FILES = 1
#DISABLE_DEFAULT_IO_SEPROXY_BUFFER_SIZE = 1 # To allow custom size declaration
#DISABLE_STANDARD_APP_DEFINES = 1 # Will set all the following disablers
#DISABLE_STANDARD_SNPRINTF = 1
#DISABLE_STANDARD_USB = 1
#DISABLE_STANDARD_WEBUSB = 1
#DISABLE_DEBUG_LEDGER_ASSERT = 1
#DISABLE_DEBUG_THROW = 1

########################################
#           Nano S (Legacy)            #
########################################
ifeq ($(TARGET_NAME),TARGET_NANOS)
        DEFINES += HAVE_UX_LEGACY
else
        DEFINES += HAVE_UX_FLOW
endif

ifeq (customCA.key,$(wildcard customCA.key))
    SCP_PRIVKEY=`cat customCA.key`
endif

# Default to shared app
ifeq ($(APP_TYPE),)
APP_TYPE=shared
endif

# Default to library app
ifndef COIN
COIN=nano
endif

APP_LOAD_PARAMS = --curve ed25519 $(COMMON_LOAD_PARAMS)
ALL_PATH_PARAMS =


#####################################################################
#                           COIN CONFIG                             #
#####################################################################
NANO_APP_NAME = "Nano"
NANO_PATH_PARAM = --path "44'/165'"
NANO_COIN_TYPE = LIBN_COIN_TYPE_NANO
ALL_PATH_PARAMS += $(NANO_PATH_PARAM)

BANANO_APP_NAME = "Banano"
BANANO_PATH_PARAM = --path "44'/198'"
BANANO_COIN_TYPE = LIBN_COIN_TYPE_BANANO
ALL_PATH_PARAMS += $(BANANO_PATH_PARAM)

NOS_APP_NAME = "NOS"
NOS_PATH_PARAM = --path "44'/229'"
NOS_COIN_TYPE = LIBN_COIN_TYPE_NOS
ALL_PATH_PARAMS += $(NOS_PATH_PARAM)

ifeq ($(APP_TYPE), standalone)
    DEFINES += IS_STANDALONE_APP
else ifeq ($(APP_TYPE), shared)
    DEFINES += SHARED_LIBRARY_NAME=\"$(NANO_APP_NAME)\"
    DEFINES += HAVE_COIN_NANO
    DEFINES += HAVE_COIN_BANANO
    DEFINES += HAVE_COIN_NOS
else ifneq ($(MAKECMDGOALS),listvariants)
    $(error Unsupported APP_TYPE - use standalone, shared)
endif

ifeq ($(COIN),nano)
    APPNAME = $(NANO_APP_NAME)
    DEFINES += HAVE_COIN_NANO
    DEFINES += DEFAULT_COIN_TYPE=$(NANO_COIN_TYPE)
    ifeq ($(APP_TYPE), shared)
        APP_LOAD_PARAMS += $(ALL_PATH_PARAMS)
        HAVE_APPLICATION_FLAG_LIBRARY = 1
        DEFINES += IS_SHARED_LIBRARY
    else
        APP_LOAD_PARAMS += $(NANO_PATH_PARAM)
    endif
else ifeq ($(COIN),banano)
    APPNAME = $(BANANO_APP_NAME)
    APP_LOAD_PARAMS += $(BANANO_PATH_PARAM)
    DEP_APP_LOAD_PARAMS := $(NANO_APP_NAME)
    DEFINES += HAVE_COIN_BANANO
    DEFINES += DEFAULT_COIN_TYPE=$(BANANO_COIN_TYPE)
else ifeq ($(COIN),nos)
    APPNAME = $(NOS_APP_NAME)
    APP_LOAD_PARAMS += $(NOS_PATH_PARAM)
    DEP_APP_LOAD_PARAMS := $(NANO_APP_NAME)
    DEFINES += HAVE_COIN_NOS
    DEFINES += DEFAULT_COIN_TYPE=$(NOS_COIN_TYPE)
else ifeq ($(filter clean listvariants,$(MAKECMDGOALS)),)
    $(error Unsupported COIN - use nano, banano, nos)
endif

MAX_ADPU_INPUT_SIZE=217
MAX_ADPU_OUTPUT_SIZE=98

#####################################################################
#                               MISC                                #
#####################################################################

ifeq ($(TARGET_NAME),TARGET_BLUE)
ICONNAME ?= $(ICON_BLUE)
endif
ifeq ($(TARGET_NAME),TARGET_NANOS)
ICONNAME ?= $(ICON_NANOS)
endif

################
# Default rule #
################

all: default

############
# Platform #
############
DEFINES   += OS_IO_SEPROXYHAL
DEFINES   += HAVE_BAGL HAVE_SPRINTF
DEFINES   += HAVE_IO_USB HAVE_L4_USBLIB IO_USB_MAX_ENDPOINTS=4 IO_HID_EP_LENGTH=64 HAVE_USB_APDU
DEFINES   += APP_MAJOR_VERSION=$(APPVERSION_M) APP_MINOR_VERSION=$(APPVERSION_N) APP_PATCH_VERSION=$(APPVERSION_P)
DEFINES   += MAX_ADPU_OUTPUT_SIZE=$(MAX_ADPU_OUTPUT_SIZE)

# U2F
DEFINES   += HAVE_IO_U2F
DEFINES   += U2F_PROXY_MAGIC=\"mRB\"
DEFINES   += USB_SEGMENT_SIZE=64
DEFINES   += BLE_SEGMENT_SIZE=32 #max MTU, min 20
DEFINES   += U2F_REQUEST_TIMEOUT=10000 # 10 seconds
DEFINES   += UNUSED\(x\)=\(void\)x
DEFINES   += APPVERSION=\"$(APPVERSION)\"

# WebUSB
#WEBUSB_URL = www.ledgerwallet.com
#DEFINES   += HAVE_WEBUSB WEBUSB_URL_SIZE_B=$(shell echo -n $(WEBUSB_URL) | wc -c) WEBUSB_URL=$(shell echo -n $(WEBUSB_URL) | sed -e "s/./\\\'\0\\\',/g")
DEFINES   += HAVE_WEBUSB WEBUSB_URL_SIZE_B=0 WEBUSB_URL=""

# Enabling debug PRINTF
DEBUG = 0
ifneq ($(DEBUG),0)
        ifeq ($(TARGET_NAME),TARGET_NANOS)
                DEFINES   += HAVE_PRINTF PRINTF=screen_printf
        else
                DEFINES   += HAVE_PRINTF PRINTF=mcu_usb_printf
        endif
else
        DEFINES   += PRINTF\(...\)=
endif

############
# Compiler #
############
ifneq ($(BOLOS_ENV),)
$(info BOLOS_ENV=$(BOLOS_ENV))
CLANGPATH := $(BOLOS_ENV)/clang-arm-fropi/bin/
GCCPATH := $(BOLOS_ENV)/gcc-arm-none-eabi-5_3-2016q1/bin/
else
$(info BOLOS_ENV is not set: falling back to CLANGPATH and GCCPATH)
endif
ifeq ($(CLANGPATH),)
$(info CLANGPATH is not set: clang will be used from PATH)
endif
ifeq ($(GCCPATH),)
$(info GCCPATH is not set: arm-none-eabi-* will be used from PATH)
endif

CC       := $(CLANGPATH)clang

#CFLAGS   += -O0
CFLAGS   += -O3 -Os -Wno-typedef-redefinition

AS     := $(GCCPATH)arm-none-eabi-gcc

LD       := $(GCCPATH)arm-none-eabi-gcc
LDFLAGS  += -O3 -Os
LDLIBS   += -lm -lgcc -lc

# variables processed by the common makefile.rules of the SDK to grab source files and include dirs
SDK_SOURCE_PATH  += lib_stusb
SDK_SOURCE_PATH  += lib_stusb_impl
SDK_SOURCE_PATH  += lib_u2f
SDK_SOURCE_PATH  += lib_ux

ifeq ($(TARGET_NAME),TARGET_NANOX)
SDK_SOURCE_PATH  += lib_blewbxx lib_blewbxx_impl
endif

# add dependency on custom makefile filename
dep/%.d: %.c Makefile

include $(BOLOS_SDK)/Makefile.standard_app
