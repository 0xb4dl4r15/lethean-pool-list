#!/usr/bin/env sh

PKG_VERSION=`grep "\"version\" *: *\".*\" *," package.json | sed "s/\"version\" *: *\"//i;s/\" *,//i;s/ //g;"`
CURRENCY=$1
GITHUB_CLIENT_ID=$2
GITHUB_CLIENT_SECRET=$3

#ssh -oStrictHostKeyChecking=no ${SSH_USER}@${SSH_HOST} "PKG_VERSION=$PKG_VERSION CURRENCY=$CURRENCY GITHUB_CLIENT_ID=$GITHUB_CLIENT_ID GITHUB_CLIENT_SECRET=$GITHUB_CLIENT_SECRET bash -s" << 'EOF'

IMAGE_NAME="letheanmovement/lethean-pool-list:$PKG_VERSION"
CONTAINER_NAME="$CURRENCY-pool-list"
VIRTUAL_HOST="pools.lethean.io,$CURRENCY-pools.containers"
VIRTUAL_PORT=80
LETSENCRYPT_HOST="pools.lethean.io"
LETSENCRYPT_EMAIL="valiant@lethean.io"
BASE_URL="https://$LETSENCRYPT_HOST"

echo "deploying $CONTAINER_NAME"
echo "IMAGE_NAME: $IMAGE_NAME"
echo "PKG_VERSION: $PKG_VERSION"
echo "CONTAINER_NAME: $CONTAINER_NAME"
echo "CURRENCY: $CURRENCY"
echo "GITHUB_CLIENT_ID: $GITHUB_CLIENT_ID"
echo "VIRTUAL_HOST: $VIRTUAL_HOST"
echo "VIRTUAL_PORT: $VIRTUAL_PORT"
echo "LETSENCRYPT_HOST: $LETSENCRYPT_HOST"
echo "LETSENCRYPT_EMAIL: $LETSENCRYPT_EMAIL"

docker pull ${IMAGE_NAME}
docker rm -f ${CONTAINER_NAME}
docker run -d --network=containers --restart always --name ${CONTAINER_NAME} \
    -e CURRENCY=${CURRENCY} \
    -e ENV_NAME=${CONTAINER_NAME} \
    -e VIRTUAL_HOST=${VIRTUAL_HOST} \
    -e VIRTUAL_PORT=8888 \
    -e LETSENCRYPT_HOST=${LETSENCRYPT_HOST} \
    -e LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL} \
    -e GITHUB_CLIENT_ID=${GITHUB_CLIENT_ID} \
    -e GITHUB_CLIENT_SECRET=${GITHUB_CLIENT_SECRET} \
    -e BASE_URL=${BASE_URL} \
    ${IMAGE_NAME}
EOF
