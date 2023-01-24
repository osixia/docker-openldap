#NAME = okcupid/openldap
NAME = okldap
VERSION = 0.0.4
PREFIX_HOST = wa1okrep000.wa1.okc.iacp.dc:443
PREFIX_PATH = /ops-docker-test-local/
.PHONY: build build-nocache login test tag-latest push push-latest release release-risky release-test git-tag-version

build:
	docker build -t $(NAME):$(VERSION) --rm image

build-nocache:
	docker build -t $(NAME):$(VERSION) --no-cache --rm image

login:
	docker login -u $(USER) $(PREFIX_HOST)

test:
	env NAME=$(NAME) VERSION=$(VERSION) bats test/test.bats

tag:
	docker tag $(NAME):$(VERSION) $(PREFIX_HOST)$(PREFIX_PATH)$(NAME):$(VERSION)

tag-latest:
	docker tag $(NAME):$(VERSION) $(PREFIX_HOST)$(PREFIX_PATH)$(NAME):latest

push:
	docker push $(PREFIX_HOST)$(PREFIX_PATH)$(NAME):$(VERSION)

push-latest:
	docker push $(PREFIX_HOST)$(PREFIX_PATH)$(NAME):latest

release: build test tag tag-latest push push-latest

release-risky: build tag tag-latest login push push-latest

release-test: build push

git-tag-version: release
	git tag -a v$(VERSION) -m "v$(VERSION)"
	git push origin v$(VERSION)
