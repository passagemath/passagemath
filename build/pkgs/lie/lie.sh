#!/usr/bin/env bash
SAGE_LOCAL="$(cd "$(dirname "$0")" && cd .. && pwd -P)"
LD=${SAGE_LOCAL}/lib/lie
exec $LD/lie initfile $LD
