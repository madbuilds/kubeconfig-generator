# Kubeconfig Generator Script
Script which helps automate generation of a Kubeconfig file, based on current `kubectl context`.

## usage
to use this script, pass in namespace and secret names as arguments.
```ssh
./generate_kubeconfig.sh <namespace> <secret>
```

## requirements

before executing the script, make sure you have applied configuration files to the cluster to create:
* Service Account
* Roles
* Role Binding
* Secret

example:
```ssh
kubectl apply -f ./example_namespace.yml
```

if your k8s running withing WSL, remember to pass the required ports to connect to the cluster.
example:
```powershell
New-NetFirewallRule -DisplayName "WSL portproxy HTTP 80 (Any)" -Direction Inbound -Action Allow -LocalPort 80 -Profile Any
netsh interface portproxy add v4tov4 listenport=80 listenaddress=0.0.0.0 connectport=80 connectaddress=$WSL_IP
```
