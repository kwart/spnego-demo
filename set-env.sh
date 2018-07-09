export SPNEGO_TEST_DIR="/tmp/spnego-demo-testdir"
export BIND_ADDRESS=localhost
export JBOSS_SPN=HTTP/$BIND_ADDRESS@JBOSS.ORG
export BROWSER="chromium-browser --auth-server-whitelist=$BIND_ADDRESS --auth-negotiate-delegate-whitelist=$BIND_ADDRESS --user-data-dir=$SPNEGO_TEST_DIR/chrome-profile"
export KRB5_CONFIG="$SPNEGO_TEST_DIR/krb5.conf"
export JBOSS_INST=http://download.jboss.org/wildfly/10.1.0.Final/wildfly-10.1.0.Final.zip
export JBOSS_HOME="$SPNEGO_TEST_DIR/wildfly-10.1.0.Final"
