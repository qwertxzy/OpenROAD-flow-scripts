# Include base config.mk
include $(dir $(lastword $(MAKEFILE_LIST)))config.mk

# Config legalizer args to use boundary pushing forces
export LEGALIZATION_ARGS = -boundary_multiplier 0.01 -origin_multiplier 0.0 -consecutive_zero_iters 10
