package org.jboss.test;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Simple session status check
 * 
 * @author Josef Cacek
 */
@WebServlet({ "/SessionStatusCheckServlet", "/user/SessionStatusCheckServlet" })
public class SessionStatusCheckServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    /**
     * Writes principal name as a simple text response.
     * 
     * @param req
     * @param resp
     * @throws ServletException
     * @throws IOException
     * @see javax.servlet.http.HttpServlet#doGet(javax.servlet.http.HttpServletRequest, javax.servlet.http.HttpServletResponse)
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html");
        final PrintWriter writer = resp.getWriter();
        writer.println("<a href='index.jsp'>index.jsp</a><br/>");
        HttpSession session = req.getSession(false);
        writer.println("Session exists: " + (session != null) + "<br/>");
        if (session != null) {
            writer.println("Session isNew: " + session.isNew());
        }
        writer.close();
    }
}
