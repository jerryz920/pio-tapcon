

#SPARK_PUBLIC_DNS=predictionio SPARK_LOCAL_IP=predictionio pio train -- --master=spark://10.10.1.53:7077 --conf spark.driver.host=predictionio


docker exec -e SPARK_PUBLIC_DNS=predictionio -e SPARK_LOCAL_IP=predictionio -it pio bash -c "cd /pioapp; pio train -- --master=spark://10.10.1.36:7077 --conf spark.driver.host=predictionio --conf spark.ui.port=4040 --conf spark.driver.blockManager.port=4041 --conf spark.driver.port=4042"
