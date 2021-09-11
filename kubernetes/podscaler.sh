for pods in `cat /tmp/deploy.list`
do
	kubectl scale --replicas=0 $pods
done
