<%@ page import="com.alibaba.fastjson.JSONArray" %>
<%@ page import="com.alibaba.fastjson.JSONObject" %>

<%@ page import="com.weavernorth.bjcj.vo.BjcjHrmSubCompany" %>
<%@ page import="weaver.conn.ConnStatement" %>
<%@ page import="weaver.conn.RecordSet" %>
<%@ page import="weaver.general.BaseBean" %>
<%@ page import="weaver.general.TimeUtil" %>
<%@ page import="weaver.general.Util" %>
<%@ page import="weaver.hrm.company.SubCompanyComInfo" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%
    BaseBean baseBean = new BaseBean();
    // 分部同步
    baseBean.writeLog("分部同步 Start ========================= " + TimeUtil.getCurrentTimeString());
    try {
        long start = System.currentTimeMillis();
        String json = getPostData(request.getReader());
        baseBean.writeLog("接收到HR分部数据 ========= " + json);
        JSONArray jsonArray = JSONObject.parseArray(json);
        int allCount = jsonArray.size();
        baseBean.writeLog("接收分部数量: " + allCount);
        List<BjcjHrmSubCompany> subCompanyList = jsonArray.toJavaList(BjcjHrmSubCompany.class);

        int departmentErrorCount = 1;
        for (int i = 0; i < 3; i++) {
            if (departmentErrorCount > 0) {
                subCompanyList = synSubCompany(subCompanyList, i);
                departmentErrorCount = subCompanyList.size();
                baseBean.writeLog("待插入分部数量： " + departmentErrorCount);
            }
        }

        // 清空分部缓存
        new SubCompanyComInfo().removeCompanyCache();

        // 结束时间戳
        long end = System.currentTimeMillis();
        long cha = (end - start) / 1000;

        String logStr = "分部信息同步完成，同步数量： " + allCount + ", 耗时：" + cha + " 秒。";
        baseBean.writeLog(logStr);
        JSONObject jsonObjectAll = new JSONObject(true);
        jsonObjectAll.put("AllCount", allCount);
        jsonObjectAll.put("errorCount", subCompanyList.size());
        jsonObjectAll.put("errList", subCompanyList);

        baseBean.writeLog("返回的json： " + jsonObjectAll.toJSONString());

        response.setHeader("Content-Type", "application/json;charset=UTF-8");
        out.clear();
        out.print(jsonObjectAll.toJSONString());

    } catch (Exception e) {
        baseBean.writeLog("分部同步异常： " + e);
    }

%>

