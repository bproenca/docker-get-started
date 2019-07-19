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