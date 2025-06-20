#!/bin/bash

# Set design dir here
DESIGN_DIR=$1

if [ $# -eq 0 ]; then
  echo "Provide a path to a design dir"
  exit 1
fi

echo "Running design from $DESIGN_DIR"

# Run TritonMP flow
make DESIGN_CONFIG="$DESIGN_DIR/tritonmp.mk" FLOW_VARIANT="tritonmp" OPENROAD_EXE=openroad OPENSTA_EXE=sta YOSYS_EXE=yosys

# Run HierRTLMP
make DESIGN_CONFIG="$DESIGN_DIR/hierrtlmp.mk" FLOW_VARIANT="hierrtlmp" OPENROAD_EXE=openroad OPENSTA_EXE=sta YOSYS_EXE=yosys

# Run LegalizeMP
make DESIGN_CONFIG="$DESIGN_DIR/legalizemp.mk" FLOW_VARIANT="legalizemp" OPENROAD_EXE=openroad OPENSTA_EXE=sta YOSYS_EXE=yosys
