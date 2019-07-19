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

## part 4: Swarms

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