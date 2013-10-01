#!/bin/bash

. set-env.sh

cd "$JBOSS_HOME/bin"
echo "Stopping JBoss AS7 server"
./jboss-cli.sh -c :shutdown

cd "$SPNEGO_TEST_DIR"
echo "Stopping Kerberos server"
java -jar kerberos-using-apacheds.jar stop

