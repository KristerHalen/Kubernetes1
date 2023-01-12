# Kubernetes implemented through Docker, K3s and K3d
Kubernetes, or as it written, K8s, is simply a container orchestration framework. What this essentially means is that K8s is a system designed to automate the lifecycle of containerized applications — from predictability, scalability to availability.  

## Why do we even need Kubernetes?  
The driving reason behind the rise and need for K8s stems from the increasing use of microservices, away from traditional monolithic-type applications towards a mindset about "single responsibility". As a result, containers provide the perfect host for these individual microservices as containers manage dependencies, are independent, OS-agnostic and ephemeral, amongst other benefits.  

Complex applications that have many components written accordingly to "single responsibilty" are often made up of hundreds or even thousands of microservices. Scaling these microservices up while ensuring availability is an extremely painful process if we were to manage all these different components using custom-written programs or scripts, resulting in the demand for a proper way of managing these components.  

## Benefits of Kubernetes
Kubernetes promises to solve the above problem using these following features:

* ***High Availability*** — this simply means that your application will always be up and running, whether you have a new update to roll-out or have some unexpected pods crashing.  
* ***Scalability*** — this ensures high performance of your application, whether you have a single user or a thousand users flooding your application concurrently.  
* ***Disaster Recovery*** — this ensures that your application will always have the latest data and states of your application if something unfortunate happens to your physical or cloud-based infrastructure.  

## A simple view of it
![K8ssimple](k8ssimple.png)

## Hardware requirements for this demo/exercise
* PC with Windows 10
* Hardware Virtualization activated in the BIOS
* Windows Subsystem for Linux (WSL) activated (Use Ubuntu => 20.04 it is easy to work with)
* Intel i7
* At least 16 gb memory
* Some 100+ mb SDD 
  
## Prerequisites for this demo/exercise
All commandlines are based on Powershell, we will update Powershell to a newer Core based Powershell 7.  

* ***Powershell 7***, Net Core based, from a powershell prompt run:  
```powershell
winget install --id Microsoft.Powershell --source winget
```
* ***Chocolatey***, install tool, from a powershell prompt run:  
```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```  
* ***Docker Desktop for Windows*** Container virtualiztion, from a powershell prompt run:  
```powershell
choco install docker-desktop
```  
* ***ConEmu***, commandline emulator that integrates well with Powershell, from a powershell prompt run:  
```powershell
choco install conemu
```
* ***Curl***, http command line tool, from a powershell prompt run:  
```powershell
choco install curl
```  
* ***K8s CLI***, KubeCtl CLI for K8s, from a powershell prompt run:  
```powershell
choco install kubernetes-cli
```  
* ***Kustomize CLI***, Customization addon for kubectl, from a powershell prompt run:  
```powershell
choco install kustomize
```  
* ***K9s***, K8s admin tool, from a powershell prompt run:  
```powershell
choco install k9s
```  
* ***K3d***, tool to create and run K3s in Docker, from a powershell prompt run:  
```powershell
choco install k3d
```  

If you look at ***ContainerTools.ps1*** in this solution you will find an example of how to add all the tools using Chocolatey.  

## Setting up Docker  
Once you have installed Docker for Windows Desktop you should configure it to use Windows Subsystem for Linux (WSL).  

## Setting up K8s  
We are going to use a lightweight version of K8s that is named K3s. This distribution was originally created by a company named Rancher but they decided to donate it to Cloud Native Computing Foundation (CNCF). CNCF have put K3s at sandbox level as "First Kubernetes" distribution. See more at: ***https://landscape.cncf.io***  

Everywhere in this document when we refer to K8s or K3s we are talking about our K3s-based K8s.

### K3s  
URL: ***https://github.com/k3s-io/k3s*** and ***https://docs.k3s.io/***

K3s is a very efficient and lightweight fully K8s compliant distribution, it includes:

***Flannel***: a very simple L2 overlay network that satisfies the K8s requirements. This is a CNI plugin (Container Network Interface), such as Calico, Romana, Weave-net.  
Flannel doesn’t support K8s Network Policy, but it can be replaced by Calico if needed.

***CoreDNS***: a flexible, extensible DNS server that can serve as the K8s cluster DNS

***Traefik***: a modern HTTP reverse proxy and load balancer.
Could easily be replace it either by Traefik v2 or Nginx

***Klipper Load Balancer***: Service load balancer that uses available host ports.

***SQLite3***: The storage backend used by default (also supports MySQL, Postgres, and etcd3)

***Containerd***: a runtime container like Docker without the image build part  

The choices of these components were made to have the most lightweight distribution. But since K3s is a modular distribution all the components can easily be replaced.  
A typical layout of a K3s cluster could look like this:  
![K3d K3s](K3d-K3s.png)  
But if you would like a more complex solution it could look a bit more like this:
![K3d K3s with agents](K3d-K3sWithAgents.png)  

