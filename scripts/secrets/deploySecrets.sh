#!/bin/bash
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
set -e

"$THIS_DIR/prepare.sh"

sshKey="jenkins-k8s-ssh"
httpUser="jenkins-k8s-http-user"
npmToken="jenkins-k8s-npm-token"
awsDev="jenkins-k8s-aws-dev"
k=kubectl
keysDir="$THIS_DIR/../../local/keys"

# Setup SSH key
if [ ! -f "$keysDir/$sshKey" ]; then
    echo "WARNING: SSH Key didn't exist: $keysDir/$sshKey"
    echo "...generating new one. You will need to install the $sshKey.pub on your repo server."
    ssh-keygen -t rsa -C "$sshKey" -f "$keysDir/$sshKey"
fi

$k create secret generic $sshKey \
    --from-file=privateKey=$keysDir/$sshKey \
    --from-literal=username=$sshKey \
    --save-config \
    --dry-run -o yaml | $k apply -f -

# Setup HTTP User
usernameFile="$keysDir/${httpUser}-name"
passwordFile="$keysDir/${httpUser}-pass"
if [ ! -f "$usernameFile" ]; then
    echo "ERROR: $httpUser not setup yet."
    echo "...creating dummy files. Manually go and set the creds properly in the following and rerun this script:"
    echo "   $usernameFile"
    echo "   $passwordFile"
    printf "fake-username" > $usernameFile
    printf "changeme" > $passwordFile
fi

$k create secret generic $httpUser \
    --from-file=username=$usernameFile \
    --from-file=password=$passwordFile \
    --save-config \
    --dry-run -o yaml | $k apply -f -

# Setup NPM Token
npmTokenFile="$keysDir/$npmToken"
if [ ! -f "$npmTokenFile" ]; then
    echo "ERROR: $npmToken not setup yet."
    echo "...creating dummy files. Manually go and set the creds properly in the following and rerun this script:"
    echo "   $npmTokenFile"
    printf "FAKE-NPM_TOKEN-REPLACE-ME" > $npmTokenFile
fi

$k create secret generic $npmToken \
    --from-file=NPM_TOKEN=$npmTokenFile \
    --save-config \
    --dry-run -o yaml | $k apply -f -

# Setup AWS Dev
awsDevAccessKeyFile="$keysDir/$awsDev-access-key"
awsDevSecretKeyFile="$keysDir/$awsDev-secret-key"
if [ ! -f "$awsDevAccessKeyFile" ]; then
    echo "ERROR: $awsDev not setup yet."
    echo "...creating dummy files. Manually go and set the creds properly in the following and rerun this script:"
    echo "   $awsDevAccessKeyFile"
    echo "   $awsDevSecretKeyFile"
    printf "FAKE-ACCESS-KEY-REPLACE-ME" > $awsDevAccessKeyFile
    printf "FAKE-SECRET-KEY-REPLACE-ME" > $awsDevSecretKeyFile
fi

$k create secret generic $awsDev \
    --from-file=AWS_ACCESS_KEY_ID=$awsDevAccessKeyFile \
    --from-file=AWS_SECRET_ACCESS_KEY=$awsDevSecretKeyFile \
    --save-config \
    --dry-run -o yaml | $k apply -f -


# kubectl create secret generic jenkins-k8s-npm-token \
#     --from-literal=NPM_TOKEN="" \
#     --save-config \
#     --dry-run -o yaml | kubectl apply -f -
