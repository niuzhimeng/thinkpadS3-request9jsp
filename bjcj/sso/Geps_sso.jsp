<%@ page import="org.apache.commons.codec.binary.Base64" %>
<%@ page import="javax.crypto.Cipher" %>
<%@ page import="javax.crypto.SecretKey" %>

<%@ page import="javax.crypto.SecretKeyFactory" %>
<%@ page import="javax.crypto.spec.DESKeySpec" %>
<%@ page import="javax.crypto.spec.IvParameterSpec" %>
<%@ page import="java.math.BigInteger" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.security.Security" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ include file="/systeminfo/init_wev8.jsp" %>

<%
    // 单点项目管理系统
    BaseBean baseBean = new BaseBean();
    try {
        String userCode = user.getLoginid();
        baseBean.writeLog("单点项目管理系统start== " + userCode);

        String timeStamp = TimeUtil.getCurrentTimeString().replace("-", "/");
        String key = "a1234567";
        String loginCredence = getMD5(String.format("%s;%s", userCode, timeStamp));
        baseBean.writeLog("userCode: " + userCode + " timeStamp: " + timeStamp + " loginCredence: " + loginCredence);
        String content = String.format("%s;%s;%s", userCode, timeStamp, loginCredence);

        byte[] contentBytes = content.getBytes(StandardCharsets.UTF_8);
        byte[] keyBytes = key.getBytes(StandardCharsets.UTF_8);
        byte[] result = DESEncrypt(contentBytes, keyBytes, keyBytes);
        //请求的userKey值
        Base64 base64 = new Base64();
        String userKey = new String(base64.encode(result), StandardCharsets.UTF_8);
        userKey = URLEncoder.encode(userKey, "utf-8");

        String url = "http://pm.bucnc.com:8888/Services/Identification/Server/login.ashx?sso=1&ssoProvider=UserKey" +
                "&userkey=" + userKey + "&service=%2findex.aspx";
        baseBean.writeLog("单点项目管理系统url： " + url);
        response.sendRedirect(url);

    } catch (Exception e) {
        baseBean.writeLog("单点项目管理异常： " + e);
    }
%>
<%!
    //加密方法
    private byte[] DESEncrypt(byte[] contentBytes, byte[] keyBytes, byte[] ivBytes) throws Exception {
        DESKeySpec keySpec = new DESKeySpec(keyBytes);
        SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DES");
        SecretKey key = keyFactory.generateSecret(keySpec);
        IvParameterSpec iv = new IvParameterSpec(ivBytes);
        Security.addProvider(new org.bouncycastle.jce.provider.BouncyCastleProvider());
        Cipher cipher = Cipher.getInstance("DES/CBC/PKCS7Padding");
        cipher.init(Cipher.ENCRYPT_MODE, key, iv);
        return cipher.doFinal(contentBytes);
    }

    //MD5
    private String getMD5(String str) {
        try {
            MessageDigest md5 = MessageDigest.getInstance("MD5");
            sun.misc.BASE64Encoder baseEncoder = new sun.misc.BASE64Encoder();
            return baseEncoder.encode(md5.digest(str.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new RuntimeException("MD5加密出现错误");
        }
    }
%>




