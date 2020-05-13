
<%@ page import="weaver.conn.RecordSet" %>
<%@ page import="javax.crypto.Cipher" %>
<%@ page import="static jdk.internal.util.xml.XMLStreamWriter.DEFAULT_ENCODING" %>
<%@ page import="javax.crypto.SecretKey" %>
<%@ page import="javax.crypto.SecretKeyFactory" %>

<%@ page import="javax.crypto.spec.DESKeySpec" %>
<%@ page import="javax.crypto.spec.IvParameterSpec" %>
<%@ page import="java.math.BigInteger" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.security.Security" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.fapiao.neon.util.Base64Utils" %>
<%@ page import="biweekly.util.org.apache.commons.codec.binary.Base64" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ include file="/systeminfo/init_wev8.jsp" %>

<%
    // 单点报表管理系统
    BaseBean baseBean = new BaseBean();

    try {
        String userCode = user.getLoginid();
        String timeStamp = TimeUtil.getCurrentTimeString();
        String key = "a1234567";
        String loginCredence = getMD5(String.format("%s;%s", userCode, timeStamp));
        String content = String.format("%s;%s;%s", userCode, timeStamp, loginCredence);

        byte[] contentBytes = content.getBytes(DEFAULT_ENCODING);
        byte[] keyBytes = key.getBytes(DEFAULT_ENCODING);
        byte[] result = DESEncrypt(contentBytes, keyBytes, keyBytes);
        //请求的userKey值
        Base64 base64 = new Base64();
        String requestKey = new String(base64.encode(result), StandardCharsets.UTF_8);
        String url = "https://192.168.133.170/static/managerTool/index.html?groupCode=EMSETUP#/login?userKey=" + requestKey +
                "&source=OA&tenant_code=ccbc";
        baseBean.writeLog("单点报表管理系统url： "+ url);
        response.sendRedirect(url);
    } catch (Exception e) {
        baseBean.writeLog("单点报表管理异常： " + e);
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
            MessageDigest md = MessageDigest.getInstance("MD5");
            md.update(str.getBytes());
            return new BigInteger(1, md.digest()).toString(16);
        } catch (Exception e) {
            throw new RuntimeException("MD5加密出现错误");
        }
    }
%>


