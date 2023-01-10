# K3d is a tool to generate a K3s environment in Docker.
k3d cluster create k3s --volume C:\Data\K8s:/tmp/shared@server:0 --kubeconfig-update-default --kubeconfig-switch-context --registry-create registry:5000 -p 3333:3306@server:0 -p 8081:80@loadbalancer -p 4222:4222@server:0 -p 8222:8222@server:0 -p 6379:6379@server:0 --api-port=16443 --wait --timeout=60s
# Ports exposed:
# 3333:3306 Use mysql.local:3333 to access mysql inside the cluster
# 8081:80 Use [hostheader]:8081 for web traffic through the loadbalancer (will use ingress/hostheader to redirect)
# 4222:4222 Use nats.local:4222 to access nats streams inside the cluster
# 8222:8222 Use nats.local:8222 to access nats web pages inside the cluster
# 6379:6379 Use redis.local:6379 to access redis inside the cluster

# Add all the basic services: certmanager, grafana, mysql, nats, prometheus, redis and sealedsecrets
kubectl apply -k ./deploy/basesvc

# Check what host port your registry publish and save it in environment:
# From Powershell you can access it as $env:REGISTRYHOST
# From CMD-files you can access it as %REGISTRYHOST%
# Following the k3d command above the value should be: "registry:5000"

$port = (docker port registry).Split(':')[1]
$registryhost = "registry:$($port)"
SETX /M REGISTRYHOST $registryhost
$env:registryhost=$registryhost

"Add following to C:\Windows\System32\drivers\etc\hosts: "
"127.0.0.1 registry"
"127.0.0.1 registry.local"
""

# Verify that you have connection to your registry
curl.exe http://$registryhost/v2/_catalog

"To remove everything regarding cluster, loadbalancer and registry:"
"k3d cluster delete k3slocal"

& ./InitBuild.ps1
& ./InitDeploy.ps1


<#
#Added for development to C:\Windows\System32\drivers\etc\hosts
127.0.0.1 registry
127.0.0.1 registry.local
127.0.0.1 buildversions
127.0.0.1 buildversions.local
127.0.0.1 buildversionsapi
127.0.0.1 buildversionsapi.local
127.0.0.1 clusterauth
127.0.0.1 clusterauth.local
127.0.0.1 customerapi
127.0.0.1 customerapi.local
127.0.0.1 employeeapi
127.0.0.1 employeeapi.local
127.0.0.1 workloadsprojector
127.0.0.1 workloadsprojector.local
127.0.0.1 workloadsapi
127.0.0.1 workloadsapi.local
127.0.0.1 workloads
127.0.0.1 workloads.local
127.0.0.1 nats
127.0.0.1 nats.local
127.0.0.1 prometheus
127.0.0.1 prometheus.local
127.0.0.1 grafana
127.0.0.1 grafana.local
127.0.0.1 mysql
127.0.0.1 mysql.local
127.0.0.1 redis
127.0.0.1 redis.local
#End of section
#>