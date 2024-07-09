#!/usr/bin/env bash

is_exists() {
  local cmd="$1"
  if [ -z "$cmd" ]; then
    echo "Usage: is_exists <command>"
    return 1
  fi
  
  which "$cmd" > /dev/null 2>&1
  if [[ $? -eq 0 ]]; then
    return 0
  fi

  return 2
}

# check tailscale is installed
if ! is_exists "tailscale"; then
  echo "Tailscale is not installed"
  exit 1
fi

TAILSCALE_BIN=$(which tailscale)
# TAILSCALE_BIN="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

TAILSCALE_VERSION=$("$TAILSCALE_BIN" version | head -n 1)
DERPER_VERSION="v$TAILSCALE_VERSION"
DERPER_URL="tailscale.com/cmd/derper@$DERPER_VERSION"
DERPER_BINARY="$DERP_BIN/derper"

echo "------------ Parameters -------------"
echo "DERP_HOST:       $DERP_HOST"
echo "DERP_PORT:       $DERP_PORT"
echo "DERP_CONN_LIMIT: $DERP_CONN_LIMIT"
echo "DERP_CONF:       $DERP_CONF"
echo "CERT_DIR:        $CERT_DIR"
echo "LOG_FILE:        $LOG_FILE"
echo "PID_FILE:        $PID_FILE"
echo "DERPER_BINARY:   $DERPER_BINARY"
echo -e "\n"
echo "-------------- Version --------------"
echo "Tailscale version: $TAILSCALE_VERSION"
echo "   Derper version: $DERPER_VERSION"
echo -e "\n"


if [ ! $(is_exists "derper") ] || [ ! -f $DERP_BIN ]; then
  # check go is installed
  if is_exists "go"; then
    echo "----- Installing DERP Server... -----"
    go install -v "$DERPER_URL"
    echo -e "\n"

    DERPER_GOBIN="$(go env GOPATH)/bin/derper"
    if [ ! -f "$DERPER_GOBIN" ]; then
      echo "Failed to install DERP Server"
      exit 1
    fi
    cp $DERPER_GOBIN $DERPER_BINARY
  else
    echo "Go is not installed"
    echo "Please install Go and try again"
    exit 1
  fi
fi

echo "------ Starting DERP Server... ------"
echo "$DERPER_BINARY" $@

# Start DERP Server
exec "$DERPER_BINARY" $@
