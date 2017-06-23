!/bin/bash
in_d=`date --date="8 days ago" +"%Y.%m.%d"`
today_dt=`date +"%Y.%m.%d"`

curl_delete_index="curl -XDELETE '<domain name with indices>-"$in_d\'
curl_set_replica="curl -XPUT '<domain name with indices>-"$today_dt"/_settings' -d '{\"index\" : { \"number_of_replicas\" : 0 }}'"
eval $curl_delete_index
eval $curl_set_replica

echo "Done !"
