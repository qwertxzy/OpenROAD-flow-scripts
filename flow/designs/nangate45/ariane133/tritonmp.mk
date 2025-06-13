# Include base config.mk
include $(dir $(lastword $(MAKEFILE_LIST)))config.mk

# Set macro strategy
export MACRO_STRATEGY = TRITON

# Set halo sizes
export MACRO_PLACE_HALO    = 10 10
export MACRO_PLACE_CHANNEL = 20 20
