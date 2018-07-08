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

serve-dev: ui generate-dev server
	./build/flow
