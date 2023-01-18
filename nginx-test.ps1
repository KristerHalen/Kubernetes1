#Build part, this generates an image in our registry that we could use in Kubernetes
docker build -t mynginx .
docker tag mynginx registry:5000/mynginx:latest
docker push registry:5000/mynginx:latest

curl.exe http://registry:5000/v2/_catalog

#Deploy part, this configures Kubernetes to pull the image from our repository and make sure it is running:
kubectl apply -f nginx-test.yaml