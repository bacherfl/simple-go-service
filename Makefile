IMG ?= bacherfl/simple-go-service

.PHONY: build-v1
build-v1:
	docker build --build-arg responseTime=0 --platform linux/amd64 --build-arg version=v1 -t ${IMG}:v1 .
	docker push ${IMG}:v1

.PHONY: build-v2
build-v2:
	docker build --build-arg responseTime=2 --platform linux/amd64 --build-arg version=v2 -t ${IMG}:v2 .
	docker push ${IMG}:v2

.PHONY: build-v1-arm64
build-v1-arm64:
	docker build --build-arg responseTime=0 --build-arg version=v1 -t ${IMG}:v1 .
	docker push ${IMG}:v1

.PHONY: build-v2-arm64
build-v2-amd64:
	docker build --build-arg responseTime=2 --build-arg version=v2 -t ${IMG}:v2 .
	docker push ${IMG}:v2
