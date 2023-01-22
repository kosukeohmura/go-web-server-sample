#!/bin/sh
if [ -n "${DEBUGGER_PROTOCOL}" ]; then
  echo "debugger protocol: ${DEBUGGER_PROTOCOL}"
  echo "debugger port: ${DEBUGGER_PORT}"
fi

if [ "${DEBUGGER_PROTOCOL}" = "dap" ];then
  go build -gcflags='all=-N -l' -o ./out/go-web-server-sample-local
  dlv dap -l 0.0.0.0:${DEBUGGER_PORT} --log --check-go-version=false
elif [ "${DEBUGGER_PROTOCOL}" = "rpc" ]; then
  dlv debug --continue --check-go-version=false --accept-multiclient --headless -l 0.0.0.0:${DEBUGGER_PORT} main.go
else
  go run main.go
fi
