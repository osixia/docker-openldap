# OpenLDAP on Kubernetes with Cert Manager

Running OpenLDAP on Kubernetes using TLS certificates from cert-manager.

## Prerequisite

- Kubernetes with working ingress and cert-manager.


### Apply the ingress yaml to trigger cert-manager creating certs:

`kubectl apply -f ldap-ingress.yaml`

### Apply the deployment yaml for ldap in k8s:

`kubectl apply -f ldap-deployment.yaml`

### Apply the service yaml for ldap in k8s:

`kubectl apply -f ldap-service.yaml`

### Edit CoreDNS to rewrite ldap.example.org to ldap.default.svc.cluster.local

`kubectl get configmap coredns -n kube-system -o=json | jq -r '.data.Corefile'`
<pre>
.:53 {
    errors
    health {
        lameduck 5s
    }
    ready
    log . {
        class error
    }
    <span style="color:green">rewrite name exact ldap.example.org. ldap.default.svc.cluster.local.</span>
    kubernetes cluster.local in-addr.arpa ip6.arpa {
        pods insecure
        fallthrough in-addr.arpa ip6.arpa
    }
    prometheus :9153
    forward . 8.8.8.8 8.8.4.4 
    cache 30
    loop
    reload
    loadbalance
}
</pre>


## Result
`kubectl get deployment,pod,replicaset,ingress,service,configmap,secret`
<pre>
NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ldap   1/1     1            1           1h

NAME                        READY   STATUS    RESTARTS   AGE
pod/ldap-6b4c4d44f9-fwmcw   1/1     Running   0          1h

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/ldap-6b4c4d44f9   1         1         1       1h

NAME                             CLASS    HOSTS              ADDRESS     PORTS     AGE
ingress.networking.k8s.io/ldap   public   ldap.example.org   127.0.0.1   80, 443   1h

NAME           TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)           AGE
service/ldap   ClusterIP   10.x.x.x     <none>        389/TCP,636/TCP   1h

NAME                         DATA   AGE
configmap/kube-root-ca.crt   1      1h

NAME                          TYPE                DATA   AGE
secret/org-example-ldap-tls   kubernetes.io/tls   2      1h
</pre>
