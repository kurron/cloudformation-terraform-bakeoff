#!/usr/bin/env bash

# updates a stack in AWS via CloudFromation

STACK_ARN=${1:-arn:aws:cloudformation:us-east-2:387188308760:stack/ECS-Service/832cd870-73d6-11e8-8ebc-50faf8bc7cfe}
CHANGE_SET_NAME=${2:-Scale-Up}
DESIRED_COUNT=${3:-3}

# aws cloudformation create-change-set --stack-name arn:aws:cloudformation:us-east-1:123456789012:stack/SampleStack/1a2345b6-0000-00a0-a123-00abc0abc000 --change-set-name SampleChangeSet --use-previous-template --parameters ParameterKey="InstanceType",UsePreviousValue=true ParameterKey="KeyPairName",UsePreviousValue=true ParameterKey="Purpose",ParameterValue="production" 

CREATE="aws cloudformation create-change-set --stack-name $STACK_ARN \
	                                     --change-set-name $CHANGE_SET_NAME \
                                             --use-previous-template \
					     --parameters ParameterKey=DesiredCount,ParameterValue=$DESIRED_COUNT \
					                  ParameterKey=Project,UsePreviousValue=true \
					                  ParameterKey=Creator,UsePreviousValue=true \
					                  ParameterKey=Environment,UsePreviousValue=true \
					                  ParameterKey=Notes,UsePreviousValue=true \
					                  ParameterKey=VPC,UsePreviousValue=true \
					                  ParameterKey=Cluster,UsePreviousValue=true \
					                  ParameterKey=Listener,UsePreviousValue=true \
					                  ParameterKey=Path,UsePreviousValue=true \
					                  ParameterKey=HealthCheckPath,UsePreviousValue=true \
					                  ParameterKey=HealthCheckProtocol,UsePreviousValue=true \
					                  ParameterKey=LoadBalancerProtocol,UsePreviousValue=true \
					                  ParameterKey=LoadBalancerPort,UsePreviousValue=true \
					                  ParameterKey=ListenerPriority,UsePreviousValue=true \
					                  ParameterKey=DockerImage,UsePreviousValue=true \
					                  ParameterKey=ContainerPort,UsePreviousValue=true \
					                  ParameterKey=ContainerMemory,UsePreviousValue=true \
					                  ParameterKey=ContainerName,UsePreviousValue=true \
					                  ParameterKey=ServiceFamily,UsePreviousValue=true \
					                  ParameterKey=LogGroup,UsePreviousValue=true"

echo $CREATE
$CREATE

VIEW="aws cloudformation list-change-sets --stack-name $STACK_ARN"
echo $VIEW
$VIEW

EXECUTE="aws cloudformation execute-change-set --stack-name $STACK_ARN --change-set-name $CHANGE_SET_NAME"
echo $EXECUTE
$EXECUTE

