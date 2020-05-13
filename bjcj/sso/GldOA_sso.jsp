<%@ page import="com.weavernorth.bjcj.sso.myWeb.WebUtil" %>
<%@ page import="weaver.conn.RecordSet" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ include file="/systeminfo/init_wev8.jsp" %>

<%
    // 单点广联达OA系统
    BaseBean baseBean = new BaseBean();

    RecordSet recordSet = new RecordSet();
    String loginId = user.getLoginid();

    try {
        String loginid = user.getLoginid();
        String LoginCredence = "";
        String LoginTimestamp = "";
        String tzurl = "http://oa.bucnc.com:8000/Portal/Frame/LayoutE/Default.aspx"; // 跳转url
        tzurl = URLEncoder.encode(tzurl, "utf-8");

        String returnStr = WebUtil.executeWebService(loginId);
        baseBean.writeLog("验证返回msg： " + returnStr);
        if (!"".equals(returnStr)) {
            String[] split = returnStr.split("\\|");
            LoginCredence = split[0];
            LoginTimestamp = split[1];
        }

        String url = "http://oa.bucnc.com:8000/Services/Identification/Server/login.ashx?sso=1&ssoProvider=WorkflowSSO" +
                "&LoginFlag=custom&UserCode=" + loginid + "&LoginCredence=" + LoginCredence + "&LoginTimestamp=" + LoginTimestamp +
                "&service=" + tzurl;

        baseBean.writeLog("单点广联达OA系统url： " + url);

        response.sendRedirect(url);
    } catch (Exception e) {
        baseBean.writeLog("单点广联达OA异常： " + e);
    }
%>





