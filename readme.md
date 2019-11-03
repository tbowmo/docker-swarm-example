Misc automation stacks and scripts
===

This is an example of my docker-swarm setup, currently having 2 x86_64 nodes

configuration parameters is set in an .env file (copy .env-dist and edit to your likings)

docker bind mounts
---
Most containers are using bind mounts for configuration files etc, and are using `/docker/<container>` directory, I created a glusterfs setup, so /docker/ is replicated accross all hosts in in my swarm setup. This makes it possible for most containers to freely roam the nodes in my swarm.

pinned containers
---
A couple of containers have been pinned to a specific host, as it has more storage available, and instead of making a nfs share, I found it easier to just always deploy the containers to the same node.

Network setup
---
