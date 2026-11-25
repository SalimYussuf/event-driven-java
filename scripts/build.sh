#!/usr/bin/env bash
# Compiles all Java modules via AgentCLI (Weeks 1-10 + scripts/).
# Requires JDK 11+ — runs AgentCLI directly from source (no pre-compile step needed).
# Usage: ./scripts/build.sh [--clean] [--week <n>]
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
java "$DIR/AgentCLI.java" build "$@"
