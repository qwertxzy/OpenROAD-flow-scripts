#!/bin/bash

# Set design dir here
DESIGN_DIR=$1

echo "Running design from $DESIGN_DIR"

# Run TritonMP flow
make DESIGN_CONFIG="$DESIGN_DIR/tritonmp.mk" FLOW_VARIANT="tritonmp"

# Run HierRTLMP
make DESIGN_CONFIG="$DESIGN_DIR/hierrtlmp.mk" FLOW_VARIANT="hierrtlmp"

# Run LegalizeMP
make DESIGN_CONFIG="$DESIGN_DIR/legalizemp.mk" FLOW_VARIANT="legalizemp"
