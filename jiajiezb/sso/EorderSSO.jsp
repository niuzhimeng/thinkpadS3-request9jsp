<%@ page import="com.alibaba.fastjson.JSONObject" %>
<%@ page import="weaver.conn.RecordSet" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.DataOutputStream" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.io.InputStreamReader" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ include file="/systeminfo/init_wev8.jsp" %>

<%
    // EORDER点登录
    BaseBean baseBean = new BaseBean();
    RecordSet recordSet = new RecordSet();
    baseBean.writeLog("EORDER Start===========================");
    try {
        // 查询单点配置信息
        Map<String, String> ssoInfoMap = new HashMap<String, String>();
        recordSet.executeQuery("select * from uf_sso_info_zb");
        while (recordSet.next()) {
            ssoInfoMap.put(recordSet.getString("ssokey").trim(), recordSet.getString("ssovalue").trim());
        }
        String eorderUrl = ssoInfoMap.get("eorderUrl");
        String eorderappId = ssoInfoMap.get("eorderappId");

        long timeStamp = System.currentTimeMillis();
        int uid = user.getUID();
        // 登录名
        String loginId = "";
        recordSet.executeQuery("select loginid from hrmresource where id = " + uid);
        if (recordSet.next()) {
            loginId = recordSet.getString("loginid");
        }
        baseBean.writeLog("当前人登录名: " + loginId + ", eorderUrl: " + eorderUrl + ", eorderappId: " + eorderappId);

        String sign = new MD5().getMD5ofStr(timeStamp + loginId + eorderappId);
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("timeStamp", timeStamp);
        jsonObject.put("account", loginId);
        jsonObject.put("sign", sign);
        String paramsStr = jsonObject.toJSONString();

        baseBean.writeLog("eorder单点发送json： " + paramsStr);
        String returnJson = sendPost(eorderUrl, paramsStr);
        baseBean.writeLog("post请求返回： " + returnJson);

        JSONObject returnObject = JSONObject.parseObject(returnJson);
        String returnCode = returnObject.getString("code");
        baseBean.writeLog("returnCode: " + returnCode);
        if ("200".equals(returnCode)) {
            response.sendRedirect(returnObject.getString("data"));
        } else {
            out.clear();
            out.print(returnObject);
            return;
        }

    } catch (Exception e) {
        baseBean.writeLog("单点EORDER系统异常： " + e);
    }

%>

<%!

    private String sendPost(String url, String paramsJson) {
        BaseBean baseBean = new BaseBean();
        BufferedReader reader = null;
        StringBuilder response = new StringBuilder();
        try {
            URL httpUrl = new URL(url);
            //建立连接
            HttpURLConnection conn = (HttpURLConnection) httpUrl.openConnection();
            conn.setRequestMethod("POST");
            conn.setUseCaches(false);//设置不要缓存
            conn.setInstanceFollowRedirects(true);
            conn.setDoOutput(true);
            conn.setConnectTimeout(9000);
            conn.setReadTimeout(9000);
            conn.setDoInput(true);
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            conn.connect();

            DataOutputStream out = new DataOutputStream(conn.getOutputStream());
            out.writeBytes(paramsJson);

            out.flush();
            out.close();

            //读取响应
            reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            String lines;
            while ((lines = reader.readLine()) != null) {
                lines = new String(lines.getBytes(), "utf-8");
                response.append(lines);
            }
            // 断开连接
            conn.disconnect();
        } catch (Exception e) {
            baseBean.writeLog("佳杰总部点单sendPost异常： " + e);
        } finally {
            try {
                if (reader != null) {
                    reader.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return response.toString();
    }
%>
