#!/usr/bin/env bash
echo "Self signed dummy cert"
set -e
openssl genrsa -out ./keys/server.key 1024
openssl req -subj '/C=US/ST=CA/L=SF/CN=*.com' -new -key ./keys/server.key -out ./keys/server.csr
openssl x509 -req -days 365 -in ./keys/server.csr -signkey ./keys/server.key -out ./keys/server.crt
