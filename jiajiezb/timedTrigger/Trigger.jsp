<%@ page import="com.weavernorth.jiajiezb.hr.timed.SyqZzTriggerFlow" %>
<%@ page import="com.weavernorth.jiajiezb.hr.timed.ZzTriggerFlow" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String id = request.getParameter("id");
    if ("1".equals(id)) {
        new SyqZzTriggerFlow().execute();
    } else if ("2".equals(id)) {
        new ZzTriggerFlow().execute();
    }

%>


















