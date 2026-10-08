
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
        "$ROOT/$rtl" \
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

    # Require an exact success marker from the testbench.
    # This avoids matching harmless text such as "ACK error : 0".
    if ! grep -Fxq "$expected" "$log"; then
        echo "FAIL: Expected success message missing"
        echo "Expected: $expected"
        cat "$log"
        FAILED=$((FAILED + 1))
        echo
        return
    fi

    # Check explicit failure markers without matching
    # status labels such as "ACK error : 0".
    if grep -Eiq \
        '(^ERROR:|^FATAL:|^I2C MASTER ERROR$|^I2C READ FAILED|^PROTEUS CPU I2C READ FAILED|^FAIL:)' \
        "$log"; then

        echo "FAIL: Testbench reported failure"
        cat "$log"
        FAILED=$((FAILED + 1))
        echo
        return
    fi

    echo "PASS: $name"
    PASSED=$((PASSED + 1))
    echo
}

echo "[1/3] Building Hardcaml..."
dune build

echo "[2/3] Generating fresh RTL..."

dune exec src/generate_spi_master.exe > rtl/spi_master.v
dune exec src/generate_i2c_master.exe > rtl/i2c_master.v
dune exec src/generate_proteus_core.exe > rtl/proteus_core.v

echo "[3/3] Running verification tests..."
echo

run_test \
    "SPI Full-Duplex" \
    "spi_master_tb" \
    "rtl/spi_master.v" \
    "sim/spi_master_tb.v" \
    "FULL-DUPLEX SPI SUCCESS"

run_test \
    "I2C Master Write" \
    "i2c_master_tb" \
    "rtl/i2c_master.v" \
    "sim/i2c_master_tb.v" \
    "I2C MASTER SUCCESS"

run_test \
    "I2C Master Read" \
    "i2c_read_tb" \
    "rtl/i2c_master.v" \
    "sim/i2c_read_tb.v" \
    "I2C READ SUCCESS"

run_test \
    "CPU I2C Read" \
    "proteus_i2c_read_tb" \
    "rtl/proteus_core.v" \
    "sim/proteus_i2c_read_tb.v" \
    "PROTEUS CPU I2C READ SUCCESS"

echo


# CPU integration tests with independently generated programs.
# These tests run in a temporary directory so production RTL is unchanged.

run_cpu_test() {
    local name="$1"
    local program="$2"
    local top="$3"
    local tb="$4"
    local expected="$5"

    local rtl="$BUILD_DIR/${program}_proteus_core.v"
    local binary="$BUILD_DIR/${top}_sim"
    local log="$BUILD_DIR/${top}.log"

    echo "----------------------------------------"
    echo "TEST: $name"
    echo "----------------------------------------"

    if ! dune exec src/generate_proteus_core.exe -- "$program" > "$rtl" 2>"$log"; then
        echo "FAIL: CPU RTL generation error"
        cat "$log"
        FAILED=$((FAILED + 1))
        return
    fi

    if ! iverilog -g2012 \
        -s "$top" \
        -o "$binary" \
        "$rtl" \
        "$ROOT/$tb" >"$log" 2>&1; then
        echo "FAIL: Compilation error"
        cat "$log"
        FAILED=$((FAILED + 1))
        return
    fi

    if ! (
        cd "$BUILD_DIR"
        timeout 15s vvp "$binary"
    ) >"$log" 2>&1; then
        echo "FAIL: Simulation error or timeout"
        cat "$log"
        FAILED=$((FAILED + 1))
        return
    fi

    if ! grep -Fxq "$expected" "$log"; then
        echo "FAIL: Expected success message missing"
        cat "$log"
        FAILED=$((FAILED + 1))
        return
    fi

    if grep -Eiq \
        '(^ERROR:|^FATAL:|^FAIL:|FAILED)' \
        "$log"; then
        echo "FAIL: Testbench reported failure"
        cat "$log"
        FAILED=$((FAILED + 1))
        return
    fi

    echo "PASS: $name"
    PASSED=$((PASSED + 1))
    echo
}

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

echo "========================================"
echo "          VERIFICATION SUMMARY"
echo "========================================"

echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Total : $((PASSED + FAILED))"

echo "========================================"

if (( FAILED > 0 )); then
    echo "VERIFICATION FAILED"
    exit 1
fi

echo "ALL SELECTED TESTS PASSED"
