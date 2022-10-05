kubectl create serviceaccount skooner-sa -n kube-system
kubectl create clusterrolebinding skooner-sa --clusterrole=cluster-admin --serviceaccount=kube-system:skooner-sa
kubectl get secrets -n kube-system
