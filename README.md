# SPNEGO secured web application demo for JBoss AS 7.x

Demo application which shows, how to get Kerberos authentication working in JBboss AS 7.x (or JBoss EAP 6.x)

## How does it work?

 * Your web application defines dependency on `org.jboss.security.negotiation` AS module in `META-INF/jboss-deployment-structure.xml`
 * Your web application defines `NegotiationAuthenticator` custom authenticator and a reference to a security domain used for clients authentication in `WEB-INF/jboss-web.xml`. The domain uses the `SPNEGOLoginModule` JAAS login module and it has name `SPNEGO` in this demo.
 * The `SPNEGO` security domain references the second domain which is used for JBoss AS server authentication against a KDC. It uses `Krb5LoginModule` login module and its name is `host`.  

## How to get the sources

You should have [git](http://git-scm.com/) installed

	$ git clone git://github.com/kwart/spnego-demo.git

or you can download [current sources as a zip file](https://github.com/kwart/spnego-demo/archive/master.zip)

## How to build it

You need to have [Maven](http://maven.apache.org/) installed

	$ cd spnego-demo
	$ mvn clean package

## How to install it

### Configure your JBoss AS 7.x

This demo application needs some additional security domains in the JBoss AS:
 * `host` domain is used for JBoss AS server authentication against the KDC (Key Distribution Center)
 * `SPNEGO` domain is used for client authentication against the JBoss AS
  
Start your AS:
	
	$ cd $JBOSS_HOME/bin
	$ ./standalone.sh
	
Define the new security domains by using JBoss CLI (`jboss-cli.sh` / `jboss-cli.bat`):

	$ cat << EOF > cli-commands.txt
	/subsystem=security/security-domain=host:add(cache-type=default)
	/subsystem=security/security-domain=host/authentication=classic:add( \
		login-modules=[{"code"=>"Kerberos", "flag"=>"required", "module-options"=>[ \
		("debug"=>"true"),\
		("storeKey"=>"true"),\
		("refreshKrb5Config"=>"true"),\
		("useKeyTab"=>"true"),\
		("doNotPrompt"=>"true"),\
		("keyTab"=>"$JBOSS_HOME/http.keytab"),\
		("principal"=>"HTTP/localhost@JBOSS.ORG")\
	]}]) {allow-resource-service-restart=true}
	
	/subsystem=security/security-domain=SPNEGO:add(cache-type=default)
	/subsystem=security/security-domain=SPNEGO/authentication=classic:add( \
		login-modules=[{"code"=>"SPNEGO", "flag"=>"required", "module-options"=>[ \
		("password-stacking"=>"useFirstPass"),\
		("serverSecurityDomain"=>"host")\
	]}]) {allow-resource-service-restart=true}
	/subsystem=security/security-domain=SPNEGO/mapping=classic:add( \
		mapping-modules=[{"code"=>"SimpleRoles", "type"=>"role", "module-options"=>[ \
		("jduke@JBOSS.ORG"=>"Admin"),\
		("hnelson@JBOSS.ORG"=>"User"),\
	]}]) {allow-resource-service-restart=true}
	
	/system-property=java.security.krb5.conf:add(value="$JBOSS_HOME/krb5.conf")
	/system-property=java.security.krb5.debug:add(value=true)
	/system-property=jboss.security.disable.secdomain.option:add(value=true)
	
	:reload()
	EOT
	$ ./jboss-cli.sh -c --file=cli-commands.txt

### Deploy the secured-webapp.war web application

Copy the `target/secured-webapp.war` to the `$JBOSS_HOME/standalone/deployments`.

Open the application URL in the browser. E.g. [http://localhost:8080/secured-webapp/](http://localhost:8080/secured-webapp/)

## License

* [GNU Lesser General Public License Version 2.1](http://www.gnu.org/licenses/lgpl-2.1-standalone.html)
