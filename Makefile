NAME = osixia/openldap
VERSION = 1.2.3

.PHONY: build build-nocache test tag-latest push push-latest release git-tag-version

build:
	docker build -t $(NAME):$(VERSION) --rm image

build-nocache:
	docker build -t $(NAME):$(VERSION) --no-cache --rm image

test:
	env NAME=$(NAME) VERSION=$(VERSION) bats test/test.bats

tag-latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest

push:
	docker push $(NAME):$(VERSION)

push-latest:
	docker push $(NAME):latest

release: build test tag-latest push push-latest

git-tag-version: release
	git tag -a v$(VERSION) -m "v$(VERSION)"
	git push origin v$(VERSION)
