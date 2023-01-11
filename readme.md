# Kubernetes implemented through Docker, K3s and K3d
## Prerequisites
* Powershell 7, Net Core based, from a powershell prompt run, ***winget install --id Microsoft.Powershell --source winget***
* Chocolatey, install tool, ***iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))***  
* Docker Desktop for Windows, ***choco install docker-desktop***  
* ConEmu, command prompt utility, ***choco install conemu***
* Curl, http command line tool, ***choco install curl***  
* Kubernetes CLI, KubeCtl, ***choco install kubernetes-cli***  
* Kustomize CLI, ***choco install kustomize***  
* Kubernetes admin tool, K9s, ***choco install k9s***  
* K3d, tool to run K3s Kubernetes in Docker, ***choco install k3d***  

If you look at ***ContainerTools.ps1*** you will find an example of how to add all the tools using Chocolatey.  

## Setting up Docker  
Once you have installed Docker for Windows Desktop you should configure it to use Windows Subsystem for Linux (WSL).  

## Setting up Kubernetes  
We are going to use a lightweight version of Kubernetes (k8s) that is named k3s. This distribution was originally created by a company named Rancher but they decided to donate it to Cloud Native Computing Foundation (CNCF). CNCF have put k3s at sandbox level as First Kubernetes distribution. See more at: https://landscape.cncf.io and also https://github.com/k3s-io/k3s  

### K3s  
K3s is a very efficient and lightweight fully compliant Kubernetes distribution, it includes:

**Flannel**: a very simple L2 overlay network that satisfies the Kubernetes requirements. This is a CNI plugin (Container Network Interface), such as Calico, Romana, Weave-net.  
Flannel doesn’t support Kubernetes Network Policy, but it can be replaced by Calico if needed.

**CoreDNS**: a flexible, extensible DNS server that can serve as the Kubernetes cluster DNS

**Traefik**: a modern HTTP reverse proxy and load balancer.
Could easily be replace it either by Traefik v2 or Nginx

**Klipper Load Balancer**: Service load balancer that uses available host ports.

**SQLite3**: The storage backend used by default (also supports MySQL, Postgres, and etcd3)

**Containerd**: a runtime container like Docker without the image build part  

The choices of these components were made to have the most lightweight distribution. But since k3s is a modular distribution all the components can easily be replaced.  

### K3d  
K3d is a utility designed to easily run k3s in Docker, it provides a simple CLI to create, run, delete a fully compliance Kubernetes cluster with 1 to n servernodes. Using k3d we will get at least four containers running in Docker, on tools container that will be used by Docker and k3d to maintain everything, one registry container that will act as our storage for our own images for deploying them into the cluster, one loadbalancer that will act as a proxy between the servernodes and our local computer and finally a number of servernodes depending on how we installed it. You could skip the loadbalancer and registry and only run the servernode(s) and it's also possible to add something called agents for each node but we will settle with a basic setup for now.   

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

If we dissect this commandline, it will:
* Create a cluster named k3s (the final name will be k3d-k3s-server-n, where n is the number of each node)  
* Add a volume in the server node(s) under /tmp/shared and map it to our local disk C:\Data\k8s (this will act as our file share against the cluster). It is possible to map files this way if you have configuration files that you need to make available for the servernode(s).  
* Update the current kubeconfig stored under your local account and switch the active context to be our cluster. This means all CLI commands will be directed against our cluster). Latest news is that you shouldn't need to use these commandline parameters anymore, they will be by default.  
* Create a registry container in Docker where we can store all our images for later deployment in the cluster. (Registry v2 is a docker compliant storage like the Docker Hub)  
* Expose localhost port 8081 in the loadbalancer as the entrypoint for port 80, do the same with port 8443 as the entrypoint for port 443.  
* Expose localhost port 3333 in the loadbalancer and redirect it into the node to port 3306 (MySql default port), do the same with ports 4222 and 8222 (Nats JetStream default ports) and also port 6379 (Redis default port)  
* Define our api-port as 16443, this is the CLI api interface, used by all tools like kubectl and k9s.  
* Finally we just add a wait and a timeout for the command to be able to finish.  

Once we have executed this command we will have a Kubernetes cluster up and running!

If you run the command *docker ps* you will see that you now have three containers up and running...  

Let's explore the cluster a bit from Visual Studio, Docker Desktop and finally with k9s...  
In Visual Studio select View - Other Windows - Containers...  
Start Docker Desktop and open the tab Containers...  
Start k9s and if needed select the K3d-K3s cluster and type in :pods and then press 0 to show all pods in the cluster.  

### Database server    
In some of the examples we are using databases, for our purpose we will use MySql. How to deploy this will be showed further down in this document.  

### Event streaming server  
In some of the examples we are using event streaming, for our purpose we will use Nats. How to deploy this will be showed further down in this document.  

### Caching  
In some of the examples we are using caching, for our purpose we will use Redis. How to deploy this will be showed further down in this document.  

### Monitoring
In some of the examples we are using monitoring, for our purpose we will use a combination of Prometheus and Grafana, some use the ELK stack but this is a bit complicated to setup when you are new at Kubernetes.  

