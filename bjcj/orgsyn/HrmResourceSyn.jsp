<%@ page import="com.alibaba.fastjson.JSONArray" %>
<%@ page import="com.alibaba.fastjson.JSONObject" %>

<%@ page import="weaver.conn.ConnStatement" %>
<%@ page import="weaver.conn.RecordSet" %>
<%@ page import="weaver.general.BaseBean" %>
<%@ page import="weaver.general.TimeUtil" %>
<%@ page import="weaver.general.Util" %>
<%@ page import="weaver.hrm.resource.ResourceComInfo" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.weavernorth.bjcj.vo.BjcjHrmResource" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%

    BaseBean baseBean = new BaseBean();
    // 人员同步
    baseBean.writeLog("人员同步 Start ========================= " + TimeUtil.getCurrentTimeString());
    try {
        String json = getPostData(request.getReader());
        baseBean.writeLog("接收到人员数据 ========= " + json);
        JSONArray jsonArray = JSONObject.parseArray(json);
        int allCount = jsonArray.size();
        baseBean.writeLog("接收人员数量: " + allCount);
        List<BjcjHrmResource> HrmResourceList = jsonArray.toJavaList(BjcjHrmResource.class);

        // 错误人员数据信息
        List<BjcjHrmResource> errHrmResourceList = synHrmResource(HrmResourceList);

        JSONObject jsonObjectAll = new JSONObject(true);
        jsonObjectAll.put("AllCount", allCount);
        jsonObjectAll.put("errorCount", errHrmResourceList.size());
        jsonObjectAll.put("errList", errHrmResourceList);

        baseBean.writeLog("返回的xml： " + jsonObjectAll.toJSONString());
        baseBean.writeLog("人员同步 END ========================= ");

        response.setHeader("Content-Type", "application/json;charset=UTF-8");
        out.clear();
        out.print(jsonObjectAll.toJSONString());


    } catch (Exception e) {
        baseBean.writeLog("人员同步异常： " + e);
    }

%>

