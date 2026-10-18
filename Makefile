.PHONY: up seed e2e down logs ps

up:
	docker compose up -d --build --wait

seed:
	./seed.sh

e2e:
	cd $${WEB_DIR:-../web} && E2E_BASE_URL=http://localhost:$${WEB_PORT:-7080} npx playwright test

down:
	docker compose down -v

logs:
	docker compose logs -f --tail=100

ps:
	docker compose ps