### K3d  
Url: ***https://github.com/k3d-io/k3d*** and ***https://k3d.io/***  

K3d is a utility designed to easily run K3s hosted in Docker, it provides a simple CLI to create, run, delete a fully compliant K8s cluster with 1 to n servernodes.  
Using K3d we will get at least four containers running in Docker, one tools container that will be used by Docker and K3d to maintain everything, one registry container that will act as a storage for our own images that we would like to deploy to the cluster, one loadbalancer that will act as a proxy between the servernode(s) and our local computer and finally a number of servernodes depending on how we installed it.  
You could skip the loadbalancer and also the registry and only run the servernode(s) and it's also possible to add something called agents (also called worker-nodes) for each node but we will settle with a basic setup for now.   


To set up K8s inside Docker we will use the command line tool named K3d. The command for creating a cluster is:  
```powershell
k3d cluster create clustername
```  
See more: ***https://k3d.io/v5.4.6/usage/commands/k3d_cluster_create/***  

And if we would like to delete the cluster simply run:  
```powershell
k3d cluster delete clustername
```  
See more: ***https://k3d.io/v5.4.6/usage/commands/k3d_cluster_delete/***  

It is also possible to start, stop and edit the cluster with this command...  

The command we will issue in this demo is:  
```powershell
k3d cluster create k3s --volume C:\Data\K8s:/tmp/shared@server:0 --kubeconfig-update-default --kubeconfig-switch-context --registry-create registry:5000 -p 8081:80@loadbalancer -p 8443:443@loadbalancer -p 3333:3306@server:0 -p 4222:4222@server:0 -p 8222:8222@server:0 -p 6379:6379@server:0 --api-port=16443 --wait --timeout=60s
```  

If we dissect this commandline, it will do following:
* Create a cluster named K3s (the final name of the nodes will be k3d-k3s-server-n, where n is the number of each node)  
* Add a volume in the server node(s) under /tmp/shared and map it to our local disk C:\Data\k8s (this will act as our file share against the cluster). It is possible to map files this way if you have configuration files that you need to make available for the servernode(s).  
* Update the current kubeconfig stored under your local account and switch the active context to be our cluster. This means all CLI commands will be directed against our cluster). Latest news is that you shouldn't need to use these commandline parameters anymore, they will be by default.  
* Create a registry container in Docker where we can store all our images for later deployment in the cluster. (Registry v2 is a docker compliant storage like the Docker Hub)  
* Expose localhost port 8081 in the loadbalancer as the entrypoint to the ingress for port 80  
* Expose localhost port 8443 as the entrypoint to the ingress for port 443.  
* Expose localhost port 3333 in the loadbalancer and redirect it into the cluster to port 3306 (MySql default port)  
* Expose localhost ports 4222 and 8222 (Nats JetStream default ports) and redirect it into the cluster  
* Expose localhost port 6379 (Redis default port) and redirect it into the cluster  
* Define our api-port as 16443, this is the CLI api interface used by all tools like kubectl and k9s (internally in the nodes it will be ported to 6443).  
* Finally we just add a wait and a timeout for the command to be able to finish.  

Once we have executed this command we will have a K8s cluster up and running!

If you run the command  
```powershell
docker ps
```  
you will see that you now have atleast three containers up and running...  

Let's explore the cluster a bit from Visual Studio, Docker Desktop and finally with k9s [demo]...  
In Visual Studio select View - Other Windows - Containers [demo]...  
Start Docker Desktop and open the tab Containers [demo]...  
Start k9s and if needed select the newly created cluster and type in ***:pods*** and then press ***0*** to show all pods in the cluster. [demo]  

## Setup our hosts-file in localhost
To be able to use nameresolution for the different services/containers running inside the cluster we will use an old traditional way of accomplishing a simple nameresolution, by editing our hosts-file.  
Open notepad as administrator (neccessary to be allowed to save the hosts-file since it is considered to be a part of the operating system)
Open the file ***C:\Windows\System32\drivers\etc\hosts*** and add following lines (you will understand later what the different names are for):  

```text
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
```  

Save it and now you should, without any errors, be able to run the command:  
***curl.exe http://registry:5000/v2/_catalog***  
It should reply with the empty json:  
```json
{"repositories":[]}  
```

## Setting up some base services in our cluster
### Database server    
In some of the examples we are using databases, we will use MySql for this purpose. In our solution you will find configurations under deploy/mysql.  

### Event streaming server  
In some of the examples we are using event streaming, we will use Nats for this purpose. In our solution you will find configurations under deploy/nats.  

### Caching  
In some of the examples we are using caching, we will use Redis for this purpose. In our solution you will find configurations under deploy/redis.  

### Monitoring
In some of the examples we are using monitoring, we will use a combination of Prometheus and Grafana for this purpose. In our solution you will find configurations under deploy/prometheus and deploy/grafana.  

