TODO! Make sure all ingresses are flexible depending on target environment!  

Create two env variables:  
$env:kubeconfigx = "C:\Users\lennart\.kube\config.ubk3s"  
$env:kubeconfig = "C:\Users\lennart\.kube\config"  

Get the config file from the server:  

```scp -r lennart@192.168.1.254:/home/lennart/.kube/config $env:kubeconfigx```  

The other file will be created by K3d when you create the cluster.  

Run k9s and kubectl with the following commands:

```
k9s --kubeconfig $env:kubeconfigx
kubectl --kubeconfig $env:kubeconfigx
```

or

```
k9s --kubeconfig $env:kubeconfig
kubectl --kubeconfig $env:kubeconfig
```  


```k3d cluster create --servers 3 --agents 5 -p "80:80@loadbalancer" -p "443:443@loadbalancer" --volume '/tmp/data:/data@agent[*]'```  

```kubectl port-forward --address localhost,192.168.1.254 -n kube-system "$(kubectl get pods -n kube-system| grep '^traefik-' | awk '{print $1}')" 9000:9000```  