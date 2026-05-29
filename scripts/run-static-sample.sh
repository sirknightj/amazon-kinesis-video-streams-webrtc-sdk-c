#!/bin/bash
#
# Runs the static frames master+viewer sample and validates the connection.
#
# Usage: ./run-static-sample.sh <channel-name>
#
# Environment:
#   KVS_ICE_TRANSPORT_POLICY - set to "relay" to force TURN and verify relay candidates
#   AWS_KVS_LOG_LEVEL        - log verbosity (default: inherited from environment)

set -euo pipefail

CHANNEL_NAME="${1:?Usage: $0 <channel-name>}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SAMPLES_DIR="$SCRIPT_DIR/../build/samples"

cd "$SAMPLES_DIR"

"./kvsWebrtcClientMaster" "$CHANNEL_NAME" > master.log 2>&1 &
MASTER_PID=$!
sleep 15
"./kvsWebrtcClientViewer" "$CHANNEL_NAME" > viewer.log 2>&1 &
VIEWER_PID=$!
sleep 15

# Interrupt after 30s, and kill 15s later for safety
bash -c "sleep 30 && kill -s INT $MASTER_PID $VIEWER_PID" &
bash -c "sleep 45 && kill -9 $MASTER_PID $VIEWER_PID" &
wait $MASTER_PID
MASTER_EXIT=$?
wait $VIEWER_PID
VIEWER_EXIT=$?

if [ $MASTER_EXIT -ne 0 ] || [ $VIEWER_EXIT -ne 0 ]; then
    echo "Sample execution failed. Master exit code: $MASTER_EXIT, Viewer exit code: $VIEWER_EXIT"
    cat master.log
    cat viewer.log
    exit 1
fi

if [ "${KVS_ICE_TRANSPORT_POLICY:-}" = "relay" ]; then
    if grep "local candidate type: relay. remote candidate type: relay" master.log || \
       grep "local candidate type: relay. remote candidate type: relay" viewer.log; then
        echo "SUCCESS: Force TURN verified - relay candidates selected"
    else
        echo "FAILURE: Expected relay candidate pair not found in logs"
        cat master.log
        cat viewer.log
        exit 1
    fi
fi

echo "SUCCESS: Static frames sample completed on channel $CHANNEL_NAME"
