ldap-secret.yaml: example
	$(eval PWD := $(shell pwd -P))
	$(eval ENV_DIR := $(shell echo ${PWD}/environment))
	ENV_YAML=$(shell ${ENV_DIR}/file-to-base64.sh ${ENV_DIR}/my-env.yaml) \
	ENV_STARTUP_YAML=$(shell ${ENV_DIR}/file-to-base64.sh ${ENV_DIR}/my-env.startup.yaml) \
	envsubst < ldap-secret.tpl > ldap-secret.yaml

example: environment/my-env.startup.yaml environment/my-env.yaml ldap-deployment.yaml

environment/my-env.startup.yaml:
	cd environment ; cp my-env.startup.yaml.example my-env.startup.yaml

environment/my-env.yaml:
	cd environment ; cp my-env.yaml.example my-env.yaml

ldap-deployment.yaml:
	cp ldap-deployment.yaml.example ldap-deployment.yaml
