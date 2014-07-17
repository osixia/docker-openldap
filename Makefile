NAME = osixia/openldap
VERSION = 0.9.1

.PHONY: all build test tag_latest release

all: build

build:
	docker.io build -t $(NAME):$(VERSION) --rm .

test:
	env NAME=$(NAME) VERSION=$(VERSION) ./test.sh debug

tag_latest:
	docker.io tag $(NAME):$(VERSION) $(NAME):latest

release: build test tag_latest
	@if ! docker.io images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	docker.io push $(NAME)
	@echo "*** Don't forget to run 'twgit release finish' :)"

