<%@ page import="com.alibaba.fastjson.JSON" %>
<%@ page import="com.alibaba.fastjson.JSONObject" %>
<%@ page import="weaver.conn.RecordSet" %>
<%@ page import="weaver.general.BaseBean" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.DataOutputStream" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.io.InputStreamReader" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<%
    // 跳转地址
    String ip = "http://gcjszxtest.tidepharm.com/#/verification";
    // 获取token地址
    String tokenUrl = "http://ucapitest.tidepharm.com/api/account/verification";
    String account = "18100000000";
    String key = "95F596A5-7B1A-11E8-A778-00FF140FC3616";

    BaseBean baseBean = new BaseBean();
    RecordSet recordSet = new RecordSet();
    try {
        recordSet.executeQuery("select EMAIL from hrmresource where id = " + user.getUID());
        recordSet.next();
        //account= recordSet.getString("EMAIL").split("@")[0];
        baseBean.writeLog("单点试剂系统account Start =========== " + account + " " + TimeUtil.getCurrentTimeString());
        baseBean.writeLog("单点试剂系统key Start =========== " + key + " " + TimeUtil.getCurrentTimeString());

        JSONObject paramObj = new JSONObject(true);
        paramObj.put("Account", account);
        paramObj.put("key", key);
        // 获取token
        String tokenStr = sendPost(tokenUrl, paramObj.toJSONString());
        baseBean.writeLog("调用获取token接口返回：" + tokenStr);
        if (tokenStr == null || "".equals(tokenStr)) {
            out.clear();
            out.print("单点异常，获取token接口返回数据： " + tokenStr);
        }

        // 解析返回json
        JSONObject tokenObject = JSON.parseObject(tokenStr);
        String code = tokenObject.getString("code");
        JSONObject responseObj = tokenObject.getJSONObject("response");
        String token = responseObj.getString("Token");
        String Identity = responseObj.getString("Identity");
        baseBean.writeLog("errCode值：" + code);

        String tzUrl = ip + "?Token=" + token + "&Identity=" + Identity + "&Account=" + account;
        if ("100".equalsIgnoreCase(code)) {
            baseBean.writeLog("跳转url： " + tzUrl);
            response.sendRedirect(tzUrl);
            return;
        }
    } catch (Exception e) {
        baseBean.writeLog("单点试剂系统 Err: " + e);
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
            conn.setRequestProperty("Content-Type", "application/json");
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