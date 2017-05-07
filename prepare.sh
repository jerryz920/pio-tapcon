
docker cp /openstack/plain-train.txt.org pio:/pioapp/data
docker exec -it pio bash -c '
cd /pioapp/data;
pio app new classify --access-key randomkey; 
head -n 20000 plain-train.txt.org > data;
python import.py --access_key randomkey --file data;
cd ..;
pio build;
'

