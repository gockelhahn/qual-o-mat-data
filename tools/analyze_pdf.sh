#!/bin/bash
#
# wrapper for calling OCR software to extract values
#
# positive = 0
# negative = 1
# neutral = 2

# checks
[ ! -f "$1" ] && echo "ERROR: First parameter must be an image. Abort!" >&2 && exit 1

SCRIPT_DIR="$(cd "`dirname "$0"`" && pwd)"
[ -z "$SCRIPT_DIR" ] && echo "ERROR: Script directory could not be detected. Abort!" >&2 && exit 1

# execute final command
gocr -d 0 -l 200 -p "$SCRIPT_DIR/db/" -m 258 -a 40 -u 2 -i "$1" | grep -v ^$ | tr -d " \t"
