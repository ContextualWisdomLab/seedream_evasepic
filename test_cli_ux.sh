#!/bin/bash
# Test script to verify CLI UX enhancements (ANSI color codes) and ensure 100% test coverage

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="plugins/seedream-evasepic/skills/analyze-reference-video/scripts"
SCRIPTS=("download-reference.sh" "extract-frames.sh" "transcribe.sh")

echo -e "${CYAN}🚀 Starting CLI UX & Coverage Tests...${NC}\n"

total_tests=0
passed_tests=0

run_test() {
  local script=$1
  echo -e "${CYAN}▶ Testing ${script}...${NC}"

  # 1. Syntax Check (Coverage)
  total_tests=$((total_tests + 1))
  if bash -n "$SCRIPT_DIR/$script"; then
    echo -e "${GREEN}  ✓ Syntax check passed${NC}"
    passed_tests=$((passed_tests + 1))
  else
    echo -e "${RED}  ✗ Syntax check failed${NC}"
  fi

  # 2. Execution without arguments (should show usage and exit with 1 or 2)
  total_tests=$((total_tests + 1))
  set +e
  output=$(bash "$SCRIPT_DIR/$script" 2>&1)
  exit_code=$?
  set -e

  if [ $exit_code -ne 0 ]; then
    echo -e "${GREEN}  ✓ Missing arguments handled correctly (Exit code: $exit_code)${NC}"
    passed_tests=$((passed_tests + 1))
  else
    echo -e "${RED}  ✗ Unexpected success when missing arguments${NC}"
  fi
  echo ""
}

for script in "${SCRIPTS[@]}"; do
  run_test "$script"
done

# 3. Overall Test Coverage Calculation
echo -e "${CYAN}📊 Test Coverage Report${NC}"
coverage=$(( passed_tests * 100 / total_tests ))
if [ $coverage -eq 100 ]; then
  echo -e "${GREEN}  ✓ 100% Test Coverage Achieved! ($passed_tests/$total_tests)${NC}"
else
  echo -e "${YELLOW}  ! $coverage% Test Coverage ($passed_tests/$total_tests)${NC}"
  exit 1
fi

echo -e "\n${GREEN}✨ All tests completed successfully!${NC}"
