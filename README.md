# SPNEGO secured web application demo for JBoss EAP & WildFly

Demo application which shows, how to get Kerberos authentication working in JBboss Application Server.

## How does it work?

 * Your web application defines dependency on `org.jboss.security.negotiation` AS module in `META-INF/jboss-deployment-structure.xml`

		<jboss-deployment-structure>
			<deployment>
				<dependencies>
					<module name="org.jboss.security.negotiation" />
				</dependencies>
			</deployment>
		</jboss-deployment-structure>
 * Your web application defines `NegotiationAuthenticator` custom authenticator and a reference to a security domain 
   used for clients authentication in `WEB-INF/jboss-web.xml`.

		<jboss-web>
			<security-domain>SPNEGO</security-domain>
			<valve>
				<class-name>org.jboss.security.negotiation.NegotiationAuthenticator</class-name>
			</valve>
		</jboss-web>

 * The security domain uses the `SPNEGOLoginModule` JAAS login module and it has name `SPNEGO` in this demo.

		<security-domain name="SPNEGO" cache-type="default">
			<authentication>
				<login-module code="SPNEGO" flag="required">
					<module-option name="serverSecurityDomain" value="host"/>
				</login-module>
			</authentication>
			<mapping>
				<mapping-module code="SimpleRoles" type="role">
					<module-option name="jduke@JBOSS.ORG" value="Admin"/>
					<module-option name="hnelson@JBOSS.ORG" value="User"/>
				</mapping-module>
			</mapping>
		</security-domain>
 * The `SPNEGO` security domain references the second domain which is used for JBoss AS server authentication 
   in Kerberos. It uses `Krb5LoginModule` login module and its name is `host`.

		<security-domain name="host" cache-type="default">
		    <authentication>
		        <login-module code="Kerberos" flag="required">
		            <module-option name="storeKey" value="true"/>
		            <module-option name="refreshKrb5Config" value="true"/>
		            <module-option name="useKeyTab" value="true"/>
		            <module-option name="doNotPrompt" value="true"/>
		            <module-option name="keyTab" value="/tmp/spnego-in-as7/http.keytab"/>
		            <module-option name="principal" value="HTTP/localhost@JBOSS.ORG"/>
		        </login-module>
		    </authentication>
		</security-domain>

## Prepare your environment

There are several steps, which should be completed to get the demo working.

### Prepare your system

