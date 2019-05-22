#!/bin/bash
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CERT_DIR="$THIS_DIR/../../local/certs"
KEYS_DIR="$THIS_DIR/../../local/keys"
set -e


function main() {
    getCerts
    createKeysDir
}

function getCerts() {
    local corporateCertUrl="https://my-corp.com/path/to/cert.crt"
    local corpCertName="corp.crt"
    if [ ! -f "$CERT_DIR/$corpCertName" ]; then
        mkdir -p "$CERT_DIR"
        cd "$CERT_DIR"
        echo "Downloading Corp certs..."
        # curl "$corporateCertUrl" -o "$CERT_DIR/$corpCertName"
        # wget https://my-corp.com/diff/path/to/another/cert.crt
        # ...
        # wget https://my-corp.com/path/to/cert/bundle.zip
        # unzip "*.zip*"
        # rm *.zip
        ls -l
        echo "Finished getting Corp certs."
        cd "$THIS_DIR"
    else
        echo "Local cert already exits: $corpCertName; Not downloading any Corp certs."
    fi
}

function createKeysDir() {
    local readme="README.md"
    if [ ! -f "$KEYS_DIR/$readme" ]; then
        mkdir -p "$KEYS_DIR"
        echo "# Jenkins Keys" > "$KEYS_DIR/$readme"
        echo "" >> "$KEYS_DIR/$readme"
        echo "This is a local, untracked folder to place keys/creds for deploying Jenkins to K8s." >> "$KEYS_DIR/$readme"
    else
        echo "Local keys $readme already exits."
    fi
}

main