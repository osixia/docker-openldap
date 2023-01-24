#NAME = okcupid/openldap
NAME = okldap
VERSION = ${VERSION:-0.0.3}
PREFIX = wa1okrep000.wa1.okc.iacp.dc:443/ops-docker-test-local/

.PHONY: build build-nocache test tag-latest push push-latest release release-risky release-test git-tag-version

build:
	docker build -t $(NAME):$(VERSION) --rm image

build-nocache:
	docker build -t $(NAME):$(VERSION) --no-cache --rm image

test:
	env NAME=$(NAME) VERSION=$(VERSION) bats test/test.bats

tag:
	docker tag $(NAME):$(VERSION) $(PREFIX)$(NAME):$(VERSION)

tag-latest:
	docker tag $(NAME):$(VERSION) $(PREFIX)$(NAME):latest

push:
	docker push $(PREFIX)$(NAME):$(VERSION)

push-latest:
	docker push $(PREFIX)$(NAME):latest

release: build test tag-latest push push-latest

release-risky: build tag-latest push push-latest

release-test: build push

git-tag-version: release
	git tag -a v$(VERSION) -m "v$(VERSION)"
	git push origin v$(VERSION)
