#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

# Template specific tests
check "python" python3 --version
check "pip" pip3 --version

# Report result
reportResults
