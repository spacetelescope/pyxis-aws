#!/bin/bash
# paste the AWS acct ID
AWSACCOUNTID=
# can change this to whatever name you give the repo you created in ECR
export IMAGENAME="rkein-pixel"
export IMAGETAG="prep"

#########################################
# don't change anything below this line #
#########################################
export REPO_URI=${AWSACCOUNTID}.dkr.ecr.us-east-1.amazonaws.com
export DOCKERIMAGE=$REPO_URI/$IMAGENAME:$IMAGETAG
echo $REPO_URI
echo $DOCKERIMAGE
