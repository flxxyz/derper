#!/usr/bin/env bash

DEFAULT_CONFIG_FILE="/opt/derper/env"

# Default Configuration
if [ ! -f "$CONFIG_FILE" ]; then
  CONFIG_FILE=$DEFAULT_CONFIG_FILE
fi

# Check Configuration File
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file $CONFIG_FILE does not exist"
    exit 1
fi

# Load Configuration
while IFS='=' read -r key value; do
    key=$(echo $key | tr -d '[:space:]')
    value=$(echo $value | tr -d '[:space:]')

    [[ $key = \#* ]] && continue
    [[ -z $key ]] && continue

    declare $key=$value
done < "$CONFIG_FILE"

# (Optional) Default Values
if [[ -z $DERP_DIR ]]; then
  DERP_DIR="/opt/derper"
fi
if [[ -z $DERP_PORT ]]; then
  DERP_PORT="33333"
fi
if [[ -z $DERP_CONN_LIMIT ]]; then
  DERP_CONN_LIMIT="100"
fi
if [[ -z $DERP_VERIFY_CLENTS ]]; then
  DERP_VERIFY_CLENTS="1"
fi
if [[ -z $DERP_CONF ]]; then
  DERP_CONF="${DERP_DIR}/derp.conf"
fi
if [[ -z $CERT_DIR ]]; then
  CERT_DIR="${DERP_DIR}/cert"
fi
if [[ -z $CERT_DAYS ]]; then
  CERT_DAYS="36500"
fi

DERP_BIN="${DERP_DIR}/bin"
DERP_ENDPOINT="${DERP_BIN}/endpoint.sh"
# Logs store default directory
if [[ -z $LOG_DIR ]]; then
  LOG_DIR="${DERP_DIR}/logs"
fi
LOG_FILE="${LOG_DIR}/derper-$(date +%Y-%m-%d_%H).log"
PID_FILE="${LOG_DIR}/derper.pid"

help()
{
  if [ -n "$1" ]; then
    echo "Unexpected option: $1"
  fi
  echo "Usage: derper.sh --start [--verbose]
       derper.sh --stop [--verbose]
       derper.sh --self-cert-sign-request [--verbose]"
  exit 2
}

start_derp_server()
{
  if [ -f $PID_FILE ]; then
    echo "DERP Server is already running"
    exit 0
  fi

  if [[ -z $DERP_HOST ]]; then
    help "DERP_HOST env is required"
  fi

  if [ -f $DERP_ENDPOINT ]; then
    export DERP_HOST DERP_PORT DERP_CONN_LIMIT DERP_VERIFY_CLENTS DERP_BIN DERP_CONF CERT_DIR LOG_FILE PID_FILE

    DERP_VERIFY_CLENTS="--verify-clients"
    if [[ $DERP_VERIFY_CLENTS  -eq 0 ]]; then
      DERP_VERIFY_CLENTS=""
    fi

    if [[ $VERBOSE -eq 1 ]]; then
      endpoint
    else
      endpoint > $LOG_FILE 2>&1 &
      PID=$!
      echo $PID > $PID_FILE
      check_derp_running "$PID" > /dev/null 2>&1
      # check_derp_running "$PID"
    fi
  else 
    echo "DERP binary not found: $DERP_BIN"
    exit 1
  fi
  exit 0
}

endpoint() {
  exec "${DERP_ENDPOINT}" -c ${DERP_CONF} \
    -a ":${DERP_PORT}" \
    -http-port -1 \
    -stun \
    -stun-port ${DERP_PORT} \
    -hostname ${DERP_HOST} \
    -accept-connection-limit ${DERP_CONN_LIMIT} \
    --certmode manual \
    -certdir ${CERT_DIR} \
    $DERP_VERIFY_CLENTS
}

check_derp_running() {
  pid=$1
  check_threshold=30
  check_period=1
  checks=0

  while true;
  do
    if [[ $checks -eq $check_threshold ]]; then
      break
    fi

    sleep $check_period

    if [[ -z `ps -ef | awk '{print $2}' | grep $pid` ]]; then
      if [ -f $PID_FILE ]; then
        if [[ `cat ${PID_FILE}` -eq $pid ]]; then
          rm -rf $PID_FILE
          exit 2
        fi
      fi
    fi

    checks=$(($checks+1))
  done
}

stop_derp_server()
{
  echo "Stopping DERP Server..."

  if [ -f $PID_FILE ]; then
    PID=`cat $PID_FILE`
    if [[ ! -z `ps -ef | awk '{print $2}' | grep $PID` ]]; then
      kill $PID
    fi
    rm -rf $PID_FILE
  fi
  exit 0
}

self_cert_sign_request() {
  if [[ $VERBOSE -eq 1 ]]; then
    self_sign_certificate
  else
    CSR_LOG_FILE="${LOG_DIR}/csr-$(date +%Y-%m-%d_%H).log"
    self_sign_certificate >> $CSR_LOG_FILE 2>&1 &
  fi
  exit 0
}

self_sign_certificate() {
  local PRIVATE_KEY="${CERT_DIR}/${DERP_HOST}.key"
  local SIGN_REQUEST="${CERT_DIR}/${DERP_HOST}.csr"
  local CERTIFICATE="${CERT_DIR}/${DERP_HOST}.crt"

  echo "PRIVATE_KEY : ${PRIVATE_KEY}"
  echo "SIGN_REQUEST: ${SIGN_REQUEST}"
  echo "CERTIFICATE : ${CERTIFICATE}"

  echo -e "\nGenerating private key for ${DERP_HOST}"
  openssl genpkey -algorithm RSA -out ${PRIVATE_KEY}

  echo -e "\nGenerating signing request for ${DERP_HOST}"
  openssl req -new \
    -key ${PRIVATE_KEY} \
    -out ${SIGN_REQUEST} \
    -subj "/C=US/ST=New York/L=New York/O=Self-signed Corp/OU=Self-signed Corp/CN=${DERP_HOST}"

  echo -e "\nGenerating certificate for ${DERP_HOST}"
  openssl x509 -req \
    -days ${CERT_DAYS} \
    -in ${SIGN_REQUEST} \
    -signkey ${PRIVATE_KEY} \
    -out ${CERTIFICATE} \
    -extfile <(printf "subjectAltName=DNS:${DERP_HOST}")
}

create_derper_user() {
  sudo useradd -r -s /bin/false derper
  sudo cp "$DERP_DIR/derper.service" /etc/systemd/system/derper.service
  sudo systemctl daemon-reload
}

# Parse options
SHORT="v,h"
LONG="verbose,help,start,stop,self-cert-sign-request"
OPTS=$(getopt -a --options $SHORT --longoptions $LONG -- "$@")

eval set -- "$OPTS"

while true;
do
  case $1 in
    --verbose)
      VERBOSE=1
      shift 1
      ;;
    --start)
      _START_DERP_SERVER=1
      shift 1
      ;;
    --stop)
      _STOP_DERP_SERVER=1
      shift 1
      ;;
    --self-cert-sign-request)
      _SELF_SIGN_REQUEST=1
      shift 1
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

if [[ $_SELF_SIGN_REQUEST -eq 1 ]]; then
  self_cert_sign_request
elif [[ $_START_DERP_SERVER -eq 1 && $_STOP_DERP_SERVER -eq 0 ]]; then
  start_derp_server
elif [[ $_STOP_DERP_SERVER -eq 1 && $_START_DERP_SERVER -eq 0 ]]; then
  stop_derp_server
else
  help
fi
