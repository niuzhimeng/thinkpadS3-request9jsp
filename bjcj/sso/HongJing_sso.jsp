<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ include file="/systeminfo/init_wev8.jsp" %>

<%
    // 单点宏景HR系统
    BaseBean baseBean = new BaseBean();
    try {
        // 双方约定key值
        String key = "HJEHR";
        String userCode = user.getLoginid();
        String timestamp = String.valueOf(System.currentTimeMillis() / 1000);

        String verify = getMD5OfStr(userCode + key + timestamp);

        String url = "http://hr.bucnc.com:8888/templates/index/ssologon.jsp?verify=" + verify +
                "&userName=" + userCode + "&strSysDatetime=" + timestamp;

        baseBean.writeLog("宏景hr跳转地址： " + url);
        response.sendRedirect(url);
    } catch (Exception e) {
        baseBean.writeLog("单点宏景HR异常： " + e);
    }
%>


<%!
    private static String getMD5OfStr(String unencodeStr) {
        String returnStr = "";
        try {
            MessageDigest messageDigest = MessageDigest.getInstance("MD5");
            messageDigest.reset();
            messageDigest.update(unencodeStr.getBytes(StandardCharsets.UTF_8));

            byte[] byteArray = messageDigest.digest();
            StringBuilder md5StrBuff = new StringBuilder();
            for (byte b : byteArray) {
                if (Integer.toHexString(0xFF & b).length() == 1)
                    md5StrBuff.append("0").append(Integer.toHexString(0xFF & b));
                else {
                    md5StrBuff.append(Integer.toHexString(0xFF & b));
                }
            }
            returnStr = md5StrBuff.toString();
        } catch (Exception e) {
            new BaseBean().writeLog("getMD5OfStr异常： " + e);
        }
        return returnStr;
    }
%>





