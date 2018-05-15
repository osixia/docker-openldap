# osixia/openldap

![Docker Pulls](https://img.shields.io/docker/pulls/osixia/openldap.svg)
![Docker Stars](https://img.shields.io/docker/stars/osixia/openldap.svg)
![](https://images.microbadger.com/badges/image/osixia/openldap.svg)

Latest release: 1.2.1 - OpenLDAP 2.4.44 -  [Changelog](CHANGELOG.md) | [Docker Hub](https://hub.docker.com/r/osixia/openldap/) 

**A docker image to run OpenLDAP.**

> OpenLDAP website : [www.openldap.org](http://www.openldap.org/)


- [Contributing](#contributing)
- [Quick Start](#quick-start)
- [Beginner Guide](#beginner-guide)
	- [Create new ldap server](#create-new-ldap-server)
		- [Data persistence](#data-persistence)
		- [Edit your server configuration](#)
	- [Use an existing ldap database](#use-an-existing-ldap-database)
	- [Backup](#backup)
	- [Administrate your ldap server](#administrate-your-ldap-server)
	- [TLS](#tls)
		- [Use auto-generated certificate](#use-auto-generated-certificate)
		- [Use your own certificate](#use-your-own-certificate)
		- [Disable TLS](#disable-tls)
	- [Multi master replication](#multi-master-replication)
	- [Fix docker mounted file problems](#fix-docker-mounted-file-problems)
	- [Debug](#debug)
- [Environment Variables](#environment-variables)
	- [Default.yaml](#defaultyaml)
	- [Default.startup.yaml](#defaultyamlstartup)
	- [Set your own environment variables](#set-your-own-environment-variables)
		- [Use command line argument](#use-command-line-argument)
		- [Link environment file](#link-environment-file)
		- [Make your own image or extend this image](#make-your-own-image-or-extend-this-image)
- [Advanced User Guide](#advanced-user-guide)
	- [Extend osixia/openldap:1.2.1 image](#extend-osixiaopenldap121-image)
	- [Make your own openldap image](#make-your-own-openldap-image)
	- [Tests](#tests)
	- [Kubernetes](#kubernetes)
	- [Under the hood: osixia/light-baseimage](#under-the-hood-osixialight-baseimage)
- [Security](#security)
	- [Known security issues](#known-security-issues)
- [Changelog](#changelog)

## Contributing

If you find this image useful here's how you can help:

- Send a pull request with your kickass new features and bug fixes
- Help new users with [issues](https://github.com/osixia/docker-openldap/issues) they may encounter
- Support the development of this image and star this repo !

## Quick Start
Run OpenLDAP docker image:

	docker run --name my-openldap-container --detach osixia/openldap:1.2.1

This start a new container with OpenLDAP running inside. Let's make the first search in our LDAP container:

	docker exec my-openldap-container ldapsearch -x -H ldap://localhost -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w admin

This should output:

	# extended LDIF
	#
	# LDAPv3
	# base <dc=example,dc=org> with scope subtree
	# filter: (objectclass=*)
	# requesting: ALL
	#

	[...]

	# numResponses: 3
	# numEntries: 2

If you have the following error, OpenLDAP is not started yet, maybe you are too fast or maybe your computer is to slow, as you want... but wait some time before retrying.

		ldap_sasl_bind(SIMPLE): Can't contact LDAP server (-1)


## Beginner Guide

### Create new ldap server

This is the default behavior when you run this image.
It will create an empty ldap for the company **Example Inc.** and the domain **example.org**.

By default the admin has the password **admin**. All those default settings can be changed at the docker command line, for example:

	docker run --env LDAP_ORGANISATION="My Company" --env LDAP_DOMAIN="my-company.com" \
	--env LDAP_ADMIN_PASSWORD="JonSn0w" --detach osixia/openldap:1.2.1

#### Data persistence

The directories `/var/lib/ldap` (LDAP database files) and `/etc/ldap/slapd.d`  (LDAP config files) are used to persist the schema and data information, and should be mapped as volumes, so your ldap files are saved outside the container (see [Use an existing ldap database](#use-an-existing-ldap-database)). However it can be useful to not use volumes,
in case the image should be delivered complete with test data - this is especially useful when deriving other images from this one.

The default uid and gid used by the image may map to surprising
counterparts in the host. If you need to match uid and gid in the
container and in the host, you can use build parameters
`LDAP_OPENLDAP_UID` and `LDAP_OPENLDAP_GID` to set uid and gid
explicitly:

	docker build --build-arg LDAP_OPENLDAP_GID=1234 --build-arg LDAP_OPENLDAP_UID=2345 -t my_ldap_image .
	docker run --name my_ldap_container -d my_ldap_image
	# this should output uid=2345(openldap) gid=1234(openldap) groups=1234(openldap)
	docker exec my_ldap_container id openldap

For more information about docker data volume, please refer to:

> [https://docs.docker.com/engine/tutorials/dockervolumes/](https://docs.docker.com/engine/tutorials/dockervolumes/)


#### Edit your server configuration

Do not edit slapd.conf it's not used. To modify your server configuration use ldap utils: **ldapmodify / ldapadd / ldapdelete**

#### Seed ldap database with ldif

This image can load ldif files at startup with either `ldapadd` or `ldapmodify`.
Mount `.ldif` in `/container/service/slapd/assets/config/bootstrap/ldif` directory if you want to overwrite image default boostrap ldif files or in `/container/service/slapd/assets/config/bootstrap/ldif/custom` (recommended) to extend image config.

Files containing `changeType:` attributes will be loaded with `ldapmodify`.

The startup script provides some substitutions in bootstrap ldif files. Following substitutions are supported:

- `{{ LDAP_BASE_DN }}`
- `{{ LDAP_BACKEND }}`
- `{{ LDAP_READONLY_USER_USERNAME }}`
- `{{ LDAP_READONLY_USER_PASSWORD_ENCRYPTED }}`

Other `{{ * }}` substitutions are left unchanged.

Since startup script modifies `ldif` files, you **must** add `--copy-service`
argument to entrypoint if you don't want to overwrite them.


		# single file example:
		docker run \
      --volume ./bootstrap.ldif:/container/service/slapd/assets/config/bootstrap/ldif/50-bootstrap.ldif \
      osixia/openldap:1.2.1 --copy-service

		#directory example:
		docker run \
	     --volume ./ldif:/container/service/slapd/assets/config/bootstrap/ldif/custom \
	     osixia/openldap:1.2.1 --copy-service

### Use an existing ldap database

This can be achieved by mounting host directories as volume.
Assuming you have a LDAP database on your docker host in the directory `/data/slapd/database`
and the corresponding LDAP config files on your docker host in the directory `/data/slapd/config`
simply mount this directories as a volume to `/var/lib/ldap` and `/etc/ldap/slapd.d`:

	docker run --volume /data/slapd/database:/var/lib/ldap \
	--volume /data/slapd/config:/etc/ldap/slapd.d \
	--detach osixia/openldap:1.2.1

You can also use data volume containers. Please refer to:
> [https://docs.docker.com/engine/tutorials/dockervolumes/](https://docs.docker.com/engine/tutorials/dockervolumes/)

Note: By default this image is waiting an **mdb**  database backend, if you want to use any other database backend set backend type via the LDAP_BACKEND environement variable.

### Backup
A simple solution to backup your ldap server, is our openldap-backup docker image:
> [osixia/openldap-backup](https://github.com/osixia/docker-openldap-backup)

### Administrate your ldap server
If you are looking for a simple solution to administrate your ldap server you can take a look at our phpLDAPadmin docker image:
> [osixia/phpldapadmin](https://github.com/osixia/docker-phpLDAPadmin)

### TLS

#### Use auto-generated certificate
By default, TLS is already configured and enabled, certificate is created using container hostname (it can be set by docker run --hostname option eg: ldap.example.org).

	docker run --hostname ldap.my-company.com --detach osixia/openldap:1.2.1

#### Use your own certificate

You can set your custom certificate at run time, by mounting a directory containing those files to **/container/service/slapd/assets/certs** and adjust their name with the following environment variables:

	docker run --hostname ldap.example.org --volume /path/to/certificates:/container/service/slapd/assets/certs \
	--env LDAP_TLS_CRT_FILENAME=my-ldap.crt \
	--env LDAP_TLS_KEY_FILENAME=my-ldap.key \
	--env LDAP_TLS_CA_CRT_FILENAME=the-ca.crt \
	--detach osixia/openldap:1.2.1

Other solutions are available please refer to the [Advanced User Guide](#advanced-user-guide)

#### Disable TLS
Add --env LDAP_TLS=false to the run command:

	docker run --env LDAP_TLS=false --detach osixia/openldap:1.2.1

### Multi master replication
Quick example, with the default config.

	#Create the first ldap server, save the container id in LDAP_CID and get its IP:
	LDAP_CID=$(docker run --hostname ldap.example.org --env LDAP_REPLICATION=true --detach osixia/openldap:1.2.1)
	LDAP_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" $LDAP_CID)

	#Create the second ldap server, save the container id in LDAP2_CID and get its IP:
	LDAP2_CID=$(docker run --hostname ldap2.example.org --env LDAP_REPLICATION=true --detach osixia/openldap:1.2.1)
	LDAP2_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" $LDAP2_CID)

	#Add the pair "ip hostname" to /etc/hosts on each containers,
	#because ldap.example.org and ldap2.example.org are fake hostnames
	docker exec $LDAP_CID bash -c "echo $LDAP2_IP ldap2.example.org >> /etc/hosts"
	docker exec $LDAP2_CID bash -c "echo $LDAP_IP ldap.example.org >> /etc/hosts"

That's it! But a little test to be sure:

Add a new user "billy" on the first ldap server

	docker exec $LDAP_CID ldapadd -x -D "cn=admin,dc=example,dc=org" -w admin -f /container/service/slapd/assets/test/new-user.ldif -H ldap://ldap.example.org -ZZ

Search on the second ldap server, and billy should show up!

	docker exec $LDAP2_CID ldapsearch -x -H ldap://ldap2.example.org -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w admin -ZZ

	[...]

	# billy, example.org
	dn: uid=billy,dc=example,dc=org
	uid: billy
	cn: billy
	sn: 3
	objectClass: top
	objectClass: posixAccount
	objectClass: inetOrgPerson
	[...]

### Fix docker mounted file problems

You may have some problems with mounted files on some systems. The startup script try to make some file adjustment and fix files owner and permissions, this can result in multiple errors. See [Docker documentation](https://docs.docker.com/v1.4/userguide/dockervolumes/#mount-a-host-file-as-a-data-volume).

To fix that run the container with `--copy-service` argument :

		docker run [your options] osixia/openldap:1.2.1 --copy-service

### Debug

The container default log level is **info**.
Available levels are: `none`, `error`, `warning`, `info`, `debug` and `trace`.

Example command to run the container in `debug` mode:

	docker run --detach osixia/openldap:1.2.1 --loglevel debug

See all command line options:

	docker run osixia/openldap:1.2.1 --help


## Environment Variables
Environment variables defaults are set in **image/environment/default.yaml** and **image/environment/default.startup.yaml**.

See how to [set your own environment variables](#set-your-own-environment-variables)

### Default.yaml
Variables defined in this file are available at anytime in the container environment.

General container configuration:
- **LDAP_LOG_LEVEL**: Slap log level. defaults to  `256`. See table 5.1 in http://www.openldap.org/doc/admin24/slapdconf2.html for the available log levels.

### Default.startup.yaml
Variables defined in this file are only available during the container **first start** in **startup files**.
This file is deleted right after startup files are processed for the first time,
then all of these values will not be available in the container environment.

This helps to keep your container configuration secret. If you don't care all environment variables can be defined in **default.yaml** and everything will work fine.

Required and used for new ldap server only:
- **LDAP_ORGANISATION**: Organisation name. Defaults to `Example Inc.`
- **LDAP_DOMAIN**: Ldap domain. Defaults to `example.org`
- **LDAP_BASE_DN**: Ldap base DN. If empty automatically set from LDAP_DOMAIN value. Defaults to `(empty)`
- **LDAP_ADMIN_PASSWORD** Ldap Admin password. Defaults to `admin`
- **LDAP_CONFIG_PASSWORD** Ldap Config password. Defaults to `config`

- **LDAP_READONLY_USER** Add a read only user. Defaults to `false`
- **LDAP_READONLY_USER_USERNAME** Read only user username. Defaults to `readonly`
- **LDAP_READONLY_USER_PASSWORD** Read only user password. Defaults to `readonly`

- **LDAP_RFC2307BIS_SCHEMA** Use rfc2307bis schema instead of nis schema. Defaults to `false`

Backend:
- **LDAP_BACKEND**: Ldap backend. Defaults to `mdb` (previously hdb in image versions up to v1.1.10)

	Help: http://www.openldap.org/doc/admin24/backends.html

TLS options:
- **LDAP_TLS**: Add openldap TLS capabilities. Can't be removed once set to true. Defaults to `true`.
- **LDAP_TLS_CRT_FILENAME**: Ldap ssl certificate filename. Defaults to `ldap.crt`
- **LDAP_TLS_KEY_FILENAME**: Ldap ssl certificate private key filename. Defaults to `ldap.key`
- **LDAP_TLS_CA_CRT_FILENAME**: Ldap ssl CA certificate  filename. Defaults to `ca.crt`
- **LDAP_TLS_ENFORCE**: Enforce TLS but except ldapi connections. Can't be disabled once set to true. Defaults to `false`.
- **LDAP_TLS_CIPHER_SUITE**: TLS cipher suite. Defaults to `SECURE256:+SECURE128:-VERS-TLS-ALL:+VERS-TLS1.2:-RSA:-DHE-DSS:-CAMELLIA-128-CBC:-CAMELLIA-256-CBC`, based on Red Hat's [TLS hardening guide](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Security_Guide/sec-Hardening_TLS_Configuration.html)
- **LDAP_TLS_VERIFY_CLIENT**: TLS verify client. Defaults to `demand`

	Help: http://www.openldap.org/doc/admin24/tls.html

Replication options:
- **LDAP_REPLICATION**: Add openldap replication capabilities. Defaults to `false`

- **LDAP_REPLICATION_CONFIG_SYNCPROV**: olcSyncRepl options used for the config database. Without **rid** and **provider** which are automatically added based on LDAP_REPLICATION_HOSTS.  Defaults to `binddn="cn=admin,cn=config" bindmethod=simple credentials=$LDAP_CONFIG_PASSWORD searchbase="cn=config" type=refreshAndPersist retry="60 +" timeout=1 starttls=critical`

- **LDAP_REPLICATION_DB_SYNCPROV**: olcSyncRepl options used for the database. Without **rid** and **provider** which are automatically added based on LDAP_REPLICATION_HOSTS.  Defaults to `binddn="cn=admin,$LDAP_BASE_DN" bindmethod=simple credentials=$LDAP_ADMIN_PASSWORD searchbase="$LDAP_BASE_DN" type=refreshAndPersist interval=00:00:00:10 retry="60 +" timeout=1 starttls=critical`

- **LDAP_REPLICATION_HOSTS**: list of replication hosts, must contain the current container hostname set by --hostname on docker run command. Defaults to :
	```yaml
  - ldap://ldap.example.org
  - ldap://ldap2.example.org
	```

	If you want to set this variable at docker run command add the tag `#PYTHON2BASH:` and convert the yaml in python:

		docker run --env LDAP_REPLICATION_HOSTS="#PYTHON2BASH:['ldap://ldap.example.org','ldap://ldap2.example.org']" --detach osixia/openldap:1.2.1

	To convert yaml to python online: http://yaml-online-parser.appspot.com/

Other environment variables:
- **KEEP_EXISTING_CONFIG**: Do not change the ldap config. Defaults to `false`
	- if set to *true* with an existing database, config will remain unchanged. Image tls and replication config will not be run. The container can be started with LDAP_ADMIN_PASSWORD and LDAP_CONFIG_PASSWORD empty or filled with fake data.
	- if set to *true* when bootstrapping a new database, bootstap ldif and schema will not be added and tls and replication config will not be run.

- **LDAP_REMOVE_CONFIG_AFTER_SETUP**: delete config folder after setup. Defaults to `true`
- **LDAP_SSL_HELPER_PREFIX**: ssl-helper environment variables prefix. Defaults to `ldap`, ssl-helper first search config from LDAP_SSL_HELPER_* variables, before SSL_HELPER_* variables.
- **HOSTNAME**: set the hostname of the running openldap server. Defaults to whatever docker creates.


### Set your own environment variables

#### Use command line argument
Environment variables can be set by adding the --env argument in the command line, for example:

	docker run --env LDAP_ORGANISATION="My company" --env LDAP_DOMAIN="my-company.com" \
	--env LDAP_ADMIN_PASSWORD="JonSn0w" --detach osixia/openldap:1.2.1

Be aware that environment variable added in command line will be available at any time
in the container. In this example if someone manage to open a terminal in this container
he will be able to read the admin password in clear text from environment variables.

#### Link environment file

For example if your environment files **my-env.yaml** and **my-env.startup.yaml** are in /data/ldap/environment

	docker run --volume /data/ldap/environment:/container/environment/01-custom \
	--detach osixia/openldap:1.2.1

Take care to link your environment files folder to `/container/environment/XX-somedir` (with XX < 99 so they will be processed before default environment files) and not  directly to `/container/environment` because this directory contains predefined baseimage environment files to fix container environment (INITRD, LANG, LANGUAGE and LC_CTYPE).

Note: the container will try to delete the **\*.startup.yaml** file after the end of startup files so the file will also be deleted on the docker host. To prevent that : use --volume /data/ldap/environment:/container/environment/01-custom**:ro** or set all variables in **\*.yaml** file and don't use **\*.startup.yaml**:

	docker run --volume /data/ldap/environment/my-env.yaml:/container/environment/01-custom/env.yaml \
	--detach osixia/openldap:1.2.1

#### Make your own image or extend this image

This is the best solution if you have a private registry. Please refer to the [Advanced User Guide](#advanced-user-guide) just below.

## Advanced User Guide

### Extend osixia/openldap:1.2.1 image

If you need to add your custom TLS certificate, bootstrap config or environment files the easiest way is to extends this image.

Dockerfile example:

	FROM osixia/openldap:1.2.1
	MAINTAINER Your Name <your@name.com>

	ADD bootstrap /container/service/slapd/assets/config/bootstrap
	ADD certs /container/service/slapd/assets/certs
	ADD environment /container/environment/01-custom

See complete example in **example/extend-osixia-openldap**

Warning: if you want to install new packages from debian repositories, this image has a configuration to prevent documentation and locales to be installed. If you need the doc and locales remove the following files :
**/etc/dpkg/dpkg.cfg.d/01_nodoc** and **/etc/dpkg/dpkg.cfg.d/01_nolocales**

### Make your own openldap image

Clone this project:

	git clone https://github.com/osixia/docker-openldap
	cd docker-openldap

Adapt Makefile, set your image NAME and VERSION, for example:

	NAME = osixia/openldap
	VERSION = 1.1.9

	become:
	NAME = cool-guy/openldap
	VERSION = 0.1.0

Add your custom certificate, bootstrap ldif and environment files...

Build your image:

	make build

Run your image:

	docker run --detach cool-guy/openldap:0.1.0

### Tests

We use **Bats** (Bash Automated Testing System) to test this image:

> [https://github.com/sstephenson/bats](https://github.com/sstephenson/bats)

Install Bats, and in this project directory run:

	make test

### Kubernetes

Kubernetes is an open source system for managing containerized applications across multiple hosts, providing basic mechanisms for deployment, maintenance, and scaling of applications.

More information:
- http://kubernetes.io
- https://github.com/kubernetes/kubernetes

osixia-openldap kubernetes examples are available in **example/kubernetes**

### Under the hood: osixia/light-baseimage

This image is based on osixia/light-baseimage.
It uses the following features:

- **ssl-tools** service to generate tls certificates
- **log-helper** tool to print log messages based on the log level
- **run** tool as entrypoint to init the container environment

To fully understand how this image works take a look at:
https://github.com/osixia/docker-light-baseimage

## Security
If you discover a security vulnerability within this docker image, please send an email to the Osixia! team at security@osixia.net. For minor vulnerabilities feel free to add an issue here on github.

Please include as many details as possible.

### Known security issues
Openldap on debian creates two admin users with the same password, if you changed admin password after bootstrap you may be concerned by issue #161.

## Changelog

Please refer to: [CHANGELOG.md](CHANGELOG.md)
