ENVIRONMENT?=production
STACK_NAME:=$(ENVIRONMENT)-kafka2
TEMPLATE_URL:=file://kafka.json

ZOOKEEPER_STACK_NAME:=$(ENVIRONMENT)-zookeeper

AWS_REGION?=eu-west-1
ADMIN_GROUP?=sg-4b31cb2c
KEY_NAME?=test
SUBNETS?=subnet-2757437e
VPC_ID?=vpc-c0608ca4
ZOOKEEPER_CLIENT_SECURITY_GROUP?=$(shell aws --region $(AWS_REGION) cloudformation describe-stacks --stack-name $(ZOOKEEPER_STACK_NAME) 2>/dev/null | jq -r '.Stacks[].Outputs | map(select(.OutputKey == "ClientSecurityGroup"))[].OutputValue')
SYSDIG_ACCESS_KEY?=
INSTANCE_TYPE?=m4.large
AMI_ID=ami-97a2ebe4
TOPIC_REPLICATION_FACTOR=2

PARAMETERS:=ParameterKey=AdminSecurityGroup,ParameterValue=$(ADMIN_GROUP) \
            ParameterKey=ZookeeperClientSecurityGroup,ParameterValue=$(ZOOKEEPER_CLIENT_SECURITY_GROUP) \
            ParameterKey=KeyName,ParameterValue=$(KEY_NAME) \
						'ParameterKey=Subnets,ParameterValue="$(SUBNETS)"' \
            ParameterKey=VpcId,ParameterValue=$(VPC_ID) \
						ParameterKey=SysdigAgentAccessKey,ParameterValue=$(SYSDIG_ACCESS_KEY) \
						ParameterKey=Environment,ParameterValue=$(ENVIRONMENT) \
						ParameterKey=InstanceType,ParameterValue=$(INSTANCE_TYPE) \
						ParameterKey=AmiId,ParameterValue=$(AMI_ID) \
						ParameterKey=KafkaDefaultTopicReplicationFactor,ParameterValue=$(TOPIC_REPLICATION_FACTOR)

create:
	aws --region $(AWS_REGION) cloudformation describe-stacks --stack-name $(ENVIRONMENT)-zookeeper 2>/dev/null | jq -r '.Stacks[].StackStatus' | grep -q UPDATE_COMPLETE
	aws --region $(AWS_REGION) cloudformation create-stack --stack-name $(STACK_NAME) --template-body $(TEMPLATE_URL) --parameters $(PARAMETERS)

update:
	aws --region $(AWS_REGION) cloudformation update-stack --stack-name $(STACK_NAME) --template-body $(TEMPLATE_URL) --parameters $(PARAMETERS)

destroy:
	aws --region $(AWS_REGION) cloudformation delete-stack --stack-name $(STACK_NAME)

.PHONY: create update destroy
