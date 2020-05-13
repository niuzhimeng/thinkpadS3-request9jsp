<%@ page import="com.alibaba.fastjson.JSONArray" %>
<%@ page import="com.alibaba.fastjson.JSONObject" %>

<%@ page import="com.weavernorth.bjcj.vo.BjcjHrmJobTitle" %>
<%@ page import="weaver.conn.ConnStatement" %>
<%@ page import="weaver.conn.RecordSet" %>
<%@ page import="weaver.general.BaseBean" %>
<%@ page import="weaver.general.TimeUtil" %>
<%@ page import="weaver.hrm.job.JobTitlesComInfo" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%
    String jobActivityId = "14"; // 所属职务id
    BaseBean baseBean = new BaseBean();
    // 岗位同步
    baseBean.writeLog("岗位同步 Start ========================= " + TimeUtil.getCurrentTimeString());
    try {
        long start = System.currentTimeMillis();
        String json = getPostData(request.getReader());
        baseBean.writeLog("接收到HR岗位数据 ========= " + json);
        JSONArray jsonArray = JSONObject.parseArray(json);
        int allCount = jsonArray.size();
        baseBean.writeLog("接收岗位数量: " + allCount);
        List<BjcjHrmJobTitle> subJobTitleList = jsonArray.toJavaList(BjcjHrmJobTitle.class);

        synJobTitle(subJobTitleList, jobActivityId);

        // 清空岗位缓存
        new JobTitlesComInfo().removeJobTitlesCache();

        // 结束时间戳
        long end = System.currentTimeMillis();
        long cha = (end - start) / 1000;

        String logStr = "岗位信息同步完成，同步数量： " + allCount + ", 耗时：" + cha + " 秒。";
        baseBean.writeLog(logStr);
        JSONObject jsonObjectAll = new JSONObject(true);
        jsonObjectAll.put("AllCount", allCount);
        jsonObjectAll.put("errorCount", 0);
        jsonObjectAll.put("errList", Collections.EMPTY_LIST);

        baseBean.writeLog("返回的json： " + jsonObjectAll.toJSONString());

        response.setHeader("Content-Type", "application/json;charset=UTF-8");
        out.clear();
        out.print(jsonObjectAll.toJSONString());
    } catch (Exception e) {
        baseBean.writeLog("岗位同步异常： " + e);
    }

%>

<%!

    private void synJobTitle(List<BjcjHrmJobTitle> subCompanyList, String jobActivityId) {
        // 岗位code - id map
        Map<String, String> numIdMap = new HashMap<>();
        RecordSet recordSet = new RecordSet();
        recordSet.executeQuery("select id, jobtitlecode from hrmjobtitles");
        while (recordSet.next()) {
            if (!"".equals(recordSet.getString("jobtitlecode"))) {
                numIdMap.put(recordSet.getString("jobtitlecode"), recordSet.getString("id"));
            }
        }

        List<BjcjHrmJobTitle> insertHrmJobTitleList = new ArrayList<>();
        List<BjcjHrmJobTitle> updateHrmJobTitleList = new ArrayList<>();
        for (BjcjHrmJobTitle jobTitle : subCompanyList) {
            jobTitle.setJobActivityId(jobActivityId);
            if (numIdMap.get(jobTitle.getJobTitleCode()) == null) {
                insertHrmJobTitleList.add(jobTitle);
                numIdMap.put(jobTitle.getJobTitleCode(), "");
            } else {
                updateHrmJobTitleList.add(jobTitle);
            }
        }

        insertHrmSubCompany(insertHrmJobTitleList);
        updateHrmSubCompany(updateHrmJobTitleList);
        // 清空map缓存
        clearMap(numIdMap);

    }

    private void insertHrmSubCompany(List<BjcjHrmJobTitle> insertHrmDepartments) {
        BaseBean baseBean = new BaseBean();
        ConnStatement statement = new ConnStatement();
        try {
            String sql = "insert into hrmjobtitles (jobtitlename, jobtitlemark, jobactivityid, jobtitlecode )values (?,?,?,?)";
            statement.setStatementSql(sql);
            for (BjcjHrmJobTitle subCompany : insertHrmDepartments) {
                baseBean.writeLog(subCompany.toString());
                statement.setString(1, subCompany.getJobTitleName());
                statement.setString(2, subCompany.getJobTitleName());
                statement.setString(3, subCompany.getJobActivityId());
                statement.setString(4, subCompany.getJobTitleCode());

                statement.executeUpdate();
            }
        } catch (Exception e) {
            new BaseBean().writeLog("insert hrmjobtitles Exception :" + e);
        } finally {
            statement.close();
        }

    }

    /**
     * 更新岗位
     */
    private static void updateHrmSubCompany(List<BjcjHrmJobTitle> jobTitleList) {
        ConnStatement statement = new ConnStatement();
        try {
            String sql = "update hrmjobtitles set  jobtitlemark = ?, jobtitlename = ? where jobtitlecode = ?";
            statement.setStatementSql(sql);
            for (BjcjHrmJobTitle jobTitle : jobTitleList) {
                new BaseBean().writeLog(jobTitle.toString());
                statement.setString(1, jobTitle.getJobTitleName());
                statement.setString(2, jobTitle.getJobTitleName());
                statement.setString(3, jobTitle.getJobTitleCode());
                statement.executeUpdate();
            }
        } catch (Exception e) {
            new BaseBean().writeLog("update hrmjobtitles Exception :" + e);
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

    private void clearMap(Map... maps) {
        for (Map map : maps) {
            if (map != null) {
                map.clear();
            }
        }
    }

%>