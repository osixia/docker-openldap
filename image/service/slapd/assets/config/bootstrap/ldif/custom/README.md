Add your custom ldif files here if you don't want to overwrite image default boostrap ldif.
at run time you can also mount a data volume with your ldif files to /container/service/slapd/assets/config/bootstrap/ldif/custom

The startup script provide some substitution in bootstrap ldif files:
`{{LDAP_BASE_DN }}` and `{{ LDAP_BACKEND }}` values are supported.
Other `{{ * }}` substitution are left as is.

Since startup script modifies `ldif` files,
you **must** add `--copy-service` argument to entrypoint if you don't want to overwrite them.
