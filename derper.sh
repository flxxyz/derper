#!/usr/bin/env bash

DERP_HOST=""
DERP_PORT="33333"
DERP_CONN_LIMIT=100
DERP_VERIFY_CLENTS=1
DERP_BIN="${DERP_DIR}/bin"
DERP_ENDPOINT="${DERP_BIN}/endpoint.sh"
DERP_CONF="${DERP_DIR}/derper.conf"
CERT_DIR="${DERP_DIR}/cert"
LOG_DIR="${DERP_DIR}/logs"
LOG_FILE="${LOG_DIR}/$(date +%Y-%m-%d_%H).log"
PID_FILE="${LOG_DIR}/derper.pid"

help()
{
  if [ -n "$1" ]; then
    echo "Unexpected option: $1"
  fi
  echo "Usage: derper.sh [ -h | --host <DOMAIN> ] [ -p | --port <NUMBER> ]
             [ -c | --conf <PATH> ] [ --cert <DIR> ]
             [ -l | --limit <NUMBER> ] [ --start ] [ --stop ]
             [ -h | --help  ]"
  exit 2
}

start_derp_server()
{
  if [ -f $PID_FILE ]; then
    echo "DERP Server is already running"
    exit 0
  fi

  if [ -z $DERP_HOST ]; then
    help "-h or --host is required"
  fi

  if [ -z $DERP_CONF ]; then
    help "-f or --conf is required"
  fi

  if [ -z $CERT_DIR ]; then
    help "--cert is required"
  fi

  if [ -f $DERP_ENDPOINT ]; then
    export DERP_HOST DERP_PORT DERP_CONN_LIMIT DERP_VERIFY_CLENTS DERP_BIN DERP_CONF CERT_DIR LOG_FILE PID_FILE

    DERP_VERIFY_CLENTS="--verify-clients"
    if [[ $DERP_VERIFY_CLENTS  -eq 0 ]]; then
      DERP_VERIFY_CLENTS=""
    fi

    exec "${DERP_ENDPOINT}" -c ${DERP_CONF} \
      -a ":${DERP_PORT}" \
      -http-port -1 \
      -stun \
      -stun-port ${DERP_PORT} \
      -hostname ${DERP_HOST} \
      -accept-connection-limit ${DERP_CONN_LIMIT} \
      --certmode manual \
      -certdir ${CERT_DIR} \
      -tcp-keepalive-time 5m \
      -tcp-user-timeout 10s \
      $DERP_VERIFY_CLENTS

    # exec "${DERP_ENDPOINT}" -c ${DERP_CONF} \
    #   -a ":${DERP_PORT}" \
    #   -http-port -1 \
    #   -stun \
    #   -stun-port ${DERP_PORT} \
    #   -hostname ${DERP_HOST} \
    #   -accept-connection-limit ${DERP_CONN_LIMIT} \
    #   --certmode manual \
    #   -certdir ${CERT_DIR} \
    #   -tcp-keepalive-time 5m \
    #   -tcp-user-timeout 10s \
    #   $DERP_VERIFY_CLENTS > $LOG_FILE 2>&1 &
    # echo $! > $PID_FILE
  else 
    echo "DERP binary not found: $DERP_BIN"
    exit 1
  fi

  exit 0
}

stop_derp_server()
{
  echo "Stopping DERP Server..."

  if [ -f $PID_FILE ]; then
    kill `cat ${PID_FILE}`
    rm -rf $PID_FILE
  fi
  exit 0
}

# Parse options
SHORT="h:,p:,c:,l:"
LONG="host:,port:,conf:,cert:,limit:,start,stop,help"
OPTS=$(getopt -a --options $SHORT --longoptions $LONG -- "$@")

eval set -- "$OPTS"

while true;
do
  case $1 in
    -h|--host)
      DERP_HOST=$2
      shift 2
      ;;
    -p|--port)
      DERP_PORT=$2
      shift 2
      ;;
    -c|--conf)
      DERP_CONF=$2
      shift 2
      ;;
    --cert)
      CERT_DIR=$2
      shift 2
      ;;
    -l|--limit)
      DERP_CONN_LIMIT=$2
      shift 2
      ;;
    --start)
      start_derp_server
      ;;
    --stop)
      stop_derp_server
      ;;
    -h|--help)
      help
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Unexpected option: $1"
      help
      ;;
  esac
done

help
