#!/bin/bash

# Replace with your VPC ID
VPC_ID="vpc-0e7bdd381b93e3b8c"

echo "Checking dependencies for VPC: $VPC_ID"
echo "---------------------------------------------"

# Get Subnets
echo "Subnets:"
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[*].{ID:SubnetId, CIDR:CidrBlock}" --output table

# Get Route Tables
echo -e "\nRoute Tables:"
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --query "RouteTables[*].{ID:RouteTableId, Main:Main}" --output table

# Get Security Groups
echo -e "\nSecurity Groups:"
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --query "SecurityGroups[*].{ID:GroupId, Name:GroupName}" --output table

# Get Network ACLs
echo -e "\nNetwork ACLs:"
aws ec2 describe-network-acls --filters "Name=vpc-id,Values=$VPC_ID" --query "NetworkAcls[*].{ID:NetworkAclId}" --output table

# Get Internet Gateways
echo -e "\nInternet Gateways:"
aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query "InternetGateways[*].{ID:InternetGatewayId}" --output table

# Get NAT Gateways
echo -e "\nNAT Gateways:"
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID" --query "NatGateways[*].{ID:NatGatewayId}" --output table

# Get VPC Peering Connections
echo -e "\nVPC Peering Connections:"
aws ec2 describe-vpc-peering-connections --filters "Name=requester-vpc-info.vpc-id,Values=$VPC_ID" "Name=accepter-vpc-info.vpc-id,Values=$VPC_ID" --query "VpcPeeringConnections[*].{ID:VpcPeeringConnectionId}" --output table

# Get VPN Connections
echo -e "\nVPN Connections:"
aws ec2 describe-vpn-connections --filters "Name=vpc-id,Values=$VPC_ID" --query "VpnConnections[*].{ID:VpnConnectionId}" --output table

echo "---------------------------------------------"
echo "Dependency check completed."
