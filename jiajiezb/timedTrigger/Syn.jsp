<%@ taglib prefix="wea" uri="http://www.weaver.com.cn" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<jsp:useBean id="RequestManager" class="weaver.workflow.request.RequestManager" scope="page"/>
<jsp:useBean id="flowDocss" class="weaver.workflow.request.RequestDoc" scope="session"/>
<jsp:useBean id="DocComInfo" class="weaver.docs.docs.DocComInfo" scope="page"/>
<jsp:useBean id="Doccoder" class="weaver.docs.docs.DocCoder" scope="page"/>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<script type="text/javascript" language="javascript" src="/FCKEditor/FCKEditorExt_wev8.js"></script>
<html>
<script src="/workflow/request/testJsp/shauter_wev8.js"></script>
<h3 style="margin-left: 23px">手动触发提醒流程</h3>
<wea:layout type="2col">
    <wea:group context="选择同步范围">
        <wea:item>选择触发流程</wea:item>
        <wea:item>
            <select id="tongBu">
                <option value="1">JT_试用期转正提醒</option>
                <option value="2">JT_转正提醒</option>
            </select>
        </wea:item>

    </wea:group>

    <!-- 查询 重置 取消 按钮 -->
    <wea:group context="">
        <wea:item type="toolbar">
            <input id="myInput" type="button" value="触发" class="e8_btn_submit" onclick="onBtnSearchClick();"/>
        </wea:item>
    </wea:group>

</wea:layout>

<script type="text/javascript">

    function onBtnSearchClick() {
        var myType = $("#tongBu").val();
        $.ajax({
            type: "post",
            url: "/workflow/request/jiajiezb/timedTrigger/Trigger.jsp",
            cache: false,
            async: true,
            timeout: 1000,
            data: {"id": myType},
            success: function (data) {

            },
            complete: function (XMLHttpRequest, status) {
                window.top.Dialog.alert("后台触发中...");
            }
        });
    }

</script>


</html>



