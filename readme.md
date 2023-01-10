## Prerequisites
* Powershell 7, Net Core based, from a powershell prompt run, *winget install --id Microsoft.Powershell --source winget*
* Chocolatey, install tool, *https://chocolatey.org*  
* Docker Desktop for Windows, *choco install docker-desktop*  
* ConEmu, command prompt, *choco install conemu*
* Curl, http command line tool, *choco install curl*  
* Kubernetes CLI, KubeCtl, *choco install kubernetes-cli*  
* Kustomize CLI, *choco install kustomize*  
* Kubernetes admin tool, K9s, *choco install k9s*  
* K3d, tool to run K3s Kubernetes in Docker, *choco install k3d*  

## Setting up Docker  
Download and install Docker for Windows Desktop. Configure it to use Windows Subsystem for Linux (WSL).  

## Setting up Kubernetes  
We are going to use a lightweight version of Kubernetes (k8s) that is named k3s. This distribution was originally created by a company named Rancher but they decided to donate it to Cloud Native Computing Foundation (CNCF). CNCF have put k3s at sandbox level as First Kubernetes distribution. See more at: https://landscape.cncf.io and also https://github.com/k3s-io/k3s  


### K3s  
K3s is a very efficient and lightweight fully compliant Kubernetes distribution.  
K3s includes:

Flannel: a very simple L2 overlay network that satisfies the Kubernetes requirements. This is a CNI plugin (Container Network Interface), such as Calico, Romana, Weave-net.  
Flannel doesn’t support Kubernetes Network Policy, but it can be replaced by Calico if needed.

CoreDNS: a flexible, extensible DNS server that can serve as the Kubernetes cluster DNS

Traefik: a modern HTTP reverse proxy and load balancer.
Could easily be replace it either by Traefik v2 or Nginx

Klipper Load Balancer : Service load balancer that uses available host ports.

SQLite3: The storage backend used by default (also support MySQL, Postgres, and etcd3)

Containerd: a runtime container like Docker without the image build part  

The choices of these components were made to have the most lightweight distribution. But since k3s is a modular distribution all the components can easily be replaced.  


### K3d  
K3d is a utility designed to easily run k3s in Docker, it provides a simple CLI to create, run, delete a fully compliance Kubernetes cluster with 1 to n nodes.  

Url: https://k3d.io/  

To set up Kubernetes inside Docker we will use the command line tool named K3d. The command for creating a cluster is:  
*k3d cluster create clustername*  
See more: https://k3d.io/v5.4.6/usage/commands/k3d_cluster_create/  

And if we would like to delete the cluster simply run:  
*k3d cluster delete clustername*  
See more: https://k3d.io/v5.4.6/usage/commands/k3d_cluster_delete/  

It is also possible to start and stop the cluster with this command...  

The command we will issue in this demo is:  
*k3d cluster create k3s --volume C:\Data\K8s:/tmp/shared@server:0 --kubeconfig-update-default --kubeconfig-switch-context --registry-create registry:5000 -p 8081:80@loadbalancer -p 8443:443@loadbalancer -p 3333:3306@server:0 -p 4222:4222@server:0 -p 8222:8222@server:0 -p 6379:6379@server:0 --api-port=16443 --wait --timeout=60s*  
If we dissect this commandline:
* Create a cluster named k3s (the final name will be k3d-k3s-server-n, where n is the number of each node)  
* Add a volume in the server node under /tmp/shared and map it to our local disk C:\Data\k8s (this will act as our file share against the cluster)  
* Update the current kubeconfig stored under your local account and switch the active context to be our cluster. This means all cli commands will be directed against our cluster)  
* Create a registry container in Docker where we can store all our images for later deployment in the cluster. (Registry is a docker compliant storage like the Docker Hub)  
* Expose port 8081 in the loadbalancer as the entrypoint for port 80, do the same with port 8443 as the entrypoint for port 443.  
* On the server node expose port 3333 and redirect it into the node to port 3306 (MySql default port), do the same with ports 4222 and 8222 (Nats JetStream default ports) and also port 6379 (Redis default port)  
* Define our api-port as 16443, this is the cli api interface, used by all tools like kubectl and k9s.  
* Finally we just add a wait and a timeout for the command to be able to finish.  

Once we have executed this command we will have a Kubernetes cluster up and running!

If you run the command *docker ps* you will see that you now have three containers up and running...  

Let's explore the cluster a bit from Visual Studio, Docker Desktop and finally with k9s...  
In Visual Studio select View - Other Windows - Containers...  
Start Docker Desktop and open the tab Containers...  
Start k9s and if needed select the K3d-K3s cluster, type in :namespaces  




## Database server    
In some of the examples we are using databases, for that purpose we are using MySql. How to deploy this will be showed further down in this document.  

## Event streaming server  
In some of the examples we are using event streaming, for that purpose we are using Nats. How to deploy this will be showed further down in this document.  

## Caching  
In some of the examples we are using caching, for that purpose we are using Redis. How to deploy this will be showed further down in this document.  

## Init cluster with MySql  
In the solutionfolder run following command:  
*kubectl apply -k ./deploy/mysql*  

## Init cluster with Nats  
In the solutionfolder run following command:  
*kubectl apply -k ./deploy/nats*  

## Init cluster with SealedSecrets  
In the solutionfolder run following command:  
*kubectl apply -k ./deploy/sealedsecrets*  

## Init cluster with Prometheus  
In the solutionfolder run following command:  
*kubectl apply -k ./deploy/prometheus*  

## Init cluster with Grafana  
In the solutionfolder run following command:  
*kubectl apply -k ./deploy/grafana*  

## Init cluster with Redis  
In the solutionfolder run following command:  
*kubectl apply -k ./deploy/redis*  

## Init cluster with CertManager  
In the solutionfolder run following command:  
*kubectl apply -k ./deploy/certmanager*

## BuildVersions NET 7 Backend

## BuildVersions Angular 14 Frontend
nvm install 16.18.1  
nvm use 16.18.1  

ng generate component BuildVersions --module=app --skip-tests  
ng generate component BuildVersionEdit --flat --module=app --skip-tests  
ng generate service ApiService --flat --module=app --skip-tests  


## Init cluster with BuildVersions and its BuildVersionsApi  
In the solutionfolder run following command:  
*./InitBuild.ps1*  
Follow that command with:  
*./InitDeploy.ps1*  

# TODO!
Make FE, BFF and BE run in the same namespace of the cluster!  
Add to Dockerfile:  
RUN apt-get update -y
RUN apt-get install -y iputils-ping dnsutils
