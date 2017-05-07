docker build -t pio .
id=`docker inspect -f '{{.ID}}' pio`
docker run -it --rm -e DOCKER_IMAGE=$id -p 3307:3307 -p 7070:7070 -p 4040-4045:4040-4045 --name pio pio

