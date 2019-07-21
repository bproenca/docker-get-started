Tutorial:  
https://docs.docker.com/get-started/part2/

Build:  
`docker build --tag=bproenca/get-started:part2 .`

Run:  
`docker run -p 4000:80 bproenca/get-started:part2`

Test:  
`curl http://localhost:4000`

Publish (need login):  
`docker push bproenca/get-started:part2`

Docker Hub:  
https://cloud.docker.com/repository/docker/bproenca/get-started


## Part 3: Services

Before we can use the docker stack deploy command we first run:  
`docker swarm init`

Now let’s run it. You need to give your app a name. Here, it is set to getstartedlab:  
`docker stack deploy -c docker-compose.yml getstartedlab`

Get the service ID for the one service in our application:  
`docker service ls`  (or)
`docker stack services getstartedlab`

A single container running in a service is called a task. List the tasks for your service:  
`docker service ps getstartedlab_web`

Run this command a few times to check the container ID changes:  
`curl -4 http://localhost:4000`  
... demonstrating the load-balancing; with each request, one of the 5 tasks is chosen, in a round-robin fashion, to respond.

To view all tasks of a stack:  
`docker stack ps getstartedlab`

You can scale the app by changing the replicas value in docker-compose.yml, saving the change, and re-running the docker stack deploy command:  
`docker stack deploy -c docker-compose.yml getstartedlab`

Take down the app and the swarm:  
`docker stack rm getstartedlab`  
`docker swarm leave --force`

## Part 4: Swarms

*A swarm is a group of machines that are running Docker and joined into a cluster.*

Create a couple of VMs using docker-machine, using the VirtualBox driver:  
`docker-machine create --driver virtualbox myvm1`  
`docker-machine create --driver virtualbox myvm2`

Use this command to list the machines and get their IP addresses.  
`docker-machine ls`

The first machine acts as the manager, which executes management commands and authenticates workers to join the swarm, and the second is a worker.  
`docker-machine ssh myvm1 "docker swarm init --advertise-addr <myvm1 ip>"`

To add a worker to this swarm, run the following command:

```  
  docker-machine ssh myvm2 "docker swarm join \
  --token <token> \
  <ip>:2377"
```

Run docker node ls on the manager to view the nodes in this swarm:  
`docker-machine ssh myvm1 "docker node ls"`

Configure your shell to talk to myvm1:  
`docker-machine env myvm1`  
`eval $(docker-machine env myvm1)`

Deploy the app on the swarm manager (on node manager myvm1 - previous command):  
`docker stack deploy -c docker-compose.yml getstartedlab`

You can access your app from the IP address of either myvm1 or myvm2.

Cleanup and reboot:  
`docker stack rm getstartedlab`  
`docker-machine ssh myvm2 "docker swarm leave"`  
`docker-machine ssh myvm1 "docker swarm leave --force"`

Unsetting docker-machine shell variable settings:  
`eval $(docker-machine env -u)`

## Part 5: Stacks

*A stack is a group of interrelated services that share dependencies, and can be orchestrated and scaled together.*

There are a couple of things in the redis specification that make data persist between deployments of this stack:  

* redis always runs on the manager, so it’s always using the same filesystem.
* redis accesses an arbitrary directory in the host’s file system as /data inside the container, which is where Redis stores data.


Together, this is creating a “source of truth” in your host’s physical filesystem for the Redis data. Without this, Redis would store its data in /data inside the container’s filesystem, which would get wiped out if that container were ever redeployed.

This source of truth has two components:  

* The placement constraint you put on the Redis service, ensuring that it always uses the same host.
* The volume you created that lets the container access ./data (on the host) as /data (inside the Redis container). While containers come and go, the files stored on ./data on the specified host persists, enabling continuity.

Create a ./data directory on the manager:  

`docker-machine ssh myvm1 "mkdir ./data"`

## Part 6: Deploy

### Deploy

* `docker-machine start myvm1`
* `docker-machine start myvm2`
* `docker-machine ssh myvm1 "docker swarm init --advertise-addr <ip-vm1>"`
* `docker-machine ssh myvm2 "docker swarm join --token <token> <ip-vm1>:2377"`
* `docker-machine ssh myvm1 "mkdir ./data"`
* `eval $(docker-machine env myvm1)`
* `docker stack deploy -c docker-compose.yml getstartedlab  `

Test **redis** data persist between deployments of this stack:  
`docker stack rm getstartedlab`  
`docker stack deploy -c docker-compose.yml getstartedlab`

### Undeploy

* `docker stack rm getstartedlab`
* `docker-machine ssh myvm2 "docker swarm leave"`
* `docker-machine ssh myvm1 "docker swarm leave --force"`
* `eval $(docker-machine env -u)`
* `docker-machine stop myvm2`
* `docker-machine stop myvm1`