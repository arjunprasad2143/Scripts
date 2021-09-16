#!/bin/bash
#set -xv
declare -a ETCDNODE
declare -a ETCDIP
oc project default
oc project openshift-etcd
i=0
while read -r line
do
        ETCDNODE[$i]=`echo $line | awk '{print $1}'`
        ETCDIP[$i]=`echo $line | awk '{print $6}'`
        i=$((i+1))
done < <(oc get pods -o wide | grep etcd-ocp)
if [[ ${#ETCDNODE[@]} -ne 3 ]]; then
   echo "More than  3 etcd nodes ... Exiting"
else
   echo "etcd nodes = ${ETCDNODE[@]}"
fi
for i in ${!ETCDNODE[@]}; do
  IS_LEADER=`oc rsh -c etcdctl ${ETCDNODE[0]} etcdctl endpoint status --cluster | grep ${ETCDIP[$i]} | awk -F ", " '{print $5}'`
  if [[ "$IS_LEADER" == "true" ]]; then
    echo  "${ETCDNODE[$i]} with ip ${ETCDIP[$i]} is leader"
    ETCD_LEADER=${ETCDNODE[$i]}
    continue
  fi
  echo "defragmenting ${ETCDNODE[$i]} with ip ${ETCDIP[$i]}"
  oc rsh ${ETCDNODE[$i]} bash -c 'unset ETCDCTL_ENDPOINTS;/usr/bin/etcdctl --command-timeout=30s --endpoints=https://localhost:2379 defrag'
  echo "Waiting etcd node to come back operationnal ..."
  sleep 90
done
echo "Defragmenting leader etcd node: $ETCD_LEADER"
oc rsh $ETCD_LEADER bash -c 'unset ETCDCTL_ENDPOINTS;/usr/bin/etcdctl --command-timeout=30s --endpoints=https://localhost:2379 defrag'
