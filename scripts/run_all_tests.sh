#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$0")/.."
ROOT="$PWD"

BUILD_DIR="$(mktemp -d)"
mkdir -p "$BUILD_DIR/sim"
trap 'rm -rf "$BUILD_DIR"' EXIT

PASSED=0
FAILED=0

echo "========================================"
echo "       PROTEUS VERIFICATION SUITE"
echo "========================================"
echo

run_test() {
    local name="$1"
    local top="$2"
    local rtl="$3"
    local tb="$4"
    local expected="$5"

    local binary="$BUILD_DIR/${top}_sim"
    local log="$BUILD_DIR/${top}.log"

    echo "----------------------------------------"
    echo "TEST: $name"
    echo "----------------------------------------"

    if ! iverilog -g2012 \
        -s "$top" \
        -o "$binary" \
        "$rtl" \
        "$ROOT/$tb" >"$log" 2>&1; then

        echo "FAIL: Compilation error"
        cat "$log"
        FAILED=$((FAILED + 1))
        echo
        return
    fi

    if ! (
        cd "$BUILD_DIR"
        timeout 15s vvp "$binary"
    ) >"$log" 2>&1; then

        echo "FAIL: Simulation error or timeout"
        cat "$log"
        FAILED=$((FAILED + 1))
        echo
        return
    fi

    if ! grep -Fxq "$expected" "$log"; then
        echo "FAIL: Expected success marker missing"
        echo "Expected: $expected"
        cat "$log"
        FAILED=$((FAILED + 1))
        echo
        return
    fi

    if grep -Eiq \
        '(^ERROR:|^FATAL:|^FAIL:|^I2C MASTER ERROR$|^I2C READ FAILED|^PROTEUS CPU I2C READ FAILED)' \
        "$log"; then

        echo "FAIL: Testbench reported an error"
        cat "$log"
        FAILED=$((FAILED + 1))
        echo
        return
    fi

    echo "PASS: $name"
    PASSED=$((PASSED + 1))
    echo
}

run_cpu_test() {
    local name="$1"
    local program="$2"
    local top="$3"
    local tb="$4"
    local expected="$5"

    local rtl="$BUILD_DIR/${program}_proteus_core.v"
    local log="$BUILD_DIR/${top}.log"

    if ! dune exec src/generate_proteus_core.exe -- "$program" \
        >"$rtl" 2>"$log"; then

        echo "FAIL: $name - RTL generation error"
        cat "$log"
        FAILED=$((FAILED + 1))
        echo
        return
    fi

    run_test "$name" "$top" "$rtl" "$tb" "$expected"
}

echo "[1/3] Building Hardcaml..."
dune build

echo
echo "[2/3] Generating RTL..."

dune exec src/generate_spi_master.exe \
    > "$BUILD_DIR/spi_master.v"

dune exec src/generate_i2c_master.exe \
    > "$BUILD_DIR/i2c_master.v"

dune exec src/generate_uart_tx.exe \
    > "$BUILD_DIR/uart_tx.v"

dune exec src/generate_uart_rx.exe \
    > "$BUILD_DIR/uart_rx.v"

dune exec src/generate_proteus_core.exe -- i2c_read \
    > "$BUILD_DIR/proteus_core_i2c_read.v"

echo
echo "[3/3] Running 8 verification tests..."
echo

# Standalone protocol tests

run_test \
    "SPI Full-Duplex" \
    "spi_master_tb" \
    "$BUILD_DIR/spi_master.v" \
    "sim/spi_master_tb.v" \
    "FULL-DUPLEX SPI SUCCESS"

run_test \
    "I2C Master Write" \
    "i2c_master_tb" \
    "$BUILD_DIR/i2c_master.v" \
    "sim/i2c_master_tb.v" \
    "I2C MASTER SUCCESS"

run_test \
    "I2C Master Read" \
    "i2c_read_tb" \
    "$BUILD_DIR/i2c_master.v" \
    "sim/i2c_read_tb.v" \
    "I2C READ SUCCESS"

run_test \
    "UART TX" \
    "uart_tx_tb" \
    "$BUILD_DIR/uart_tx.v" \
    "sim/uart_tx_tb.v" \
    "UART TX SUCCESS"

run_test \
    "UART RX" \
    "uart_rx_tb" \
    "$BUILD_DIR/uart_rx.v" \
    "sim/uart_rx_tb.v" \
    "UART RX SUCCESS"

# CPU integration tests

run_test \
    "CPU I2C Read" \
    "proteus_i2c_read_tb" \
    "$BUILD_DIR/proteus_core_i2c_read.v" \
    "sim/proteus_i2c_read_tb.v" \
    "PROTEUS CPU I2C READ SUCCESS"

run_cpu_test \
    "CPU SPI Transfer" \
    "spi" \
    "proteus_core_tb" \
    "sim/proteus_core_tb.v" \
    "CPU SPI_XFER SUCCESS"

run_cpu_test \
    "CPU I2C Write" \
    "i2c_write" \
    "proteus_i2c_tb" \
    "sim/proteus_i2c_tb.v" \
    "PROTEUS CPU I2C SUCCESS"


run_cpu_test \
    "CPU UART Loopback" \
    "uart_loopback" \
    "proteus_uart_loopback_tb" \
    "sim/proteus_uart_loopback_tb.v" \
    "CPU UART LOOPBACK SUCCESS"


run_cpu_test \
    "CPU UART Stream" \
    "uart_loopback" \
    "proteus_uart_stream_tb" \
    "sim/proteus_uart_stream_tb.v" \
    "CPU UART STREAM SUCCESS"


run_test \
    "UART Error Recovery" \
    "uart_error_recovery_tb" \
    "$BUILD_DIR/uart_rx.v" \
    "sim/uart_error_recovery_tb.v" \
    "UART ERROR RECOVERY SUCCESS"


run_cpu_test \
    "CPU UART Error Recovery" \
    "uart_loopback" \
    "proteus_uart_error_tb" \
    "sim/proteus_uart_error_tb.v" \
    "CPU UART ERROR RECOVERY SUCCESS"


run_test \
    "UART Variable Baud" \
    "uart_variable_baud_tb" \
    "$BUILD_DIR/uart_rx.v" \
    "sim/uart_variable_baud_tb.v" \
    "UART VARIABLE BAUD SUCCESS"

echo "========================================"
echo "          VERIFICATION SUMMARY"
echo "========================================"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Total : $((PASSED + FAILED))"
echo "========================================"

if (( FAILED > 0 || PASSED != 13 )); then
    echo "VERIFICATION FAILED"
    exit 1
fi

echo "ALL SELECTED TESTS PASSED"
