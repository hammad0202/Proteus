#!/usr/bin/env bash

set +e

cd "$(dirname "$0")/.." || exit 1

BUILD_DIR="/tmp/proteus_video4"
mkdir -p "$BUILD_DIR/sim"

echo "========================================"
echo "     PROTEUS VIDEO 4 READINESS"
echo "========================================"

echo ""
echo "PHASE 1: EXISTING REGRESSION TESTS"
echo "----------------------------------------"

bash scripts/run_all_tests.sh > "$BUILD_DIR/regression.log" 2>&1
regression_status=$?

tail -n 10 "$BUILD_DIR/regression.log"

if [ "$regression_status" -ne 0 ]; then
    echo "ERROR: Existing regression suite failed."
    echo "Full log: $BUILD_DIR/regression.log"
    exit 1
fi

echo ""
echo "PHASE 2: GENERATE CPU RTL"
echo "----------------------------------------"

dune build > "$BUILD_DIR/build.log" 2>&1
build_status=$?

if [ "$build_status" -ne 0 ]; then
    cat "$BUILD_DIR/build.log"
    exit 1
fi

dune exec src/generate_proteus_core.exe -- uart_loopback \
    > "$BUILD_DIR/proteus_core.v"

if [ "$?" -ne 0 ]; then
    echo "ERROR: RTL generation failed."
    exit 1
fi

echo "CPU RTL generated successfully."

echo ""
echo "PHASE 3: COMPILE STRESS TEST"
echo "----------------------------------------"

iverilog -g2012 \
    -s proteus_uart_stress_tb \
    -o "$BUILD_DIR/stress_sim" \
    "$BUILD_DIR/proteus_core.v" \
    sim/proteus_uart_stress_tb.v

if [ "$?" -ne 0 ]; then
    echo "ERROR: Stress test compilation failed."
    exit 1
fi

echo "Stress test compiled successfully."

echo ""
echo "PHASE 4: RUN ALL STRESS SCENARIOS"
echo "----------------------------------------"

(
    cd "$BUILD_DIR" || exit 1
    timeout 30s vvp stress_sim
) | tee "$BUILD_DIR/stress.log"

simulation_status=${PIPESTATUS[0]}

echo ""
echo "========================================"
echo "        FINAL READINESS REPORT"
echo "========================================"
echo "Regression suite exit : $regression_status"
echo "Stress simulation exit: $simulation_status"
echo "Regression log        : $BUILD_DIR/regression.log"
echo "Stress log            : $BUILD_DIR/stress.log"
echo "Waveform              : $BUILD_DIR/sim/proteus_uart_stress.vcd"
echo "========================================"

if [ "$simulation_status" -ne 0 ]; then
    echo "READINESS: INVESTIGATION REQUIRED"
    exit 1
fi

echo "READINESS: CHARACTERIZATION COMPLETED"
echo "Review limited scenarios before making"
echo "continuous-throughput performance claims."
