#!/usr/bin/env bash
cd -- "$(dirname -- "$0")"
./start.sh "$@"
result=$?
if [[ "$result" -ne 0 ]]; then read -r -p '按回车关闭窗口…' _; fi
exit "$result"
