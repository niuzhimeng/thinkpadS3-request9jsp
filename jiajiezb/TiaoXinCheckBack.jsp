<%@ page import="com.alibaba.fastjson.JSONObject" %>
<%@ page import="com.weaver.general.BaseBean" %>
<%@ page import="weaver.conn.RecordSet" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>

<%
    // 调薪流程-调薪范围校验
    BaseBean baseBean = new BaseBean();
    RecordSet recordSet = new RecordSet();
    String tzhzjVal = request.getParameter("tzhzjVal"); // 调整后职级
    String tzhjbgzVal = request.getParameter("tzhjbgzVal"); // 调整后基本工资
    baseBean.writeLog("调薪流程-调薪范围校验后台=====================Start");
    try {
        boolean flag = true;
        double mbxz = Double.parseDouble(tzhjbgzVal);

        double zdxz = 0; // 最低薪资
        double zgxz = 0; // 最高薪资
        recordSet.executeQuery("select * from uf_JTxzfw where zj = '" + tzhzjVal + "'");
        if (recordSet.next()) {
            zdxz = recordSet.getDouble("zdxz") < 0 ? 0 : recordSet.getDouble("zdxz");
            zgxz = recordSet.getDouble("zgxz") < 0 ? 0 : recordSet.getDouble("zgxz");
            if (mbxz <= zdxz || mbxz > zgxz) {
                flag = false;
            }
        }
        JSONObject returnObject = new JSONObject();
        returnObject.put("myState", flag);
        if (!flag) {
            returnObject.put("msg", "当前薪资不合规，正确薪资范围应大于【" + zdxz + "元】小于等于【" + zgxz + "元】，请确认金额。");
        }

        out.clear();
        out.print(returnObject.toJSONString());
    } catch (Exception e) {
        baseBean.writeLog("调薪流程-调薪范围校验后台Error: " + e);
        out.clear();
        out.print("调薪流程-调薪范围校验后台Error: " + e);
    }


%>