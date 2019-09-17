#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

LABELS=${LABELS:-LifeCycle=OnDemand}
TAINTS=${TAINTS:-}

SPOT_LABELS=${SPOT_LABELS:-LifeCycle=Ec2Spot}
SPOT_TAINTS=${SPOT_TAINTS:-spotInstance=true:PreferNoSchedule}

run () {
  echo "Running labeller..."
  region=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed -e "s/.$//")
  localHostname=$(curl -s http://169.254.169.254/latest/meta-data/local-hostname)
  iid=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

  ilc=`aws ec2 describe-instances --region ${region} --instance-ids ${iid} --query 'Reservations[0].Instances[0].InstanceLifecycle' --output text`
  
  if [ "${ilc}" == "spot" ]; then
    for l in ${SPOT_LABELS}; do
      kubectl label nodes "${localHostname}" $l
    done

    for t in ${SPOT_TAINTS}; do
      kubectl taint nodes "${localHostname}" $t
    done
  else
    for l in ${LABELS}; do
      kubectl label nodes "${localHostname}" $l
    done

    for t in ${TAINTS}; do
      kubectl taint nodes "${localHostname}" $t
    done
  fi
}

while true; do
  run
  sleep 60
done
