# Helm-chart

After setting the variables you can get strange variables like:

https://github.com/osixia/docker-openldap/issues/342

I have found that using this helm chart does not have those issues:

https://github.com/jp-gouin/helm-openldap.git

# Generating ldap-secret.yaml

`make example`

Then edit the yaml files in the environment directory to have the desired parameters, and then make the secret file:

`make ldap-secret.yaml`

And deploy the secret you just made:

`kubectl apply -f ldap-secret.yaml`

Apply the deployment yaml for ldap in k8s:

`kubectl apply -f ldap-deployment.yaml`

Finally apply the service yaml for ldap in k8s:

`kubectl apply -f ldap-service.yaml`
