

SPARK_PUBLIC_DNS=predictionio SPARK_LOCAL_IP=predictionio pio train -- --master=spark://10.10.1.53:7077 --conf spark.driver.host=predictionio
