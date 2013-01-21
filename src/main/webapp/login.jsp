<%@ include file="/taglibs.jsp"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <title><fmt:message key="login.title"/></title>
</head>
<body>
<form method="post" id="loginForm" action="j_security_check">
<fieldset>
<ul>
    <li>
       <label for="j_username">
            <fmt:message key="label.username"/>
        </label>
        <input type="text" name="j_username" id="j_username" tabindex="1" />
    </li>

    <li>
        <label for="j_password" >
            <fmt:message key="label.password"/>
        </label>
        <input type="password" name="j_password" id="j_password" tabindex="2" />
    </li>

    <li>
        <input type="submit" name="login" value="<fmt:message key="button.login"/>" tabindex="4" />
    </li>
</ul>
</fieldset>
</form>
</body>
</html>