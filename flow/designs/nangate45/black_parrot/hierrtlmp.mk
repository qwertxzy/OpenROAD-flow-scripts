# Include base config.mk
include $(dir $(lastword $(MAKEFILE_LIST)))config.mk

# Set macro strategy
export MACRO_STRATEGY = HIER_RTLMP

# Set halo sizes
export MACRO_PLACE_HALO    = 10 10
# export MACRO_PLACE_CHANNEL = 20 20

# RTL_MP Settings
export RTLMP_MAX_INST = 30000
export RTLMP_MIN_INST = 5000
export RTLMP_MAX_MACRO = 12
export RTLMP_MIN_MACRO = 4 
