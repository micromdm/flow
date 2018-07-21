.PHONY: all build server ui

all: build
build: deps ui server
deps: go-deps elm-deps

.prefix:
	mkdir -p build/frontend/assets/

go-deps:
	@which dep > /dev/null 2>&1 || \
		echo "Installing dep" && go get -u github.com/golang/dep/cmd/dep
	dep ensure -vendor-only

elm-deps:
	cd ui && elm-package install

ui: .prefix
	cd ui && elm-make src/Main.elm --output assets/generated/elm.js

generate:
	go-bindata \
		-prefix=ui/ $(DEV) -pkg=bindata -o=server/bindata/bindata_generated.go ui/index.html ui/assets/... 

export DEV=-debug
generate-dev: generate

server:
	go build -o build/flow ./cmd/flow

docker-up-dev:
	docker-compose -f docker-compose-dev.yaml up -d  

GOOSE :=cd server/data/migrations && goose postgres "host=localhost port=5432 user=flow dbname=flow password=work sslmode=disable"
migrate-up-dev:
	$(GOOSE) up

migrate-down-dev:
	$(GOOSE) down

psql-dev:
	docker exec -it flow_db_1 psql -U flow

serve-dev: ui generate-dev server docker-up-dev migrate-up-dev
	./build/flow
