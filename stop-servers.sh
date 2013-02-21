#!/bin/bash

export SPNEGO_TEST_DIR=/tmp/spnego-in-as7
export JBOSS_HOME=$SPNEGO_TEST_DIR/jboss-as-7.1.1.Final

cd $JBOSS_HOME/bin
echo "Stopping JBoss AS7 server"
./jboss-cli.sh -c :shutdown

cd $SPNEGO_TEST_DIR
echo "Stopping Kerberos server"
java -jar kerberos-using-apacheds.jar stop

