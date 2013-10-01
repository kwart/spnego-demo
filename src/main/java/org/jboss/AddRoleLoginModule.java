/*
 * Copyright 2013, Red Hat, Inc., and individual contributors
 * as indicated by the @author tags.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.jboss;

import java.security.Principal;
import java.security.acl.Group;
import java.util.Map;

import javax.security.auth.Subject;
import javax.security.auth.callback.CallbackHandler;
import javax.security.auth.login.LoginException;

import org.jboss.security.SecurityConstants;
import org.jboss.security.SimpleGroup;
import org.jboss.security.SimplePrincipal;
import org.jboss.security.auth.spi.AbstractServerLoginModule;

/**
 * Login module, which adds a single role (configured as {@value #ROLE_NAME} module option) to an already authenticated
 * identity. It can be plugged into a login module stack, where already exists an authenticating login module with
 * password-stacking=useFirstPass module option.
 * <p>
 * Example configuration:
 * 
 * <pre>
 * &lt;security-domain name=&quot;SPNEGO&quot; cache-type=&quot;default&quot;&gt;
 *     &lt;authentication&gt;
 *         &lt;login-module code=&quot;SPNEGO&quot; flag=&quot;required&quot;&gt;
 *             &lt;module-option name=&quot;serverSecurityDomain&quot; value=&quot;host&quot;/&gt;
 *             &lt;module-option name=&quot;password-stacking&quot; value=&quot;useFirstPass&quot;/&gt;
 *         &lt;/login-module&gt;
 *         &lt;login-module code=&quot;org.jboss.AddRoleLoginModule&quot; flag=&quot;optional&quot;&gt;
 *             &lt;module-option name=&quot;roleName&quot; value=&quot;admin&quot;/&gt;
 *             &lt;module-option name=&quot;password-stacking&quot; value=&quot;useFirstPass&quot;/&gt;
 *         &lt;/login-module&gt;
 *     &lt;/authentication&gt;
 * &lt;/security-domain&gt;
 * </pre>
 * 
 * @author Josef Cacek
 */
public class AddRoleLoginModule extends AbstractServerLoginModule {

    private static final String ROLE_NAME = "roleName";
    private static final String[] ALL_VALID_OPTIONS = { ROLE_NAME };

    private String role;
    private Principal identity;

    @Override
    public void initialize(Subject subject, CallbackHandler callbackHandler, Map<String, ?> sharedState, Map<String, ?> options) {
        addValidOptions(ALL_VALID_OPTIONS);
        super.initialize(subject, callbackHandler, sharedState, options);
        role = (String) options.get(ROLE_NAME);
    }

    @Override
    public boolean login() throws LoginException {
        if (super.login()) {
            Object username = sharedState.get("javax.security.auth.login.name");
            if (username instanceof Principal)
                identity = (Principal) username;
            else {
                String name = username.toString();
                try {
                    identity = createIdentity(name);
                } catch (Exception e) {
                    LoginException le = new LoginException("Identity creation failed");
                    le.initCause(e);
                    throw new LoginException("Identity");
                }
            }
            return true;
        }
        return false;
    }

    @Override
    protected Group[] getRoleSets() throws LoginException {
        Group roles = new SimpleGroup(SecurityConstants.ROLES_IDENTIFIER);
        roles.addMember(new SimplePrincipal(role));
        return new Group[] { roles };
    }

    @Override
    protected Principal getIdentity() {
        return identity;
    }

}
