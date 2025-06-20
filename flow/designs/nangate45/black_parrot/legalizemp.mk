# Include base config.mk
include $(dir $(lastword $(MAKEFILE_LIST)))config.mk

# Set macro strategy
export MACRO_STRATEGY = LEGALIZE

# Set halo sizes
export MACRO_PLACE_HALO    = 10
# export MACRO_PLACE_CHANNEL = 20 20

# Unplace standard cells after macro placemeng again
# The displacement is too high which leads to congestion during routing in areas
#   where many stdcells were moved
export MACRO_UNPLACE_STD = 1