## Setup our hosts-file in localhost
To be able to use nameresolution for the different services/containers running inside the cluster we will use an old traditional way of accomplishing a simple nameresolution, by editing our hosts-file.  
Open notepad as administrator (neccessary to be allowed to save the hosts-file since it is considered to be a part of the operating system)
Open the file C:\Windows\System32\drivers\etc\hosts and add following lines:  

127.0.0.1 registry  
127.0.0.1 mysql  
127.0.0.1 mysql.local  
127.0.0.1 nats  
127.0.0.1 nats.local  
127.0.0.1 prometheus  
127.0.0.1 prometheus.local  
127.0.0.1 grafana  
127.0.0.1 grafana.local  
127.0.0.1 redis  
127.0.0.1 redis.local  

Save it and now you should, without any errors, be able to run the command:  
***curl.exe http://registry:5000/v2/_catalog***  
It should reply with the empty json:  
{"repositories":[]}  

## Setting up some base services in our cluster
To able to create some more advanced samples along the way we will add support for following services:  
* MySql, no need for presentation, lightweight sqlbased database server  
* Nats, this is a Kubernetes-compliant EventStreaming server that is capable of high performant, scalable, persistent streams.  
* Prometheus, this is a metrics scraper that is quite popular in Kubernetes, it will scrape all the containers for metrics data and store it for monitoring.  
* Grafana, this is the graphical presentationlayer for metrics and logs  
* Redis, dictionary based cache that is scalable and persistant  
* SealedSecrets, this is a cluster service that allows us to store secrets (connectionstrings etc) in the configuration  

### Init cluster with MySql  
Explore the content of subfolder deploy/mysql...  
To configure, in the solutionfolder run following command:  
*kubectl apply -k ./deploy/mysql*  

### Init cluster with Nats  
Explore the content of subfolder deploy/mysql...  
To configure, in the solutionfolder run following command:  
*kubectl apply -k ./deploy/nats*  

### Init cluster with Prometheus  
Explore the content of subfolder deploy/mysql...  
To configure, in the solutionfolder run following command:  
*kubectl apply -k ./deploy/prometheus*  

### Init cluster with Grafana  
Explore the content of subfolder deploy/mysql...  
To configure, in the solutionfolder run following command:  
*kubectl apply -k ./deploy/grafana*  

### Init cluster with Redis  
Explore the content of subfolder deploy/mysql...  
To configure, in the solutionfolder run following command:  
*kubectl apply -k ./deploy/redis*  

### Init cluster with SealedSecrets  
Explore the content of subfolder deploy/mysql...  
To configure, in the solutionfolder run following command:  
***kubectl apply -k ./deploy/sealedsecrets***  

### Init cluster with CertManager  
Explore the content of subfolder deploy/mysql...  
To configure, in the solutionfolder run following command:  
***kubectl apply -k ./deploy/certmanager***

## The magic Dockerfile
To be able to build images for our containers/pods we will use Docker CLI, there are some other tools available for this purpose but we will leave them for now.  

### Build an image
The Docker CLI contains the command ***docker build*** that allows us to build an image. We define how it should be built and what operatingsystem it should be based on and for that we use a *Dockerfile*. A simple *Dockerfile*, which is a plain textfile, could look like this:  

***FROM nginx:latest***

That's all! What we are saying is that we would like to create our own image based on the official nginx image from Docker Hub. As you can understand there's a lot more into it but that will be for the future...  

Now from the commandline inside the nginx-test folder run following command:  
***docker build -t mynginx .***  
Note! There's a dot on the end of the command and there need to be a space before that dot!  
This will create an image named (tagged) *mynginx* in our local image cache  

Verify that got the image by running the command:  
***docker images***  
you will se a list of all the images in your own local cache and you should be able to see the one you just built...  

### Run an image in Docker
You could try this image by running the command:  
***docker run --name mynginx1 -p 80:80 -d nginx***  

You should now be able to see it amongst the running containers in Docker by running the command:  
***docker ps***  

If you try to browse to:  
***http://localhost***  
you should end up with the basic page for an empty nginx webserver...  

Remove the container again by executing the command:  
***docker kill mynginx***  

### Deploy your image to the registry  
First we need to re-tag the image:  
***docker tag mynginx registry:5000/mynginx:latest***  

If you run  
***docker images***  
You will now see an image that is tagged with *registry:5000/mynginx:latest*  

Now to add it to our registry, all we need to do is to run the command:  
***docker push registry:5000/mynginx:latest***  

Verify the content of the registry by running the command:  
***curl.exe http://registry:5000/v2/_catalog***  
It should reply with the json:  
*{"repositories":["mynginx"]}*  

So, we now have our image as an useable image in the registry...  

### Deploy our image as a container/pod in Kubernetes
Final step to make our build and deploy complete is to use the newly created image and deploy it to Kubernetes.  
For that we need a namespace to put it in, a deployment to get it up and running, a service to expose it and a ingress to make it available from the outside of the cluster.  

Open up the file *nginx-test/nginx-test.yaml* and you will see the four configurations we need.  

To deploy this into Kubernetes we run the command:  
***kubectl apply -f nginx-test.yaml***

## Example 1: BuildVersions NET 7 Backend

## Example 2: BuildVersions Angular 14 Frontend
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
