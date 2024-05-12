#!/bin/bash

### This script is using for enumerating Public RDS Snapshots using account ID in all available regions.

# Colors Dictionary
RED='\033[0;31m'
RED_BLINK='\033[5;31m'
RED_BOLD='\033[1;31m'
GREEN='\033[1;32m'
GREEN_BLINK='\033[5;32m'
YELLOW='\033[0;33m'
YELLOW_BOLD='\033[1;33m'
CYAN='\033[1;36m'
WHITE_BOLD='\033[1;77m'
RESET='\033[0m'

# Specify the Account ID
echo -e -n "${GREEN_BLINK}[+] ${YELLOW_BOLD}Enter Account ID: ${RESET}"
read account_id

# Check if there are any active sessions
caller_identity=$(aws sts get-caller-identity)
if [ -z "$caller_identity" ]; then
    echo -e "${RED_BOLD}[!] Error: No Active Sessions!${RESET}"
else
	## Retrieving all the regions
	regions=()
	while IFS= read -r region; do
	    regions+=("$region")
	done < <(aws ec2 describe-regions --output text --query 'Regions[*].RegionName')

	## Searching Single RDS database instances
	echo -e "${GREEN}Single RDS DB Instances: ${RESET}"
	for region in ${regions[@]}; do 
		echo -e "${RED_BLINK}[+]${RESET} ${RED_BOLD}Region: ${RED}$region ${RESET}";
		aws rds describe-db-snapshots --snapshot-type public --include-public --region $region | grep $account_id; 
	done

	## Searching Cluster of RDS database instances
	echo -e "${GREEN}Cluster RDS DB Instances: ${RESET}"
	for region in ${regions[@]}; do 
		echo -e "${RED_BLINK}[+]${RESET} ${RED_BOLD}Region: ${RED}$region ${RESET}"; 
		aws rds describe-db-cluster-snapshots --snapshot-type public --include-public --region $region | grep $account_id; 
	done     
fi
