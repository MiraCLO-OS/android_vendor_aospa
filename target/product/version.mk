#
# SPDX-FileCopyrightText: Paranoid Android
# SPDX-License-Identifier: Apache-2.0
#

#
# Handle various build version information.
#
# Guarantees that the following are defined:
#     AOSPA_MAJOR_VERSION
#     AOSPA_MINOR_VERSION
#     AOSPA_BUILD_VARIANT
#

# This is the global AOSPA version flavor that determines the focal point
# behind our releases. This is bundled alongside $(AOSPA_MINOR_VERSION)
# and only changes per major Android releases.
AOSPA_MAJOR_VERSION := 1.0

# The version code is the upgradable portion during the cycle of
# every major Android release. Each version code upgrade indicates
# our own major release during each lifecycle.
# It is based in three parts
# X for SPL changes, Y for week, and Z for hotfix.
ifdef AOSPA_BUILDVERSION
    AOSPA_MINOR_VERSION := $(AOSPA_BUILDVERSION)
endif

# Build Variants
#
# Alpha: Development / Test releases
# Beta: Public releases with CI
# Stable: Final Product | No Tagging
ifdef AOSPA_BUILDTYPE
  ifeq ($(AOSPA_BUILDTYPE), ALPHA)
      AOSPA_BUILD_VARIANT := alpha
  else ifeq ($(AOSPA_BUILDTYPE), BETA)
      AOSPA_BUILD_VARIANT := beta
  else ifeq ($(AOSPA_BUILDTYPE), STABLE)
      AOSPA_BUILD_VARIANT := stable
  endif
else
  AOSPA_BUILD_VARIANT := unofficial
endif

# MiraCLO release name: the number and codename of this beta / stable release.
# Beta 1 is "Aurora". Bump both for every public release.
MIRACLO_RELEASE_NUMBER := 2
MIRACLO_CODENAME := Aurora

# Build Date
BUILD_DATE := $(shell date -u +%Y%m%d)

# AOSPA Version
AOSPA_VERSION := $(AOSPA_MAJOR_VERSION)-
AOSPA_DISPLAY_VERSION := $(shell V1=$(AOSPA_MAJOR_VERSION); echo -n $${V1^})

ifeq ($(filter stable,$(AOSPA_BUILD_VARIANT)),)
  ifeq ($(AOSPA_BUILD_VARIANT),unofficial)
    AOSPA_VERSION += $(AOSPA_BUILD_VARIANT)-
  else
    # MiraCLO: e.g. MiraCLO-1.0-beta1-Aurora-marble-20261027.zip
    AOSPA_VERSION += $(AOSPA_BUILD_VARIANT)$(MIRACLO_RELEASE_NUMBER)-$(MIRACLO_CODENAME)-
  endif
    AOSPA_DISPLAY_VERSION += $(shell V1=$(AOSPA_BUILD_VARIANT); echo -n $${V1^})
else
    AOSPA_VERSION += $(AOSPA_MINOR_VERSION)-
    AOSPA_DISPLAY_VERSION += $(AOSPA_MINOR_VERSION)
endif

# Add BUILD_DATE for zip naming
AOSPA_VERSION += $(AOSPA_BUILD)-$(BUILD_DATE)

# Remove unwanted characters for zip naming
AOSPA_VERSION := $(shell echo -n $(AOSPA_VERSION) | tr -d '[:space:]')

# MiraCLO
# Settings shows ro.aospa.miraclo.version with "_" as spaces and the variant
# capitalised, plus the codename for releases: 1.0-beta_1 + Aurora ->
# "1.0 Beta 1 (Aurora)". Property values stay free of spaces and brackets.
ifeq ($(AOSPA_BUILD_VARIANT),unofficial)
PRODUCT_SYSTEM_PROPERTIES += \
    ro.build.display.id=MiraCLO-$(AOSPA_VERSION) \
    ro.aospa.miraclo.version=$(AOSPA_MAJOR_VERSION)-$(AOSPA_BUILD_VARIANT)
else
PRODUCT_SYSTEM_PROPERTIES += \
    ro.build.display.id=MiraCLO-$(AOSPA_VERSION) \
    ro.aospa.miraclo.version=$(AOSPA_MAJOR_VERSION)-$(AOSPA_BUILD_VARIANT)_$(MIRACLO_RELEASE_NUMBER) \
    ro.aospa.miraclo.codename=$(MIRACLO_CODENAME)
endif
