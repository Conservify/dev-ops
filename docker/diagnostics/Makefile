docker-image:
	docker build -t temp .

docker-test: docker-image
	docker run --rm -p 8080:8080 temp

test:
	node_modules/.bin/vue-cli-service serve

pack:
	node_modules/.bin/vue-cli-service build

run: diagnostics
	./diagnostics --path ~/conservify/diagnostics

diagnostics: *.go
	go build -o diagnostics $^

clean:
	rm -rf node_modules
