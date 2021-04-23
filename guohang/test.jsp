<script type="text/javascript">
    var ryid = ModeForm.convertFieldNameToId("ry");
    $(function () {
        window.checkCustomize = () => {
           alert('阻止提交')
            return false;    //同步提交
        }

        ModeForm.bindFieldChangeEvent(ryid, (obj, id, value) => {
            console.log("WfForm.bindFieldChangeEvent--", obj, id, value);
        });
    })

</script>

