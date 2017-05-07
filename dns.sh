
for n in 1 2 3  4 5; do

  eval $(docker-machine env v$n)
  id=`docker ps | grep spark | awk '{print $1}'`

   docker exec -it $id bash -c "
   	echo 10.10.1.46 predictionio >> /etc/hosts;
	echo 10.10.1.41 hdfs-1 hdfs-1-bind >> /etc/hosts
	echo 10.10.1.42 hdfs-2 >> /etc/hosts
	echo 10.10.1.43 hdfs-3 >> /etc/hosts
	echo 10.10.1.44 hdfs-4 >> /etc/hosts
	"

      docker exec -it $id cat /etc/hosts
  

done
