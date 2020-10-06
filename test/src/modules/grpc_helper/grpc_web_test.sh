#!/bin/bash

# Usage Function
function usage() {
  if [ -n "$1" ]; then
    echo -e "${RED}👉 $1${CLEAR}\n";
  fi
  echo "Usage: $0 [-h --host] [-d --data] [-e --expected] [-r --request]"
  echo "  -h, --host        dns host name (required) 'localhost'"
  echo "  -e, --expected    Base64 expected response (required) 'AAAAAFI...'"
  echo "  -r, --request     The request path (required) '/rpc.Ledger/ListContracts'"
  echo "  -d, --data        Base64 data string (required) 'AAAAAFIK...'"
  echo "  -p, --port        Default: 50051 (optional)"
  echo "  -P, --protocol    Default: 'http' Connection Protocol(optional) 'http' or 'https'"
  echo "  -M, --max_time    Default: 10 seconds"
  echo "  -v, --verbose     Enable Verbose Logging"
  echo ""
  echo "Example: $0 --host localhost --request /rpc.Ledger/ListContracts\
  --expected AAAAAQcIyAESgQJ7IjMiOnsiY29udHJhY3RfbmFtZSI6ImNvbS5vcmcxLmNvbnRyYWN0LlN0YXRlVXBkYXRlciIsImNlcnRfaWQiOiJtZGJveCIsImNlcnRfdmVyc2lvbiI6MSwiY29udHJhY3RfcHJvcGVydGllcyI6e30sInJlZ2lzdGVyZWRfYXQiOjE1NTgzMzQ5NTU0MjUsInNpZ25hdHVyZSI6Ik1FWUNJUURQVXpPVGdvaGE2bzJQV2FWL0xpRmhVMTI1SGpCeVlLYnphT0Z3a1ZxeXlRSWhBTkd6d3ltVjV5SlBhVjZMWG9rbXhEQlZpODNWc0tlNndndTBVSEh4aWhlVyJ9fQ==\
  --data AAAAAFIKBW1kYm94EAEiRzBFAiEAx4josbxWPEuZ7w/imnl5B/xY0FKbQLkuK/E/UFUHbmwCIGBludc3JD3pkTYqmeT186g+rDaoFkLqHg4xCQ8uCL3w"
  exit 1
}

# Set Default Values
REQUEST_PROTOCOL='http'
SERVER_PORT='50051'
MAX_TIME=10
VERBOSE='-s'

# Parse input arguments
while [[ "$#" -gt 0 ]]; do case $1 in
  -e|--expected) EXPECTED_DATA="$2"; shift;;
  -d|--data) REQUEST_DATA="$2"; shift;;
  -m|--method) REQUEST_PROTOCOL="$2"; shift;;
  -h|--host) SERVER_HOST="$2"; shift;;
  -p|--port) SERVER_PORT="$2"; shift;;
  -r|--request) REQUEST_PATH="$2"; shift;;
  -H|--help) usage=1;;
  -v|--verbose) VERBOSE="-v";;
  -M|--max-time) MAX_TIME="$2"; shift;;
  *) usage "Unknown parameter passed: $1"; shift;;
esac; shift; done

# Check if --help -h was passed as argument
if [[ $usage = "1" ]]; then
  usage
fi

# Verify required arguments are set
if [[ -z ${REQUEST_PATH} || -z ${SERVER_HOST} || -z ${EXPECTED_DATA} || -z ${REQUEST_DATA} ]]; then
  usage "Missing one or more required arguments";
fi

# Start Test
echo "*********************************************************"
echo "* Testing... $REQUEST_PATH"
echo "*"
echo "* SERVER_HOST     : $SERVER_HOST"
echo "* SERVER_PORT     : $SERVER_PORT"
echo "* REQUEST_PATH    : $REQUEST_PATH"
echo "* REQUEST_PROTOCOL: $REQUEST_PROTOCOL"
echo "* REQUEST_DATA    : $REQUEST_DATA"
echo "* EXPECTED_DATA   : $EXPECTED_DATA"
echo "* MAX_TIME        : $MAX_TIME seconds"
echo "*"
echo "* Connecting... $REQUEST_PROTOCOL://$SERVER_HOST:$SERVER_PORT$REQUEST_PATH"

out=$(curl "$VERBOSE" "$REQUEST_PROTOCOL://$SERVER_HOST:$SERVER_PORT$REQUEST_PATH" \
           -H 'X-User-Agent: grpc-web-javascript/0.1' \
           -H "Origin: $REQUEST_PROTOCOL://$SERVER_HOST:$SERVER_PORT" \
           -H 'Content-Type: application/grpc-web-text' \
           -H 'Accept: application/grpc-web-text' \
           -H 'X-Grpc-Web: 1' \
           -H "Referer: $REQUEST_PROTOCOL://$SERVER_HOST:$POST" \
           -H 'Connection: keep-alive' \
           --max-time $MAX_TIME \
           --data-binary "$REQUEST_DATA" \
           --compressed)

if [[ "$out" != "$EXPECTED_DATA" ]]; then
  echo "*"
  echo "* Expected:"
  echo "$EXPECTED_DATA"
  echo "*"
  echo "* Actual:"
  echo "$out"
  echo "*"
  echo "* Failed"
  echo "*"
  echo "*********************************************************"
  exit 1;
fi

echo "*"
echo "* Passed"
echo "*"
echo "*********************************************************"
