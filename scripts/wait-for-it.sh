#!/bin/sh
# wait-for-postgres.sh

set -e
  
host="$1"
shift
  
until curl -s "$host"; do
  >&2 echo "k8s is unavailable - sleeping"
  sleep 10
done
  
>&2 echo "k8s is up - executing command"
exec "$@"