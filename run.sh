#!/bin/bash

. set-env.sh

mkdir -p "$SPNEGO_TEST_DIR"

cd "$SPNEGO_TEST_DIR"
echo "Building Kerberos test server"
git clone git://github.com/kwart/kerberos-using-apacheds.git
cd kerberos-using-apacheds
mvn clean package
cp test.ldif target/kerberos-using-apacheds.jar "$SPNEGO_TEST_DIR"

cd "$SPNEGO_TEST_DIR"
echo "Starting Kerberos server"
java -Dkerberos.bind.address=$BIND_ADDRESS -jar kerberos-using-apacheds.jar test.ldif > kerberos.out 2>&1 &
sleep 10

echo "Authenticate hnelson@JBOSS.ORG in Kerberos"
kinit hnelson@JBOSS.ORG << EOT
secret
EOT

echo "Genereate keytab for $JBOSS_SPN"
java -classpath kerberos-using-apacheds.jar org.jboss.test.kerberos.CreateKeytab $JBOSS_SPN httppwd http.keytab

echo "Install WildFly"
cd "$SPNEGO_TEST_DIR"
wget "${JBOSS_INST}"
unzip -q "${JBOSS_INST##*/}"

echo "Configuring WildFly"
cat << EOT > "$SPNEGO_TEST_DIR/cli-commands.txt"
embed-server
/subsystem=security/security-domain=host:add(cache-type=default)
/subsystem=security/security-domain=host/authentication=classic:add(login-modules=[{"code"=>"Kerberos", "flag"=>"required", "module-options"=>[ ("debug"=>"true"),("storeKey"=>"true"),("refreshKrb5Config"=>"true"),("useKeyTab"=>"true"),("doNotPrompt"=>"true"),("keyTab"=>"$SPNEGO_TEST_DIR/http.keytab"),("principal"=>"$JBOSS_SPN")]}]) {allow-resource-service-restart=true}

/subsystem=security/security-domain=SPNEGO:add(cache-type=default)
/subsystem=security/security-domain=SPNEGO/authentication=classic:add(login-modules=[{"code"=>"SPNEGO", "flag"=>"required", "module-options"=>[("serverSecurityDomain"=>"host")]}]) {allow-resource-service-restart=true}
/subsystem=security/security-domain=SPNEGO/mapping=classic:add(mapping-modules=[{"code"=>"SimpleRoles", "type"=>"role", "module-options"=>[("jduke@JBOSS.ORG"=>"Admin"),("hnelson@JBOSS.ORG"=>"User")]}]) {allow-resource-service-restart=true}

/system-property=java.security.krb5.conf:add(value="$SPNEGO_TEST_DIR/krb5.conf")
/system-property=java.security.krb5.debug:add(value=true)
/system-property=jboss.security.disable.secdomain.option:add(value=true)
EOT
"$JBOSS_HOME/bin/jboss-cli.sh" "--file=$SPNEGO_TEST_DIR/cli-commands.txt" 2>&1 | tee jboss_as_config.out

echo "Starting WildFly"
"$JBOSS_HOME/bin/standalone.sh" > "$SPNEGO_TEST_DIR/jboss_as.out" 2>&1 &

cd "$SPNEGO_TEST_DIR"
git clone git://github.com/kwart/spnego-demo.git
cd spnego-demo
mvn clean package
cp target/spnego-demo.war "$JBOSS_HOME/standalone/deployments/"
