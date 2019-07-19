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
