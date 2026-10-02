#!/bin/bash
set -e

SCRIPT_DIR="plugins/seedream-evasepic/skills/analyze-reference-video/scripts"
source "$SCRIPT_DIR/terminal-output.sh"

test_string=$'hello\033[31mworld\n\r\t\302\233CSI\342\200\256RTL\342\200\250NEXT'

ITERATIONS=500

echo "Benchmarking terminal_safe_text ($ITERATIONS iterations)"

echo "1. Legacy mode (subshell fallback):"
time for ((i=0; i<ITERATIONS; i++)); do
  val="$(terminal_safe_text "$test_string")"
done

echo "2. Optimized mode (dynamic variable binding):"
time for ((i=0; i<ITERATIONS; i++)); do
  terminal_safe_text "$test_string" val
done
