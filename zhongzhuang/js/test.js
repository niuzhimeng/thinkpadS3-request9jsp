let zgldId = WfForm.convertFieldNameToId("zgld"); // 主办主管领导
let cbzgldId = WfForm.convertFieldNameToId("cbzgld"); // 从办主管领导

let cbbmfzrId = WfForm.convertFieldNameToId("cbbmfzr"); // 承办部门负责人

myChangeFieldAttr = () => {

    let {f_weaver_belongto_userid: currentUserId} = WfForm.getBaseInfo();

    let cbzgldIdVal = WfForm.getFieldValue(cbzgldId).split(',');
    let zgldIdVal = WfForm.getFieldValue(zgldId).split(',');

    cbzgldIdVal = cbzgldIdVal.filter(item => zgldIdVal.indexOf(item) === -1);

    console.log(`筛选后从办： ${cbzgldIdVal}`)

    if (cbzgldIdVal.indexOf(currentUserId) > 0) {
        WfForm.changeFieldAttr(cbbmfzrId, 1);
    }
    WfForm.registerCheckEvent(WfForm.OPER_SUBMIT, (callback) => {
        jQuery("#field27495").val("保存自动赋值");
        callback();    //继续提交需调用callback，不调用代表阻断
    });
    WeaTools.callApi('/json/datalist.json', 'GET', {}).then(data => {
        this.setState({
            myData: data.datalsit,
        })
    });
}

myChangeFieldAttr();