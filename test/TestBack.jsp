<%@ page import="com.alibaba.fastjson.JSONObject" %>
<%@ page import="weaver.conn.RecordSet" %>
<%@ page import="weaver.general.BaseBean" %>
<%@ page import="weaver.general.Util" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%
    BaseBean baseBean = new BaseBean();
    RecordSet recordSet = new RecordSet();
    JSONObject returnObj = new JSONObject();
    boolean flag = true;
    try {
        returnObj.put("name", "nzm");
    } catch (Exception e) {
        baseBean.writeLog("主从领导提交校验 Err: " + e);
    }
    out.clear();
    out.print(returnObj);

%>