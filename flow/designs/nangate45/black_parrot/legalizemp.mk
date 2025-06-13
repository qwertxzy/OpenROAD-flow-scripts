# Include base config.mk
include $(dir $(lastword $(MAKEFILE_LIST)))config.mk

# Set macro strategy
MACRO_STRATEGY = LEGALIZE

# Set halo sizes
export MACRO_PLACE_HALO    = 10
# export MACRO_PLACE_CHANNEL = 20 20
