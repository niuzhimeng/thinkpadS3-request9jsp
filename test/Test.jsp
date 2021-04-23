//点击按钮：需要先计算平均值赋值给 pjbj ，然后汇总数据给明细表6

<script type="text/javascript">
    var dwsl = 'field15570'; // 询比价单位数量
    var bjje = 'field15556'; // 报价金额
    var gysmc = 'field15689'; // 供应商名称
    var gsje = 'field15506';// 概算金额
    var pjbj = 'field15672';//平均报价

    var zja = 'field15508'; // 总价a
    var zjb = 'field15510'; // 总价b
    var zjc = 'field15512'; // 总价c
    var zjd = 'field15514'; // 总价d
    var zje = 'field15516'; // 总价e

    var zjf = 'field15662'; // 总价f
    var zjg = 'field15663'; // 总价g
    var zjh = 'field15664'; // 总价h
    var zji = 'field15665'; // 总价i
    var zjj = 'field15666'; // 总价j

    var zjsz = [zja, zjb, zjc, zjd, zje,
        zjf, zjg, zjh, zji, zjj];

    var config = {
        '1': 'field15508', // 总价a
        '2': 'field15510', // 总价b
        '3': 'field15512', // 总价c
        '4': 'field15514', // 总价d
        '5': 'field15516', // 总价e

        '6': 'field15662', // 总价f
        '7': 'field15663', // 总价g
        '8': 'field15664', // 总价h
        '9': 'field15665', // 总价i
        '10': 'field15666', // 总价j
    };

    var configName = {
        '1': 'field15576', // 供应商名称a
        '2': 'field15577', // 供应商名称b
        '3': 'field15578', // 供应商名称c
        '4': 'field15579', // 供应商名称d
        '5': 'field15580', // 供应商名称e

        '6': 'field15652', // 供应商名称f
        '7': 'field15654', // 供应商名称g
        '8': 'field15656', // 供应商名称h
        '9': 'field15658', // 供应商名称i
        '10': 'field15660', // 供应商名称j
    };

    // 黄色明细表字段
    var mxbNum6 = 'submitdtlid5'; // 明细表6
    var cxgys = 'field15673'; // 参选供应商

    jQuery(document).ready(function () {
        appendButton();
    });

    function newButton() {
        myJs();
        // 增加黄色明细表行数
        var dwslVal = Number($("#" + dwsl).val()) + 1;
        // 查询当前明细行
        var currentRows;
        var mxbObj = $("#" + mxbNum6);
        var mxbObjVal = mxbObj.val();
        if (mxbObjVal === '') {
            currentRows = 0;
        } else {
            currentRows = mxbObj.val().split(",").length;
        }

        for (var j = 0; j < dwslVal; j++) {
            addRow5(5);
        }
        var currentMxs = mxbObj.val().split(",");
        var gysmcNum = 1;
        for (var i = 0; i < dwslVal; i++) {
            $("#" + cxgys + '_' + currentMxs[currentRows]).val(gysmcNum);
            //添加概算金额赋值
            //添加平均报价赋值
            $("#" + bjje + '_' + currentMxs[currentRows]).val($("#" + config[gysmcNum.toString()]).val());

            var gysRel = $("#" + configName[gysmcNum.toString()]).val();
            $("#" + gysmc + '_' + currentMxs[currentRows]).val(gysRel);
            $("#" + gysmc + '_' + currentMxs[currentRows] + 'span').html($("#" + configName[gysmcNum.toString()] + 'span').children('a').clone());

            gysmcNum++;
            currentRows++;
        }
    }

    function appendButton() {
        jQuery("#collect").append("<input id=\"collect\" type=\"button\" value=\"报价数据汇总\" onclick=\"newButton();\" class=\"e8_btn_top_first\">");
    }

    // 计算平均值
    function myJs() {
        var sl = Number($("#" + dwsl).val()) + 1; // 选择客户的数量
        var allCont = 0; // 供应商价格总和
        var count0 = 0;
        for (var i = 0; i < sl; i++) {
            var curVVal = $("#" + zjsz[i]).val() * 100;
            if (curVVal == 0) {
                count0++;
            }
            allCont += curVVal;
        }
        var pjs = 0; // 平均值
        if (allCont > 0) {
            allCont = allCont / 100;
            sl -= count0;
            pjs = (allCont / sl).toFixed(2);
        }
        $("#" + pjbj).val(pjs);
        $("#" + pjbj + 'span').html(pjs);
    }

    $.post("/workflow/request/zhongsha/ZhongShaBack.jsp", {
        "message": message
    }, function (data) {
        var data = data.replace(/\s+/g, "");
        var datas = data.split(',');

        jQuery('#' + sqjemx).val(datas[0]);
        jQuery('#' + spjb).val(datas[1]);
        jQuery('#' + gljy).val(datas[2]);

    });
</script>


