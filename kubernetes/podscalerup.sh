for pods in `cat /tmp/deploy.list`
do
        kubectl scale --replicas=1 $pods
done