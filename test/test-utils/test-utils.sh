#!/bin/bash

PASS="\e[32mPASS\e[0m"
FAIL="\e[31mFAIL\e[0m"
TESTCOUNT=0
FAILCOUNT=0

check() {
    TESTCOUNT=$((TESTCOUNT + 1))
    local TEST_NAME=$1
    shift
    echo -e "\n\n🔄 Test: $TEST_NAME"
    if "$@"; then
        echo -e "  --> $PASS"
    else
        echo -e "  --> $FAIL"
        FAILCOUNT=$((FAILCOUNT + 1))
    fi
}

reportResults() {
    echo -e "\n\n=== TEST SUMMARY: ${TESTCOUNT} tests, ${FAILCOUNT} failures ==="
    if [ "${FAILCOUNT}" -ne 0 ]; then
        exit 1
    fi
}
