# Template for secured Java web applications

Simple Java web application template with the secured content.

## How to get it

You need to have [git](http://git-scm.com/) installed

	$ git clone git://github.com/kwart/secured-webapp-template.git

## How to build it

You need to have [Maven](http://maven.apache.org/) installed

	$ cd secured-webapp-template
	$ mvn clean package

If the target container doesn't include JSTL implementation, then set the `jstl` property while calling the Maven build

	$ mvn clean package -Djstl

## How to install it

Copy the produced `secured-webapp.war` from the `target` folder to the deployment folder of your container.

Open the application URL in the browser. E.g. [http://localhost:8080/secured-webapp/](http://localhost:8080/secured-webapp/)

### How to configure it on JBoss AS 7.x / EAP 6.x

The JBoss specific deployment descriptor (WEB-INF/jboss-web.xml) refers to a `web-tests` security domain. You have to add it to your configuration.
Define the new security domain, either by using JBoss CLI (`jboss-cli.sh` / `jboss-cli.bat`):

	$ ./jboss-cli.sh -c '/subsystem=security/security-domain=web-tests:add(cache-type=default)'
	$ ./jboss-cli.sh -c '/subsystem=security/security-domain=web-tests/authentication=classic:add(login-modules=[{"code"=>"UsersRoles", "flag"=>"required"}]) {allow-resource-service-restart=true}'

or by editing `standalone/configuration/standalone.xml`, where you have to add a new child to the `<security-domains>` element

	<security-domain name="web-tests" cache-type="default">
		<authentication>
			<login-module code="UsersRoles" flag="required"/>
		</authentication>
	</security-domain>

## License

* [GNU Lesser General Public License Version 2.1](http://www.gnu.org/licenses/lgpl-2.1-standalone.html)