<%@ page import="com.alibaba.fastjson.JSONObject" %>
<%@ page import="weaver.conn.RecordSet" %>
<%@ page import="weaver.integration.util.HTTPUtil" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ include file="/systeminfo/init_wev8.jsp" %>

<%
    // 单点SFA系统
    BaseBean baseBean = new BaseBean();
    int uid = user.getUID();
    baseBean.writeLog("单点北方学院开始==============" + uid);
    String name = "";
    String password = "";

    RecordSet recordSet = new RecordSet();
    recordSet.executeQuery("select zh, mm from uf_sso_info where xtmc = 'bfxy' and modedatacreater = " + uid);
    if (recordSet.next()) {
        name = recordSet.getString("zh");
        password = recordSet.getString("mm");
    }

    Map<String, String> map = new HashMap<>();
    map.put("name", name);
    map.put("password", password);
    String returnJson = HTTPUtil.doPost("http://bfpt.yunkeonline.cn/sso/api/login", map);
    baseBean.writeLog("returnJson: " + returnJson);
    JSONObject jsonObject = JSONObject.parseObject(returnJson);
    String token = jsonObject.getString("token");

    response.sendRedirect("http://bfpt.yunkeonline.cn?token=" + token);

%>





