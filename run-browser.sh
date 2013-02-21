#!/bin/bash

export SPNEGO_TEST_DIR=/tmp/spnego-in-as7
export KRB5_CONFIG=$SPNEGO_TEST_DIR/krb5.conf

chromium-browser --auth-server-whitelist=localhost --auth-negotiate-delegate-whitelist=localhost http://localhost:8080/spnego-demo/
