#!/bin/bash

export SPNEGO_TEST_DIR=/tmp/spnego-in-as7

mkdir -p $SPNEGO_TEST_DIR

cd $SPNEGO_TEST_DIR
echo "Building Kerberos test server"
git clone git://github.com/kwart/kerberos-using-apacheds.git
cd kerberos-using-apacheds
mvn clean package
cp test.ldif target/kerberos-using-apacheds.jar $SPNEGO_TEST_DIR

cd $SPNEGO_TEST_DIR
echo "Starting Kerberos server"
java -jar kerberos-using-apacheds.jar test.ldif > kerberos.out 2>&1 &
sleep 10

echo "Authenticate hnelson@JBOSS.ORG in Kerberos"
export KRB5_CONFIG=$SPNEGO_TEST_DIR/krb5.conf
kinit hnelson@JBOSS.ORG << EOT
secret
EOT

echo "Genereate keytab for HTTP/localhost@JBOSS.ORG"
java -classpath kerberos-using-apacheds.jar org.jboss.test.kerberos.CreateKeytab HTTP/localhost@JBOSS.ORG httppwd http.keytab

echo "Install JBoss AS7"
cd $SPNEGO_TEST_DIR
wget http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.zip
unzip -q jboss-as-7.1.1.Final.zip
export JBOSS_HOME=$SPNEGO_TEST_DIR/jboss-as-7.1.1.Final

echo "Starting JBoss AS7"
cd $JBOSS_HOME/bin
./standalone.sh >as7.out 2>&1 &
sleep 10

echo "Configuring JBoss AS7"
cat << EOT > $SPNEGO_TEST_DIR/cli-commands.txt
/subsystem=security/security-domain=host:add(cache-type=default)
/subsystem=security/security-domain=host/authentication=classic:add(login-modules=[{"code"=>"Kerberos", "flag"=>"required", "module-options"=>[ ("debug"=>"true"),("storeKey"=>"true"),("refreshKrb5Config"=>"true"),("useKeyTab"=>"true"),("doNotPrompt"=>"true"),("keyTab"=>"$SPNEGO_TEST_DIR/http.keytab"),("principal"=>"HTTP/localhost@JBOSS.ORG")]}]) {allow-resource-service-restart=true}

/subsystem=security/security-domain=SPNEGO:add(cache-type=default)
/subsystem=security/security-domain=SPNEGO/authentication=classic:add(login-modules=[{"code"=>"SPNEGO", "flag"=>"required", "module-options"=>[("serverSecurityDomain"=>"host")]}]) {allow-resource-service-restart=true}
/subsystem=security/security-domain=SPNEGO/mapping=classic:add(mapping-modules=[{"code"=>"SimpleRoles", "type"=>"role", "module-options"=>[("jduke@JBOSS.ORG"=>"Admin"),("hnelson@JBOSS.ORG"=>"User")]}]) {allow-resource-service-restart=true}

/system-property=java.security.krb5.conf:add(value="$SPNEGO_TEST_DIR/krb5.conf")
/system-property=java.security.krb5.debug:add(value=true)
/system-property=jboss.security.disable.secdomain.option:add(value=true)

:reload()
EOT
./jboss-cli.sh -c --file=$SPNEGO_TEST_DIR/cli-commands.txt
sleep 3

cd $SPNEGO_TEST_DIR
git clone git://github.com/kwart/spnego-demo.git
cd spnego-demo
mvn clean package
cp target/spnego-demo.war $JBOSS_HOME/standalone/deployments/

killall chromium-browser
chromium-browser --auth-server-whitelist=localhost --auth-negotiate-delegate-whitelist=localhost http://localhost:8080/spnego-demo/
