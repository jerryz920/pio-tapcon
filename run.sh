#for n in `seq 1 20`; do /usr/bin/time --portability --append -o oldtime docker run -it --rm -p 3308:3307 -p 4050-4055:4040-4045 pio /opt/old.sh; done

IAAS_IP="152.3.145.38:5000"
for n in `seq 1 18`; do 
  msg=`curl http://compute5:7777/postInstanceSet -d "{ \"principal\": \"10.10.1.36:1985\",  \"otherValues\": [\"pio-container\", \"a7df7a6989b5101691f406608aff5b43c94fcf0eaff3c659dc323b43c83da079\", \"image\", \"10.10.1.36:80\", \"port=3308:4050-4055,cmd=/opt/all.sh\"] }"`
  echo $msg | tee key
  inst_id=`python id.py <key`
  curl http://compute5:7777/updateSubjectSet -d "{ \"principal\": \"10.10.1.36:80\",  \"otherValues\": [\"$inst_id\"] }"
  curl http://10.10.1.9:7777/postImageProperty -d "{ \"principal\": \"10.10.1.36:1985\", \"otherValues\": [\"a7df7a6989b5101691f406608aff5b43c94fcf0eaff3c659dc323b43c83da079\", \"https://github.com/jerryz920/predictionio\"] }"
  curl http://compute5:7777/postAttesterImage -d "{ \"principal\": \"10.10.1.36:1985\",  \"otherValues\": [\"a7df7a6989b5101691f406608aff5b43c94fcf0eaff3c659dc323b43c83da079\"]}"
  /usr/bin/time --portability --append -o newtime docker run -it --rm -p 3308:3307 -p 4050-4055:4040-4045 pio /opt/all.sh
done

