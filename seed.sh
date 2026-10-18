#!/usr/bin/env bash
# Fills a running stack with demo data: the catalog (SQL, straight into Postgres)
# and a few orders (through the orders API, so they're priced like real ones).
# Safe to run more than once.
#
#   docker compose up -d --build --wait && ./seed.sh
set -euo pipefail
cd "$(dirname "$0")"

CATALOG_URL=${CATALOG_URL:-http://localhost:${CATALOG_PORT:-7082}}
ORDERS_URL=${ORDERS_URL:-http://localhost:${ORDERS_PORT:-7081}}

wait_for() {
  local url=$1
  for _ in $(seq 1 60); do
    if curl -fsS "$url" > /dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done
  echo "Timed out waiting for $url" >&2
  exit 1
}

echo "Waiting for the services..."
wait_for "$CATALOG_URL/actuator/health"
wait_for "$ORDERS_URL/actuator/health"

echo "Seeding the catalog..."
docker compose exec -T postgres psql -q -v ON_ERROR_STOP=1 -U catalog -d catalog < seed/catalog.sql > /dev/null

place_order() {
  local customer=$1 lines=$2
  curl -fsS -X POST "$ORDERS_URL/api/v1/orders" \
    -H 'Content-Type: application/json' \
    -d "{\"customerId\": \"$customer\", \"lines\": $lines}" > /dev/null
}

has_orders() {
  curl -fsS "$ORDERS_URL/api/v1/orders?customerId=$1&size=1" | grep -q '"totalElements" *: *[1-9]'
}

for customer in demo-customer web-customer; do
  if has_orders "$customer"; then
    echo "Orders for $customer already there."
    continue
  fi
  echo "Placing demo orders for $customer..."
  place_order "$customer" '[{"productId": 1, "quantity": 2}, {"productId": 8, "quantity": 1}]'
  place_order "$customer" '[{"productId": 4, "quantity": 1}]'
  place_order "$customer" '[{"productId": 6, "quantity": 1}, {"productId": 2, "quantity": 3}]'
done

echo "Done. Web: http://localhost:${WEB_PORT:-7080}"