Install MIT kerberos utils, [Java JDK](http://www.oracle.com/technetwork/java/javase/downloads/index.html) version 6 or newer,
[git](http://git-scm.com/) and [Maven](http://maven.apache.org/), unzip and wget.

Fedora:

	$ sudo yum install wget unzip java-1.7.0-openjdk-devel krb5-workstation maven git

Ubuntu:

	$ sudo apt-get install wget unzip openjdk-6-jdk krb5-user git maven

### Prepare your browser

If you use the Firefox, go to `about:config` and set following entries there:

	network.negotiate-auth.delegation-uris = localhost
	network.negotiate-auth.trusted-uris = localhost

If you use Chromium, then start it with following command line arguments:

	$ chromium-browser --auth-server-whitelist=localhost --auth-negotiate-delegate-whitelist=localhost

### Prepare a folder for your tests

```bash
export SPNEGO_TEST_DIR=/tmp/spnego-in-as7
mkdir $SPNEGO_TEST_DIR
```

### Prepare the Kerberos server

If you don't have some Kerberos server prepared already, you can use the testing
[kerberos-using-apacheds](http://github.com/kwart/kerberos-using-apacheds) project:

```bash
cd $SPNEGO_TEST_DIR
git clone git://github.com/kwart/kerberos-using-apacheds.git
cd kerberos-using-apacheds
mvn clean package
cp test.ldif target/kerberos-using-apacheds.jar $SPNEGO_TEST_DIR
```

The test server has hardcoded following settings:

	searchBaseDn = dc=jboss,dc=org
	primaryRealm = JBOSS.ORG
	kdcPrincipal = krbtgt/JBOSS.ORG@JBOSS.ORG

#### Start the server and import test data 
	
The test server project is a runnable JAR file 

```bash
cd $SPNEGO_TEST_DIR
java -jar kerberos-using-apacheds.jar test.ldif
```

Launching the test server also creates an `krb5.conf` kerberos configuration file in the current folder. We will use it later.

There are 3 important users which you will use later in the imported `test.ldif` file:

	dn: uid=HTTP,ou=Users,dc=jboss,dc=org
	userPassword: httppwd
	krb5PrincipalName: HTTP/${hostname}@JBOSS.ORG
	
	dn: uid=hnelson,ou=Users,dc=jboss,dc=org
	userPassword: secret
	krb5PrincipalName: hnelson@JBOSS.ORG
	
	dn: uid=jduke,ou=Users,dc=jboss,dc=org
	userPassword: theduke
	krb5PrincipalName: jduke@JBOSS.ORG

The HTTP user is the principal of your JBoss AS server. The other 2 users are test client principals. 
The ${hostname} is a placeholder which will be replaced with the value of system property `kerberos.bind.address`.
It this property is not defined, then the `localhost` value is used.

### Customize the client's krb5.conf

The previous step generated `krb5.conf` file. Backup your original configuration in `/etc/krb5.conf` and replace it with the generated one.

```bash
mv /etc/krb5.conf /etc/krb5.conf.orig
cp $SPNEGO_TEST_DIR/krb5.conf /etc/krb5.conf
```

Correct configuration in `krb5.conf` file is necessary for client authentication (`kinit`) and also for correct negotiation
in a web browser.

#### Login to Kerberos as hnelson@JBOSS.ORG

Refer to generated `krb5.conf` file and use `kinit` system tool to authenticate in Kerberos.

```bash
kinit hnelson@JBOSS.ORG << EOT
secret
EOT
```

### Prepare keytab file for the JBoss AS authentication in Kerberos

A keytab is a file containing pairs of Kerberos principals and encrypted keys derived from the Kerberos password.
Keytab files can be used to log into Kerberos without being prompted for a password (e.g. authenticate without human interaction).

Use the `CreateKeytab` utility from the `kerberos-using-apacheds` project to generate the keytab for the `HTTP/localhost@JBOSS.ORG` principal:

```bash
cd $SPNEGO_TEST_DIR
java -classpath kerberos-using-apacheds.jar org.jboss.test.kerberos.CreateKeytab HTTP/localhost@JBOSS.ORG httppwd http.keytab
```

You can also use some system utility such as `ktutil` to generate your keytab file.

### Prepare JBoss AS 7.x

Download the [JBoss AS 7.x](http://www.jboss.org/jbossas/downloads) and install it.

```bash
cd $SPNEGO_TEST_DIR
wget http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.zip
unzip jboss-as-7.1.1.Final.zip
export JBOSS_HOME=$SPNEGO_TEST_DIR/jboss-as-7.1.1.Final
```

Start the AS 7:

```bash
cd $JBOSS_HOME/bin
./standalone.sh
```

Configure the AS 7 using management API (CLI):

```bash
cd $JBOSS_HOME/bin
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
```

You've created `host` and `SPNEGO` security domains now. Also some kerberos authentication related system properties were added.

## Prepare and deploy the demo application

Use this `spnego-demo` web application to test your settings.

```bash
cd $SPNEGO_TEST_DIR
git clone git://github.com/kwart/spnego-demo.git
cd spnego-demo
mvn clean package
cp target/spnego-demo.war $JBOSS_HOME/standalone/deployments 
```

## Test the application

Open the application URL in your SPNEGO enabled  browser

```bash
chromium-browser --auth-server-whitelist=localhost --auth-negotiate-delegate-whitelist=localhost http://localhost:8080/spnego-demo/
```

There are 3 test pages included:

 * [Home page](http://localhost:8080/spnego-demo/) is unprotected
 * [User page](http://localhost:8080/spnego-demo/user/) is reachable by Admin and User role (so both `jduke@JBOSS.ORG` and `hnelson@JBOSS.ORG` should have access)
 * [Admin page](http://localhost:8080/spnego-demo/admin/) is reachable only by Admin role (only `jduke@JBOSS.ORG` should have access)

## License

* [GNU Lesser General Public License Version 2.1](http://www.gnu.org/licenses/lgpl-2.1-standalone.html)