To able to create some more advanced samples along the way we will add support for following services:  
* ***MySql***, no need for presentation, lightweight sqlbased database server well suited to use in a cluster.  
* ***Nats***, this is a K8s-compliant EventStreaming server that is capable of high performant, scalable, persistent streams.  
* ***Prometheus***, this is a metrics scraper that is quite popular in K8s, it will scrape (ask) all the containers for metrics data and store it for monitoring.  
* ***Grafana***, this is the graphical presentationlayer for metrics and logs.  
* ***Redis***, dictionary based cache that is scalable and persistant.  
* ***SealedSecrets***, this is a cluster service that allows us to store encrypted secrets (connectionstrings etc) in the configuration.  

### Init cluster with MySql  
Explore the content of subfolder deploy/mysql...  
To configure MySql, in the solutionfolder run following command:  
```powershell
kubectl apply -k ./deploy/mysql
```

### Init cluster with Nats  
Explore the content of subfolder deploy/nats...  
To configure Nats, in the solutionfolder run following command:  
```powershell
kubectl apply -k ./deploy/nats
```  

### Init cluster with Prometheus  
Explore the content of subfolder deploy/prometheus...  
To configure Prometheus, in the solutionfolder run following command:  
```powershell
kubectl apply -k ./deploy/prometheus
```  

### Init cluster with Grafana  
Explore the content of subfolder deploy/grafana...  
To configure Grafana, in the solutionfolder run following command:  
```powershell
kubectl apply -k ./deploy/grafana
```

### Init cluster with Redis  
Explore the content of subfolder deploy/redis...  
To configure Redis, in the solutionfolder run following command:  
```powershell
kubectl apply -k ./deploy/redis
```

### Init cluster with SealedSecrets  
Explore the content of subfolder deploy/sealedsecrets...  
To configure SealedSecrets, in the solutionfolder run following command:  
```powershell
kubectl apply -k ./deploy/sealedsecrets
```

## The magic Dockerfile
To be able to build images for our containers/pods we will use Docker CLI, there are some other tools available for this purpose but we will leave them for now.  

### Build an image
The Docker CLI includes the commands ***docker build***, ***docker tag*** and ***docker push*** that allows us to build, tag and deploy an image. We define how it should be built and what operatingsystem it should be based on and for that we use a ***Dockerfile***. A simple ***Dockerfile***, which is a plain textfile, could look like this:  

```docker
FROM nginx:latest
```

That's all! What we are defining in this file is that we would like to create our own image based on the official nginx image from Docker Hub. As you can understand there's a lot more into it but that will be explored further later on...  

Now from the commandline inside the ***./nginx-test*** folder run following command:  
```powershell
docker build -t mynginx .
```
Note! There's a dot on the end of the commandline and there need to be a space before that dot! It states that "look for a Dockerfile inside current folder"  
The command will create an image named and tagged ***mynginx:latest*** in our local image cache. The tag latest means that it doesn't have a particular version other than just latest.  

Verify that you got the image by running the command:  
```powershell
docker images
```
You will se a list of all the images in your own local cache and you should be able to see the one you just built... The local cache means that it is available for Docker to use.  

### Run an image in Docker
You could try this image by running the command:  
```powershell
docker run --name mynginx1 -p 80:80 -d nginx
```

You should now be able to see it amongst the running containers in Docker by running the command:  
```powershell
docker ps
```

If you try to run curl against it (or browse to it):  
```powershell
curl.exe http://localhost
-OR-
Start-Process http://localhost
```
You should end up with the content of the default start page for an empty nginx webserver...  

Remove the container again by executing the command:  
```powershell
docker kill mynginx
```

### Deploy your image to the registry  
First, to be able to redirect our image, we need to re-tag it:  
```powershell
docker tag mynginx registry:5000/mynginx:latest
```

If you run  
```powershell
docker images
```  
You will now see an image that is tagged with "registry:5000/mynginx:latest"  

Now to add it to our registry at http://registry:5000, all we need to do is to run the command:  
```powershell
docker push registry:5000/mynginx:latest
```
So the target address for pushing is always the image name

Verify the content of the registry by running the command:  
```powershell
curl.exe http://registry:5000/v2/_catalog
```
It should reply with the json:  
```json
{"repositories":["mynginx"]}
```

So, we now have our image as an artifact in the registry...  

### Deploy our image as a container/pod in K8s
Final step to make our build and deploy complete is to use the newly created image and deploy it to K8s.  
For that we need a *namespace* to put it in, a *deployment* to get it up and running, a *service* to expose it and an *ingress* to make it available from the outside of the cluster.  

Open up the file ***./nginx-test/nginx-test.yaml*** in the solution and you will see the four configurations we need.  

To deploy this into K8s we run the command:  
```powershell
kubectl apply -f nginx-test.yaml
```
