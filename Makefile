include .env
export


export PROJECT_ROOT=$(shell pwd)


env-up:
	@docker compose up -d todoapp-postgres

env-down:
	@docker compose down todoapp-postgres

env-cleanup:
	@read -p "Вы действительно хотите очистить все volume-файлы окружения? Данные будут утеряны. [y/n]: " ans; \
	if [ $$ans = "y" ]; then \
		docker compose down todoapp-postgres port-forwarder -v && \
		echo "Файлы окружения очищены"; \
	else \
		echo "Очистка окружения отменена"; \
	fi

env-port-forward:
	@docker compose up -d port-forwarder

env-port-close:
	@docker compose down port-forwarder


migrate-create:
	@if [ -z "$(seq)" ]; then \
		echo "Отсутствует необходимый параметр seq. Пример: make migrate-create seq=init"; \
		exit 1; \
	fi; \
	docker compose run --rm todoapp-postgres-migrate \
		create \
		-ext sql \
		-dir /migrations \
		-seq "$(seq)"

migrate-up:
	@make migrate-action action=up

migrate-down:
	@make migrate-action action=down

migrate-action:
	@if [ -z "$(action)" ]; then \
		echo "Отсутствует необходимый параметр action. Пример: make migrate-action action=up"; \
		exit 1; \
	fi; \
	docker compose run --rm todoapp-postgres-migrate \
		-path /migrations \
		-database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@todoapp-postgres:5432/${POSTGRES_DB}?sslmode=disable \
		"$(action)"


logs-cleanup:
	@read -p "Вы действительно хотите очистить все log-файлы? Логи будут утеряны. [y/n]: " ans; \
	if [ $$ans = "y" ]; then \
		rm -rf ${PROJECT_ROOT}/out/logs && \
		echo "Файлы логов очищены"; \
	else \
		echo "Очистка логов отменена"; \
	fi


todoapp-run:
	@export LOGGER_FOLDER=${PROJECT_ROOT}/out/logs && \
	export POSTGRES_HOST=localhost && \
	export POSTGRES_PORT=5433 && \
	go mod tidy && \
	go run ${PROJECT_ROOT}/cmd/todoapp/main.go