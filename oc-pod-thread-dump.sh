#!/bin/bash
set +e
POD="${1}"
DELAY="${2-15}"
TIMES="${3-5}"
if [[ -z "${POD}" ]]; then
	echo "missing pod name"
	exit
fi
CONTAINER=$(oc get pod $POD -o jsonpath='{.spec.containers[*].name}*'|cut -d ' ' -f 1)

oc logs $POD --container $CONTAINER --follow --since=1s |  csplit -k -f 'tdump' -z - '/Full thread dump/' '{*}' &
seq 1 $TIMES | xargs -I{} sh -c "oc exec $POD --container $CONTAINER -- kill -3 1  && sleep $DELAY"
kill %1
rm tdump00 -f
tar --remove-files -czvf thread-dump.tgz tdump* 
