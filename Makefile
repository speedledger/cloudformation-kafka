ENVIRONMENT?=production
STACK_NAME:=$(ENVIRONMENT)-kafka
TEMPLATE_URL:=file://kafka.json

ZOOKEEPER_STACK_NAME:=$(ENVIRONMENT)-zookeeper

AWS_REGION?=eu-west-1
ADMIN_GROUP?=sg-b5a0aed2
KEY_NAME?=internal
SUBNETS?=subnet-c59b309d
VPC_ID?=vpc-461a9422
ZOOKEEPER_CLIENT_SECURITY_GROUP?=$(shell aws --region $(AWS_REGION) cloudformation describe-stacks --stack-name $(ZOOKEEPER_STACK_NAME) 2>/dev/null | jq -r '.Stacks[].Outputs | map(select(.OutputKey == "ClientSecurityGroup"))[].OutputValue')
EXHIBITOR_URL?=$(shell aws --region $(AWS_REGION) cloudformation describe-stacks --stack-name $(ZOOKEEPER_STACK_NAME) 2>/dev/null | jq -r '.Stacks[].Outputs | map(select(.OutputKey == "ExhibitorDiscoveryUrl"))[].OutputValue')


PARAMETERS:=ParameterKey=AdminSecurityGroup,ParameterValue=$(ADMIN_GROUP) \
            ParameterKey=ZookeeperClientSecurityGroup,ParameterValue=$(ZOOKEEPER_CLIENT_SECURITY_GROUP) \
            ParameterKey=KeyName,ParameterValue=$(KEY_NAME) \
            ParameterKey=Subnets,ParameterValue=$(SUBNETS) \
            ParameterKey=VpcId,ParameterValue=$(VPC_ID) \
            ParameterKey=ExhibitorLoadBalancer,ParameterValue=$(EXHIBITOR_URL)

create:
	@aws --region $(AWS_REGION) cloudformation describe-stacks --stack-name $(ENVIRONMENT)-zookeeper 2>/dev/null | jq -r '.Stacks[].StackStatus' | grep -q CREATE_COMPLETE || echo "The cfn-stack '$(ZOOKEEPER_STACK_NAME)' does not exist or isn't ready"
	aws --region $(AWS_REGION) cloudformation create-stack --stack-name $(STACK_NAME) --template-body $(TEMPLATE_URL) --parameters $(PARAMETERS)

destroy:
	aws --region $(AWS_REGION) cloudformation delete-stack --stack-name $(STACK_NAME)
