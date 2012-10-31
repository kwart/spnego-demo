package org.jboss.test;

import java.io.IOException;
import java.io.PrintWriter;

import javax.annotation.security.DeclareRoles;
import javax.servlet.ServletException;
import javax.servlet.annotation.HttpConstraint;
import javax.servlet.annotation.ServletSecurity;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Protected version of {@link SimpleServlet}. Only {@value #ALLOWED_ROLE} role has access right.
 * 
 * @author Josef Cacek
 */
@DeclareRoles({ SimpleSecuredServlet.ALLOWED_ROLE })
@ServletSecurity(@HttpConstraint(rolesAllowed = { SimpleSecuredServlet.ALLOWED_ROLE }))
@WebServlet(SimpleSecuredServlet.SERVLET_PATH)
public class SimpleSecuredServlet extends HttpServlet {

    /** The serialVersionUID */
    private static final long serialVersionUID = 1L;
    public static final String SERVLET_PATH = "/SimpleSecuredServlet";
    public static final String ALLOWED_ROLE = "Admin";

    /** The String returned in the HTTP response body. */
    public static final String RESPONSE_BODY = "GOOD";

    /**
     * Writes simple text response.
     * 
     * @param req
     * @param resp
     * @throws ServletException
     * @throws IOException
     * @see javax.servlet.http.HttpServlet#doGet(javax.servlet.http.HttpServletRequest, javax.servlet.http.HttpServletResponse)
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/plain");
        final PrintWriter writer = resp.getWriter();
        writer.write(RESPONSE_BODY);
        writer.close();
    }
}
