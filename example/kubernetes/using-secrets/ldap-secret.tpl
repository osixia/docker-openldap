apiVersion: "v1"
kind: "List"
items:
  - kind: "Secret"
    apiVersion: "v1"
    metadata:
      name: "ldap-secret"
    data:
      # files in environment/* converted into base64 with file-to-base64.sh
      env.yaml: "$ENV_YAML"
      env.startup.yaml: "$ENV_STARTUP_YAML"
