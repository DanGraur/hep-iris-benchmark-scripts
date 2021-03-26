#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

NUM_INSTANCES="${1:-1}"
INSTANCE_TYPE="${2:-m5d.xlarge}"

# Load common functions
. "$SCRIPT_PATH/../common/ec2-helpers.sh"

# Deploy cluster
experiments_dir="$SCRIPT_PATH/../experiments"
mkdir -p "$experiments_dir"
deploy_cluster "$experiments_dir" $NUM_INSTANCES $INSTANCE_TYPE

# Deploy software on machines
echo "Deploying software..."
for dnsname in ${dnsnames[*]}
do
    (
        (
            ssh -q ec2-user@$dnsname \
                docker pull masonproffitt/rdataframe-benchmarks:0.0
        ) &>> "$deploy_dir/deploy_$dnsname.log"
        echo "Done deploying $dnsname."
    ) &
done
wait
echo "Done deploying machines."
