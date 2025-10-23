.PHONY: help run build test sqlc migrate-up migrate-down migrate-create seed clean

# Variáveis
APP_NAME=products-api
MIGRATIONS_PATH=./db/migrations
# DB_URL=postgresql://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=$(DB_SSLMODE)
DB_URL=postgresql://postgres:postgres@localhost:5432/postgres?sslmode=disable

# Carregar variáveis de ambiente
include .env
export

# Comando padrão
help:
	@echo "Comandos disponíveis:"
	@echo "  make run            - Executa a aplicação"
	@echo "  make build          - Compila a aplicação"
	@echo "  make test           - Executa os testes"
	@echo "  make sqlc           - Gera código SQLC"
	@echo "  make migrate-up     - Executa migrações (up)"
	@echo "  make migrate-down   - Reverte migrações (down)"
	@echo "  make migrate-create - Cria nova migração"
	@echo "  make seed           - Insere dados de exemplo"
	@echo "  make clean          - Remove binários"

# Executar aplicação
run:
	@echo "Iniciando aplicação..."
	go run cmd/api/main.go

# Build da aplicação
build:
	@echo "Compilando aplicação..."
	@mkdir -p bin
	go build -o bin/$(APP_NAME) cmd/api/main.go
	@echo "Binário criado em: bin/$(APP_NAME)"

# Executar testes
test:
	@echo "Executando testes..."
	go test -v -cover ./...

# Gerar código SQLC
sqlc:
	@echo "Gerando código SQLC..."
	sqlc generate
	@echo "Código gerado em: db/sqlc/"

# Executar migrações (up)
migrate-up:
	@echo "Executando migrações..."
	migrate -path $(MIGRATIONS_PATH) -database "$(DB_URL)" -verbose up

# Reverter migrações (down)
migrate-down:
	@echo "Revertendo migrações..."
	migrate -path $(MIGRATIONS_PATH) -database "$(DB_URL)" -verbose down

# Criar nova migração
migrate-create:
	@read -p "Nome da migração: " name; \
	migrate create -ext sql -dir $(MIGRATIONS_PATH) -seq $$name

# Inserir dados de exemplo
seed:
	@echo "Inserindo dados de exemplo..."
	psql "$(DB_URL)" -f db/seeds/products.sql
	@echo "Dados inseridos com sucesso!"

# Limpar binários
clean:
	@echo "Removendo binários..."
	rm -rf bin/
	@echo "Limpeza concluída!"

# Instalar dependências
deps:
	@echo "Instalando dependências..."
	go mod download
	go mod tidy

# Verificar formatação
fmt:
	@echo "Formatando código..."
	go fmt ./...

# Executar linter
lint:
	@echo "Executando linter..."
	golangci-lint run

# Docker commands
docker-build:
	docker build -t $(APP_NAME) .

docker-run:
	docker run -p 8080:8080 --env-file .env $(APP_NAME)

# Database commands
db-create:
	createdb $(DB_NAME)

db-drop:
	dropdb $(DB_NAME)

db-reset: db-drop db-create migrate-up seed
