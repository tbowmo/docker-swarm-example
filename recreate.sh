#!/bin/bash
IFS='
'
export $(grep -v '^#' .env | xargs -0)
IFS=' '

echo - Initializing standard swarm setup for home automation
docker swarm init
TOKEN=`docker swarm join-token worker -q`

for host in $SWARM_WORKERS; do
	echo "Joining $host as a worker"
	ssh -t $host "docker swarm join --token $TOKEN 192.168.1.64:2377"
done

echo - Creating swarm overlay networks
for network in traefik-public mqtt grafing; do
	echo "creating network $network"
	docker network create --driver=overlay --attachable $network
done

docker network create -d macvlan --scope swarm --config-from vlan1_conf swarm-macvlan1
#docker network create -d macvlan --scope swarm --config-from vlan30_conf swarm-macvlan30
#docker network create -d macvlan --scope swarm --config-from vlan40_conf swarm-macvlan40

echo - Setting node labels

var="${!LABEL*}"

regex='LABEL_[0-9]*_([a-z|A-Z|0-9]*)'
for e in $var; do
    [[ "$e" =~ $regex ]]
	host="${BASH_REMATCH[1]}"
	label=${!e}
	echo "Setting '$label' for '$host'"
	docker node update --label-add $label $host >/dev/null
done

echo - starting registry and traefik before all other stacks
docker stack deploy -c registry.yml registry
docker stack deploy -c traefik.yml traefik

echo sleeping 5s before continuing
sleep 5s

echo Now start the rest of the stacks in this directory

for f in *.yml
do
	base=$(basename $f)
	stack="${base%.*}"
	if  [ "$stack" != "registry" ] && [ "$stack" != "traefik" ]
	then
		echo $stack
		docker stack deploy -c $f $stack
	fi	
done
