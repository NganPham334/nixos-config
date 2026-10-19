#!/usr/bin/env bash
find . -type f -iname '*.dll' -printf '%f\t%h\n' | sort | column -t -s $'\t'