<%!

    private List<BjcjHrmSubCompany> synSubCompany(List<BjcjHrmSubCompany> subCompanyList, int count) {
        BaseBean baseBean = new BaseBean();
        baseBean.writeLog("第 " + count + " 次执行分部同步=========================");
        // sunCompanyCode - id map
        Map<String, String> numIdMap = new HashMap<>();
        RecordSet recordSet = new RecordSet();
        recordSet.executeQuery("select id, subcompanycode from hrmsubcompany");
        while (recordSet.next()) {
            if (!"".equals(recordSet.getString("subcompanycode"))) {
                numIdMap.put(recordSet.getString("subcompanycode"), recordSet.getString("id"));
            }
        }

        List<BjcjHrmSubCompany> insertHrmDepartments = new ArrayList<>();
        List<BjcjHrmSubCompany> updateHrmDepartments = new ArrayList<>();
        List<BjcjHrmSubCompany> errorHrmDepartments = new ArrayList<>();
        for (BjcjHrmSubCompany subCompany : subCompanyList) {
            // 分部编码
            String subCode = Util.null2String(subCompany.getSubCode()).trim();
            // 上级编码
            String supperCode = Util.null2String(subCompany.getSupperCode()).trim();
            // 分部状态 1封存，0代表有效
            String status = Util.null2String(subCompany.getStatus()).trim();

            baseBean.writeLog("==========================");
            baseBean.writeLog("分部编码： " + subCode + ", 上级编码： " + supperCode);
            baseBean.writeLog("分部名称： " + subCompany.getSubName() + ", sap分部状态： " + subCompany.getStatus());
            baseBean.writeLog("转换后分部状态： " + status);
            baseBean.writeLog("分部顺序： " + subCompany.getShowOrder());

            if ("".equals(subCode)) {
                String errMes = "分部编码为空，上级编码： " + supperCode + "分部名称： " + subCompany.getSubName();
                baseBean.writeLog(errMes);
                subCompany.setErrMessage(errMes);
                errorHrmDepartments.add(subCompany);
                continue;
            }
            if ("".equals(supperCode)) {
                String errMes = "分部编上级编码为空，分部编码： " + subCode + "分部名称： " + subCompany.getSubName();
                baseBean.writeLog(errMes);
                subCompany.setErrMessage(errMes);
                errorHrmDepartments.add(subCompany);
                continue;
            }
            if ("".equals(subCompany.getSubName())) {
                String errMes = "分部名称为空，分部编码： " + subCode + "上级编码： " + supperCode;
                baseBean.writeLog(errMes);
                subCompany.setErrMessage(errMes);
                errorHrmDepartments.add(subCompany);
                continue;
            }

            int subCompanyId = Util.getIntValue(numIdMap.get(supperCode), 0);
            if (!"0".equals(supperCode) && subCompanyId <= 0) {
                if (count >= 2) {
                    String errMes = "上级分部不存在 - 分部编码 - " + subCode + " - 分部名称 - " + subCompany.getSubName();
                    //第3次仍有错误，插入错误信息
                    baseBean.writeLog(errMes);
                    subCompany.setErrMessage(errMes);
                    errorHrmDepartments.add(subCompany);
                }
                errorHrmDepartments.add(subCompany);
                continue;
            }

            subCompany.setSupperSubId(String.valueOf(subCompanyId));
            if (numIdMap.get(subCode) == null) {
                insertHrmDepartments.add(subCompany);
                numIdMap.put(subCode, "1");
            } else {
                updateHrmDepartments.add(subCompany);
            }

            insertHrmSubCompany(insertHrmDepartments);
            updateHrmSubCompany(updateHrmDepartments);
        }

        // 清空map缓存
        clearMap(numIdMap);
        return errorHrmDepartments;
    }

    private void insertHrmSubCompany(List<BjcjHrmSubCompany> insertHrmDepartments) {
        BaseBean baseBean = new BaseBean();
        ConnStatement statement = new ConnStatement();
        try {
            String sql = "insert into hrmsubcompany (subcompanyname, subcompanydesc, supsubcomid, canceled, showorder, " +
                    "subcompanycode, companyid )values (?,?,?,?,?, ?,?)";
            statement.setStatementSql(sql);
            for (BjcjHrmSubCompany subCompany : insertHrmDepartments) {
                baseBean.writeLog(subCompany.toString());
                statement.setString(1, subCompany.getSubName());
                statement.setString(2, subCompany.getSubName());
                statement.setString(3, subCompany.getSupperSubId());
                statement.setString(4, subCompany.getStatus());
                statement.setString(5, subCompany.getShowOrder());

                statement.setString(6, subCompany.getSubCode());
                statement.setString(7, "1"); // 所属总部id

                statement.executeUpdate();
            }

        } catch (Exception e) {
            new BaseBean().writeLog("insert hrmsubcompany Exception :" + e);
        } finally {
            statement.close();
            // 插入分部权限
            RecordSet recordSet = new RecordSet();
            for (BjcjHrmSubCompany subCompany : insertHrmDepartments) {
                recordSet.executeQuery("select id from hrmsubcompany where subcompanycode = ?", subCompany.getSubCode());
                if (recordSet.next()) {
                    insertMenuConfig(recordSet.getString("id"));
                }
            }
        }

    }

    /**
     * 更新分部
     */
    private static void updateHrmSubCompany(List<BjcjHrmSubCompany> subCompanyList) {

        ConnStatement statement = new ConnStatement();
        try {
            String sql = "update hrmsubcompany set  subcompanyname = ?, subcompanydesc = ?, supsubcomid = ?, canceled = ?," +
                    " showorder = ? where subcompanycode = ?";
            statement.setStatementSql(sql);
            for (BjcjHrmSubCompany hrmSubCompany : subCompanyList) {
                new BaseBean().writeLog(hrmSubCompany.toString());
                statement.setString(1, hrmSubCompany.getSubName());
                statement.setString(2, hrmSubCompany.getSubName());
                statement.setString(3, hrmSubCompany.getSupperSubId());
                statement.setString(4, hrmSubCompany.getStatus());
                statement.setString(5, hrmSubCompany.getShowOrder());

                statement.setString(6, hrmSubCompany.getSubCode());

                statement.executeUpdate();
            }
        } catch (Exception e) {
            new BaseBean().writeLog("update hrmsubcompany Exception :" + e);
        } finally {
            statement.close();
        }

    }

    private static String getPostData(BufferedReader reader) throws Exception {
        StringBuilder stringBuilder = new StringBuilder();
        String str;
        while ((str = reader.readLine()) != null) {
            stringBuilder.append(str);
        }
        return new String(stringBuilder).replaceAll("\\s*", "");
    }

    private void insertMenuConfig(String id) {
        RecordSet rs = new RecordSet();
        rs.executeUpdate("insert into leftmenuconfig (userid,infoid,visible,viewindex,resourceid,resourcetype,locked,lockedbyid,usecustomname,customname,customname_e)  select  distinct  userid,infoid,visible,viewindex," + id + ",2,locked,lockedbyid,usecustomname,customname,customname_e from leftmenuconfig  where resourcetype=1  and resourceid=1");
        rs.executeUpdate("insert into mainmenuconfig (userid,infoid,visible,viewindex,resourceid,resourcetype,locked,lockedbyid,usecustomname,customname,customname_e)  select  distinct  userid,infoid,visible,viewindex," + id + ",2,locked,lockedbyid,usecustomname,customname,customname_e from mainmenuconfig where resourcetype=1  and resourceid=1");

    }

    private void clearMap(Map... maps) {
        for (Map map : maps) {
            if (map != null) {
                map.clear();
            }
        }
    }

%>