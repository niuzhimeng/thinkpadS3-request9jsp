<%@ page import="weaver.conn.RecordSet" %>
<%@ page import="weaver.general.BaseBean" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<%
    BaseBean baseBean = new BaseBean();
    RecordSet recordSet = new RecordSet();
    RecordSet updateSet = new RecordSet();
    RecordSet jkSet = new RecordSet();
    try {
        recordSet.executeQuery("select * form uf_ygjk");
        while (recordSet.next()) {
            // 借款流程的requestid
            String jklc = recordSet.getString("jklc");
            String id = recordSet.getString("id");
            jkSet.executeQuery("select currentnodetype from workflow_requestbase where requestid = " + jklc);
            if (jkSet.next()) {
                int currentnodetype = jkSet.getInt("currentnodetype"); // 0：创建，1：批准，2：提交，3：归档
                int state; // 还款状态
                if (currentnodetype == 3) {
                    state = 2; // 已还款
                } else {
                    state = 1; // 还款中
                }
                updateSet.executeUpdate("update uf_ygjk set hkzt = " + state + " where id = " + id); // 未还款
            } else {
                updateSet.executeUpdate("update uf_ygjk set hkzt = 0 where id = " + id); // 未还款
            }

        }
    } catch (Exception e) {
        baseBean.writeLog("单点试剂系统 Err: " + e);
    }
%>