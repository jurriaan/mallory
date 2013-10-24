#!/usr/bin/env bash
echo "Generating CA"
set -e
openssl genrsa -out ./keys/ca.key 1024
openssl req -new -x509 -days 3650 -key ./keys/ca.key -out ./keys/ca.crt -subj '/C=US/ST=CA/L=SF/CN=mallory.com'
openssl x509 -noout -text -in ./keys/ca.crt
