# ****************************************************************************
#    Ledger App Boilerplate
#    (c) 2023 Ledger SAS.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
# ****************************************************************************

########################################
#          Coin configuration          #
########################################
NANO_COIN_NAME = nano
BANANO_COIN_NAME = banano
NOS_COIN_NAME = nos

COIN ?= $(NANO_COIN_NAME)

ifeq ($(COIN),$(NANO_COIN_NAME))
    COIN_NAME = Nano
		COIN_PATH = "44'/165'"
    DEFINES += COIN_TYPE=LIBN_COIN_TYPE_NANO
else ifeq ($(COIN),$(BANANO_COIN_NAME))
    COIN_NAME = Banano
		COIN_PATH = "44'/198'"
    DEFINES += COIN_TYPE=LIBN_COIN_TYPE_BANANO
else ifeq ($(COIN),$(NOS_COIN_NAME))
    COIN_NAME = NOS
		COIN_PATH = "44'/229'"
    DEFINES += COIN_TYPE=LIBN_COIN_TYPE_NOS
else ifeq ($(filter clean listvariants,$(MAKECMDGOALS)),)
    $(error unsupported COIN $(COIN); expected nano, banano, or nos)
endif

########################################
#             Boilerplate              #
########################################
ifeq ($(BOLOS_SDK),)
    $(error Environment variable BOLOS_SDK is not set)
endif

include $(BOLOS_SDK)/Makefile.target

########################################
#        Mandatory configuration       #
########################################
# Application name
APPNAME = $(COIN_NAME)

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

# Application allowed derivation curves.
# Possibles curves are: secp256k1, secp256r1, ed25519 and bls12381g1
# If your app needs it, you can specify multiple curves by using:
# `CURVE_APP_LOAD_PARAMS = <curve1> <curve2>`
CURVE_APP_LOAD_PARAMS = ed25519

# Application allowed derivation paths.
# You should request a specific path for your app.
# This serve as an isolation mechanism.
# Most application will have to request a path according to the BIP-0044
# and SLIP-0044 standards.
# If your app needs it, you can specify multiple path by using:
# `PATH_APP_LOAD_PARAMS = "44'/1'" "45'/1'"`
PATH_APP_LOAD_PARAMS = $(COIN_PATH)

# Setting to allow building variant applications
# - <VARIANT_PARAM> is the name of the parameter which should be set
#   to specify the variant that should be build.
# - <VARIANT_VALUES> a list of variant that can be build using this app code.
#   * It must at least contains one value.
#   * Values can be the app ticker or anything else but should be unique.
VARIANT_PARAM = COIN
VARIANT_VALUES = $(NANO_COIN_NAME) $(BANANO_COIN_NAME) $(NOS_COIN_NAME)

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

#####################################################################
#                               MISC                                #
#####################################################################

ifeq ($(TARGET_NAME),TARGET_BLUE)
ICONNAME ?= $(ICON_BLUE)
endif
ifeq ($(TARGET_NAME),TARGET_NANOS)
ICONNAME ?= $(ICON_NANOS)
endif

# variables processed by the common makefile.rules of the SDK to grab source files and include dirs
SDK_SOURCE_PATH += lib_ux

# add dependency on custom makefile filename
dep/%.d: %.c Makefile

include $(BOLOS_SDK)/Makefile.standard_app
