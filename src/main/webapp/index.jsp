<%@ include file="/taglibs.jsp"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<title>Sample secured web application</title>
</head>
<body>
	<h1>Sample secured web application</h1>
	<p>ServletPath: ${pageContext.request.servletPath}<br/>	
	PathInfo: ${pageContext.request.pathInfo}</p>	
	<p>This application contains 3 pages:</p>
	<ul>
		<li><a href="<c:url value='/'/>">Home page</a> - unprotected</li>
		<li><a href="<c:url value='/user/'/>">User page</a> - only users with User or Admin role can access it</li>
		<li><a href="<c:url value='/admin/'/>">Admin page</a> - only users with Admin role can access it</li>
	</ul>
	<p>There are 2 user accounts prepared for JBoss testing:</p>
	<ul>
		<li>user/user with role User</li>
		<li>admin/admin with role Admin</li>
	</ul>
</body>
</html>