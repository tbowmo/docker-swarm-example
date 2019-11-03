#!/bin/bash
echo Shutting down cluster for reboot!
STACKS=`docker stack ls --format "{{.Name}}"`
STACKS=($STACKS)
echo Shutting down stacks
for i in "${STACKS[@]}"
do
	docker stack rm $i
done
echo waiting for stacks to be shutdown
CONTAINERS=(`docker ps --format "{{.Image}}" | wc -l`)
while [ $CONTAINERS -gt 0 ]
do
	CONTAINERS=(`docker ps --format "{{.Image}}" |wc -l`)
done

echo Remove workers from swarm
for host in $SWARM_WORKERS; do
	echo "- $host leaving"
	ssh -t $host "docker swarm leave"
done
docker swarm leave -f

echo Ready for rebooting..