<%!

    private List<BjcjHrmResource> synHrmResource(List<BjcjHrmResource> resourceList) {
        List<BjcjHrmResource> errHrmResourceList = new ArrayList<>();
        BaseBean baseBean = new BaseBean();
        try {
            // departmentCode - id map
            Map<String, String> depIdMap = new HashMap<>();
            RecordSet recordSet = new RecordSet();
            recordSet.executeQuery("select id, departmentcode from HrmDepartment");
            while (recordSet.next()) {
                if (!"".equals(recordSet.getString("departmentcode"))) {
                    depIdMap.put(recordSet.getString("departmentcode"), recordSet.getString("id"));
                }
            }

            // 部门 - id 所属分部id
            Map<Integer, Integer> idSubIdMap = new HashMap<>();
            recordSet.executeQuery("select id, subcompanyid1 from hrmdepartment");
            while (recordSet.next()) {
                if (!"".equals(recordSet.getString("subcompanyid1"))) {
                    idSubIdMap.put(recordSet.getInt("id"), recordSet.getInt("subcompanyid1"));
                }
            }

            // 岗位编码 - 岗位id
            Map<String, String> jobCodeIdMap = new HashMap<>();
            recordSet.executeQuery("select id, jobtitlecode from hrmjobtitles");
            while (recordSet.next()) {
                if (!"".equals(recordSet.getString("jobtitlecode"))) {
                    jobCodeIdMap.put(recordSet.getString("jobtitlecode"), recordSet.getString("id"));
                }
            }

            // 根据【身份证】判断人员是否存在
            List<String> existList = new ArrayList<>();
            recordSet.executeQuery("select certificatenum from hrmresource");
            while (recordSet.next()) {
                if (!"".equals(recordSet.getString("certificatenum"))) {
                    existList.add(recordSet.getString("certificatenum"));
                }
            }

            List<BjcjHrmResource> insertHrmResource = new ArrayList<>();
            List<BjcjHrmResource> updateHrmResource = new ArrayList<>();
            for (BjcjHrmResource hrmResource : resourceList) {
                // 身份证号码（唯一标识）
                String certificatenum = Util.null2String(hrmResource.getCertificatenum()).trim();
                // 岗位编码
                String jobtitlecode = Util.null2String(hrmResource.getJobtitlecode()).trim();
                // 登录名
                String loginId = Util.null2String(hrmResource.getLoginid()).trim();
                // 所属部门编码
                String depCode = Util.null2String(hrmResource.getDepcode()).trim();
                // 员工状态（Y在职，N离职，R退休）
                String mhStatus = Util.null2String(hrmResource.getStatus()).trim();
                String statusOa = "1";
                if ("1".equals(mhStatus) || "2".equals(mhStatus) || "3".equals(mhStatus) || "7".equals(mhStatus) || "8".equals(mhStatus) || "9".equals(mhStatus)) {
                    statusOa = "1";
                } else if ("4".equals(mhStatus) || "5".equals(mhStatus)) {
                    statusOa = "0";
                } else if ("37".equals(mhStatus)) {
                    statusOa = "6";
                } else if ("38".equals(mhStatus)) {
                    statusOa = "5";
                } else if ("39".equals(mhStatus)) {
                    statusOa = "7";
                }

                // 性别（1男，2女）
                String sex = Util.null2String(hrmResource.getSex()).trim();
                String sexOa = "1";
                if ("1".equals(sex)) {
                    sexOa = "0";
                }
                // 工作地点
                String locationStr = Util.null2String(hrmResource.getLocation()).trim();
                if ("".equals(locationStr)) {
                    locationStr = "北京";
                }
                String locationId = insertLocation(locationStr);
                String telPhone = Util.null2String(hrmResource.getTelephone());

                baseBean.writeLog("========================");
                baseBean.writeLog("人员姓名： " + hrmResource.getLastname() + ", 身份证号码：" + certificatenum + ", 登录名： " + loginId);
                baseBean.writeLog("所属部门编码： " + depCode + ", hrStatus： " + mhStatus + ", 岗位编码： " + jobtitlecode);
                baseBean.writeLog("性别： " + sex + ", 工作地点： " + locationStr + ", 办公室电话: " + telPhone);

                //部门ID
                int depId = Util.getIntValue(depIdMap.get(depCode), 0);

                if ("".equals(certificatenum)) {
                    // 身份证号码为空
                    String errMsg = "人员【身份证号码】为空，部门code： " + depCode + " ,人员编码： " + hrmResource.getWorkcode() + ", 姓名： " + hrmResource.getLastname();
                    baseBean.writeLog(errMsg);
                    hrmResource.setErrMessage(errMsg);
                    errHrmResourceList.add(hrmResource);
                    continue;
                }
                if ("".equals(loginId)) {
                    // 登录名为空
                    String errMsg = "人员【登录名】为空，部门code： " + depCode + " ,人员编码： " + hrmResource.getWorkcode() + ", 姓名： " + hrmResource.getLastname();
                    baseBean.writeLog(errMsg);
                    hrmResource.setErrMessage(errMsg);
                    errHrmResourceList.add(hrmResource);
                    continue;
                }
                if ("".equals(Util.null2String(hrmResource.getLastname()).trim())) {
                    // 姓名为空
                    String errMsg = "人员【姓名】为空，部门code： " + depCode + " , 登录名： " + loginId + ", 姓名： " + hrmResource.getLastname();
                    baseBean.writeLog(errMsg);
                    hrmResource.setErrMessage(errMsg);
                    errHrmResourceList.add(hrmResource);
                    continue;
                }
                if (depId <= 0) {
                    //所属部门不存在
                    String errMsg = "人员所属【部门】不存在，部门code： " + depCode + " ,登录名： " + loginId + ", 姓名： " + hrmResource.getLastname();
                    baseBean.writeLog(errMsg);
                    hrmResource.setErrMessage(errMsg);
                    errHrmResourceList.add(hrmResource);
                    continue;
                }

                // 所属分部id
                int subId = idSubIdMap.get(depId);

                //默认密码
                hrmResource.setPassWord(Util.getEncrypt("123456"));
                hrmResource.setDepId(String.valueOf(depId));
                hrmResource.setSubId(String.valueOf(subId));
                hrmResource.setJobtitleId(jobCodeIdMap.get(jobtitlecode));
                hrmResource.setStatusOa(statusOa);

                hrmResource.setSexOa(sexOa);
                hrmResource.setLocationId(locationId);
                //账号类型
                hrmResource.setAccounttype("0");
                //语言类型
                hrmResource.setSystemlanguage("7");
                // 安全级别默认10
                hrmResource.setSeclevel("10");
                hrmResource.setTelephone(telPhone);

                if (!existList.contains(certificatenum)) {
                    String newId = String.valueOf(getHrmMaxId());
                    hrmResource.setId(newId);
                    insertHrmResource.add(hrmResource);
                    existList.add(certificatenum);
                } else {
                    updateHrmResource.add(hrmResource);
                }
            }

            baseBean.writeLog("新增人员数： " + insertHrmResource.size());
            insertHrmResource(insertHrmResource);

            baseBean.writeLog("更新人员数： " + updateHrmResource.size());
            updateHrmResource(updateHrmResource);
            // 清空人员缓存
            new ResourceComInfo().removeResourceCache();

            // 清空map缓存
            clearMap(depIdMap, idSubIdMap, jobCodeIdMap);
            existList.clear();
        } catch (Exception e) {
            baseBean.writeLog("人员同步synHrmResource异常： " + e);
        }
        return errHrmResourceList;
    }

    private int getHrmMaxId() {
        int maxID = 1;
        RecordSet rs = new RecordSet();
        try {
            rs.executeProc("HrmResourceMaxId_Get", "");
            if (rs.next()) {
                maxID = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return maxID;
    }

    private void insertHrmResource(List<BjcjHrmResource> insertHrmResourceList) {
        ConnStatement statement = new ConnStatement();
        try {
            String sql = "insert into hrmresource (workcode, lastname, loginid, status, sex," +
                    " locationid, email, mobile, managerid, seclevel, " +
                    "departmentid, subcompanyid1, jobtitle, dsporder, id," +
                    "password, accounttype, belongto, systemlanguage, telephone, " +
                    "startdate, certificatenum ) " +
                    "values (?,?,?,?,?,  ?,?,?,?,?,  ?,?,?,?,?,  ?,?,?,?,?, ?,?)";
            statement.setStatementSql(sql);
            int stnCount = 0;
            for (BjcjHrmResource hrmResource : insertHrmResourceList) {
                if (stnCount % 500 == 0) {
                    statement.close();
                    statement = new ConnStatement();
                    statement.setStatementSql(sql);
                }
                statement.setString(1, hrmResource.getWorkcode());
                statement.setString(2, hrmResource.getLastname());
                statement.setString(3, hrmResource.getLoginid());
                statement.setString(4, hrmResource.getStatusOa());
                statement.setString(5, hrmResource.getSexOa());

                statement.setString(6, hrmResource.getLocationId());
                statement.setString(7, hrmResource.getEmail());
                statement.setString(8, hrmResource.getPhone());
                statement.setString(9, hrmResource.getManagerIdReal());
                statement.setString(10, hrmResource.getSeclevel());

                statement.setString(11, hrmResource.getDepId());
                statement.setString(12, hrmResource.getSubId());
                statement.setString(13, hrmResource.getJobtitleId());
                statement.setString(14, hrmResource.getDsporder());
                statement.setString(15, hrmResource.getId());

                statement.setString(16, hrmResource.getPassWord());
                statement.setString(17, hrmResource.getAccounttype());
                statement.setString(18, hrmResource.getBelongto());
                statement.setString(19, hrmResource.getSystemlanguage());
                statement.setString(20, hrmResource.getTelephone());

                statement.setString(21, hrmResource.getStartdate());
                statement.setString(22, hrmResource.getCertificatenum());

                statement.executeUpdate();
                hrmResource.updaterights(hrmResource.getId());
                stnCount++;
            }
        } catch (Exception e) {
            new BaseBean().writeLog("insert HrmResource Exception :" + e);
        } finally {
            statement.close();
        }
    }

    private void updateHrmResource(List<BjcjHrmResource> updateHrmResourceList) {

        ConnStatement statement = new ConnStatement();
        try {
            String sql = "update hrmresource set lastname = ?, status = ?, sex = ?, locationid = ?, mobile = ?, " +
                    "departmentid = ?, subcompanyid1 = ?, email = ?, workcode = ?, telephone = ?, " +
                    "loginid = ?, jobtitle = ? where certificatenum = ?";
            statement.setStatementSql(sql);
            int stnCount = 0;
            for (BjcjHrmResource hrmResource : updateHrmResourceList) {
                if (stnCount % 500 == 0) {
                    statement.close();
                    statement = new ConnStatement();
                    statement.setStatementSql(sql);
                }
                statement.setString(1, hrmResource.getLastname());
                statement.setString(2, hrmResource.getStatusOa());
                statement.setString(3, hrmResource.getSexOa());
                statement.setString(4, hrmResource.getLocationId());
                statement.setString(5, hrmResource.getPhone());

                statement.setString(6, hrmResource.getDepId());
                statement.setString(7, hrmResource.getSubId());
                statement.setString(8, hrmResource.getEmail());
                statement.setString(9, hrmResource.getWorkcode());
                statement.setString(10, hrmResource.getTelephone());

                statement.setString(11, hrmResource.getLoginid());
                statement.setString(12, hrmResource.getJobtitleId());
                statement.setString(13, hrmResource.getCertificatenum());

                statement.executeUpdate();
                stnCount++;
            }
        } catch (Exception e) {
            new BaseBean().writeLog("update HrmResource Exception :" + e);
        } finally {
            statement.close();
        }
    }

    private String insertLocation(String locationname) {
        if (null == locationname || "".equals(locationname)) {
            return "";
        }
        String locationId = locationIsRepeat(locationname);

        if ("".equals(locationId)) {
            RecordSet rs = new RecordSet();
            rs.executeUpdate("insert into HrmLocations(locationname,locationdesc,countryid) values ('" + locationname + "','" + locationname + "','0')");
            rs.executeQuery("select max(id) as id from HrmLocations");
            if (rs.next()) {
                locationId = Util.null2String(rs.getString("id"));
            }
        }
        return locationId;
    }

    private String locationIsRepeat(String locationname) {
        String locationId = "";
        try {
            RecordSet rs = new RecordSet();
            rs.executeQuery("select id from HrmLocations where locationname = '" + locationname + "'");
            if (rs.next()) {
                locationId = Util.null2String(rs.getString("id"));
            }
        } catch (Exception e) {
            new BaseBean().writeLog("check location is Repeat Exception" + e);
        }
        return locationId;
    }

    private static String getPostData(BufferedReader reader) throws Exception {
        StringBuilder stringBuilder = new StringBuilder();
        String str;
        while ((str = reader.readLine()) != null) {
            stringBuilder.append(str);
        }
        return new String(stringBuilder).replaceAll("\\s*", "");
    }

    private void clearMap(Map... maps) {
        for (Map map : maps) {
            if (map != null) {
                map.clear();
            }
        }
    }

%>