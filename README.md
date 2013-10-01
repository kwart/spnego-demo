# SPNEGO secured web application demo for JBoss AS 7.x

Demo application which shows, how to get Kerberos authentication working in JBboss AS 7.x (or JBoss EAP 6.x).

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
		            <module-option name="password-stacking" value="useFirstPass"/>
		        </login-module>
		        <login-module code="org.jboss.AddRoleLoginModule" flag="optional">
		            <module-option name="roleName" value="admin"/>
		            <module-option name="password-stacking" value="useFirstPass"/>
		        </login-module>
		    </authentication>
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

## Test the application

Open the application URL in your SPNEGO enabled  browser

	$ chromium-browser --auth-server-whitelist=localhost --auth-negotiate-delegate-whitelist=localhost http://localhost:8080/spnego-demo/

## License

* [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)
