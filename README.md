# dev-env

Runs the whole Shopfront product locally with Docker Compose: Postgres,
catalog-service, orders-service and the web app.

## Prerequisites

- Docker with Compose v2 (`docker compose version`)
- The other repos checked out next to this one:

```
shopfront/
├── dev-env/            <- you are here
├── orders-service/
├── catalog-service/
└── web/
```

If they live elsewhere, copy `.env.example` to `.env` and set `ORDERS_SERVICE_DIR`,
`CATALOG_SERVICE_DIR` and `WEB_DIR`.

## Run it

```sh
docker compose up -d --build --wait    # or: make up
./seed.sh                              # or: make seed
```

The first build downloads Gradle, Maven and npm dependencies inside Docker and takes a
few minutes. Later builds are cached.

| What | URL |
|---|---|
| Web shop | http://localhost:7080 |
| orders-service | http://localhost:7081 (Swagger UI: `/swagger-ui.html`) |
| catalog-service | http://localhost:7082 (Swagger UI: `/swagger-ui/index.html`) |
| Postgres | `localhost:7432`, user `shopfront` / `shopfront`; databases `orders` and `catalog` with users of the same name |

Ports are bound to 127.0.0.1 only. Change them in `.env` if they clash with something.

## Seed data

`seed.sh` loads 12 products in 4 categories (`seed/catalog.sql`, straight into the
catalog database) and places three orders each for `demo-customer` (the mobile app's
default) and `web-customer` (the web's default) through the orders API. Running it
again doesn't duplicate anything.

Things in the seed worth knowing:

- "Hand grinder (old model)" is inactive and hidden from the shop.
- "Paper filters (100)" has no price, so it can't be ordered.
- "Espresso beans 1kg" has a price history (21.90 until 2026, 18.90 now).

## E2E tests

With the stack up and seeded:

```sh
make e2e
```

runs the web repo's Playwright tests against http://localhost:7080. Run
`npx playwright install chromium` in the web repo once first.

## Mobile app against this stack

```sh
cd ../mobile
flutter run --dart-define=ORDERS_API_URL=http://10.0.2.2:7081 \
            --dart-define=CATALOG_API_URL=http://10.0.2.2:7082   # Android emulator
flutter run                                                     # iOS simulator: localhost defaults
```

The ports are bound to 127.0.0.1, which the Android emulator reaches as `10.0.2.2`. A
physical phone can't reach them; change the port bindings in `compose.yaml` for that.

## Stop

```sh
docker compose down -v    # or: make down. -v also drops the database.
```

## Troubleshooting

- **orders-service unhealthy**: it waits for catalog-service. `docker compose logs
  orders-service catalog-service`.
- **"relation does not exist" in seed.sh**: catalog-service hasn't run its Flyway
  migrations yet. Wait for it to be healthy (`--wait` does that) and run the seed again.
- **Port already in use**: set `WEB_PORT` etc. in `.env`.
