#!/usr/bin/env bash
echo "Self signed dummy cert"
set -e
openssl genrsa -out server.key 1024
openssl req -subj '/C=US/ST=CA/L=SF/CN=*.com' -new -key server.key -out server.csr
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
