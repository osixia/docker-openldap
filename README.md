## docker-openldap

Fork of Nick Stenning docker-slapd :
https://github.com/nickstenning/docker-slapd

Add support of tls.

### How to use tls

Add `-v some/host/dir:/etc/ldap/ssl` and `--dns=127.0.0.1` to the run command.

`some/host/dir` must contain a least 3 files :
- `ca.crt` certificate authority certificate
- `ldap.crt` ldap server certificate
- `ldap.key` ldap server certificate private key

and optionaly `dhparam.pem` this file is genereted automaticaly if not present.

`--dns=127.0.0.1` allow to use the certificate cn correctly.


### Example

    docker run --dns=127.0.0.1 \
               -v /data/ldap/db:/var/lib/ldap \
               -v /data/ldap/config:/etc/ldap/slapd.d \
               -v /data/ldap/ssl/:/etc/ldap/ssl \
               -v /data/ldap/log/:/var/log \
               -e LDAP_DOMAIN=example.com \
               -e LDAP_ORGANISATION="Example Corp." \
               -e LDAP_ROOTPASS=toor \
               -p 389:389 -d osixia/openldap


### License

The MIT License (MIT)

Copyright (c) [year] [fullname]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
