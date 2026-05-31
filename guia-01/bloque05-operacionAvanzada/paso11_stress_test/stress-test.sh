#!/bin/bash

URL=$1

if [ -z "$URL" ]; then
  echo ""
  echo "Uso:"
  echo ""
  echo "./stress-test.sh http://URL"
  echo ""
  exit 1
fi

WORKERS=50

echo ""
echo "====================================================="
echo " KUBERNETES STRESS TEST"
echo "====================================================="
echo ""

echo "TARGET: $URL"
echo "WORKERS: $WORKERS"

echo ""
echo "Presione CTRL+C para detener"
echo ""

for i in $(seq 1 $WORKERS)
do
(
  while true
  do

    HTTP_CODE=$(curl \
      -o /dev/null \
      -s \
      -w "%{http_code}" \
      $URL)

    echo "[Worker $i] HTTP=$HTTP_CODE"

  done
) &
done

wait
