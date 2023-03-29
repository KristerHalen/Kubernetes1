#Build part, this generates an image in our registry that we could use in Kubernetes
docker build -t mynginx .

if(hostname -eq "ubk3s")
{
	$extName = ".ubk3s"
	$currentContext = $env:XKUBECONFIG
}
else
{
	$extName = ""
	$currentContext = $env:KUBECONFIG
}

docker tag mynginx registry${extName}:5000/mynginx:latest
docker push registry${extName}:5000/mynginx:latest

curl.exe http://registry${extName}:5000/v2/_catalog

#Deploy part, this configures Kubernetes to pull the image from our repository and make sure it is running:
kubectl --kubeconfig=$currentContext apply -f nginx-test${extName}.yaml
