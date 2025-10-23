# Execução do backend

```sh
migrate -database ${POSTGRESQL_URL} -path db/migrations up
```

```sh
export POSTGRESQL_URL='postgres://postgres:postgres@localhost:5432/postgres?sslmode=disable'
```
