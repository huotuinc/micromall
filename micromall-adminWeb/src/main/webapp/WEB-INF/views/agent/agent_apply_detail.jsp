<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 2015/5/25
  Time: 19:57
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <link href="<c:url value="/resources/css/houtaikk.css"/>" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="<c:url value="/resources/css/common.css"/>">
    <script type="text/javascript" src="<c:url value="/resources/scripts/jquery-1.7.2.min.js" />"></script>
    <script type="text/javascript" src="<c:url value="/resources/scripts/jquery.utils.js" />"></script>
    <script type="text/javascript" src="<c:url value="/resources/scripts/jQuery.md5.js" />"></script>
    <script type="text/javascript" src="<c:url value="/resources/scripts/jBox/jquery.jBox-2.3.min.js" />"></script>
    <link rel="stylesheet" type="text/css" href="<c:url value="/resources/scripts/jBox/Skins/Green/jbox.css"/>">
    <script type="text/javascript" src="<c:url value="/resources/scripts/jqueryui/jquery-ui-1.8.20.min.js" />"></script>
    <link rel="stylesheet" type="text/css" href="<c:url value="/resources/scripts/jqueryui/jquery-ui-1.10.3.custom.min.css"/>">
    <title>编辑商品</title>
    <script type="text/javascript">
        var ajaxUrl = "<c:url value="/agentApi/" />";
        var superAgentCount = 0;
        var superLevelCount = 0;
        var superGroup = "all";
        $(function () {
            $("#confirmBtn").click(function () {
                $("#tipSpan").html("通过理由");
                $(".levelLi").show();
                $("#applyStatus").val(1);
                J.ShowDialog("apply_dialog", "审核", function () {
                    var applyStatus = $("#applyStatus").val();
                    var levelId = $("#agentLevel").val();
                    var superAgent = $("#superAgent").val();
                    var refuseReason = $("#refuseReason").val();
                    var mobile = "${applyBean.mobile}";

                    if (applyStatus == 1) {
                        if (levelId == 0) {
                            $.jBox.tip("请选择代理商等级");
                            return;
                        }
                        if (superLevelCount > 0 && superAgent == 0) {
                            $.jBox.tip("请选择上级代理");
                            return;
                        }
                    }

                    var groups = "";
                    if ($("#checkAll").attr("checked")) {
                        groups = "all";
                    } else {
                        var $chkDom = $("input[name='chkGroup']:checked");
                        $chkDom.each(function () {
                            groups += $(this).val() + "|";
                        })
                        groups = "|" + groups;
                    }
                    if (groups.length == 0) {
                        $.jBox.tip("请选择分组");
                        return null;
                    }

                    if (refuseReason.length == 0) {
                        $.jBox.tip("请输入理由");
                        return;
                    }
                    $.jBox.tip("正在提交", "loading");
                    var requestData = {
                        mobile: mobile,
                        password: $.md5(mobile.substring(5)),
                        applyId:${applyId},
                        levelId: levelId,
                        superAgentId: superAgent,
                        applyStatus: applyStatus,
                        refuseReason: refuseReason,
                        groups: groups
                    };

                    J.GetJsonRespons(ajaxUrl + "applyAgent", requestData, function (json) {
                        if (json.result == 1) {
                            $.jBox.tip("操作成功", "success");
                            window.location.reload();
                        } else if (json.result == 2) {
                            $.jBox.tip("该手机号码已经是代理商", "error");
                        } else {
                            $.jBox.tip("操作失败", "error");
                        }
                    }, function () {
                    }, J.PostMethod);
                }, function () {
                    $(this).dialog("close");
                }, J.PostMethod);
            });

            $("#agentLevel").change(function () {
                resetSuper();
                resetGroup();
                getSuperLevel($(this).val(), 0);
            });

            $("#superLevel").change(function () {
                resetGroup();
                getSuperAgent($(this).val(), 0);
            });

            $("#superAgent").change(function () {
                resetGroup();
                superGroup = $(this).find("option:selected").attr("group-data");
                if (superGroup == "all") {
                    $("#checkAll").attr("checked", "checked");
                    $("#checkAll").change();
                } else {
                    var groupArray = superGroup.substring(1, superGroup.length - 1).split("|");
                    $.each(groupArray, function (o, item) {
                        $("input[name='chkGroup'][value='" + item + "']").attr("checked", "checked");
                    });
                }
            });

            $("#applyStatus").change(function () {
                if ($(this).val() == 1) {
                    $(".levelLi").show();
                    $("#tipSpan").html("通过理由");
                } else {
                    $(".levelLi").hide();
                    $("#tipSpan").html("拒绝理由");
                }
            });

            $("#checkAll").change(function () {
                if (superGroup != "all") {
                    $.jBox.tip("该代理商分组只能包含于选择的上级代理分组");
                    $(this).removeAttr("checked");
                    return;
                }
                $("input[name='chkGroup']").removeAttr("checked", "checked");
                if ($(this).attr("checked")) {
                    $("input[name='chkGroup']").attr("disabled", "disabled");
                } else {
                    $("input[name='chkGroup']").removeAttr("disabled");
                }
            });

            $("input[name='chkGroup']").change(function () {
                if (superGroup != "all") {
                    if (superGroup.indexOf("|" + $(this).val() + "|") == -1) {
                        $.jBox.tip("该代理商分组只能包含于选择的上级代理分组");
                        $(this).removeAttr("checked");
                        return;
                    }
                }
            });
        });

        function getSuperAgent(superLevel) {
            J.GetJsonRespons(ajaxUrl + "getSuperAgent", {
                superLevel: superLevel
            }, function (json) {
                var $dom = $("#superAgent");
                $dom.empty();
                $dom.append('<option value="0">请选择</option>');
                superAgentCount = json.list.length;
                $.each(json.list, function (o, item) {
                    $dom.append('<option group-data="' + item.groups + '" value="' + item.agentId + '">' + item.name + '</option>');
                });
            }, function () {
            }, J.PostMethod);
        }

        function getSuperLevel(levelId) {
            J.GetJsonRespons(ajaxUrl + "getSuperLevel", {
                levelId: levelId
            }, function (json) {
                var $dom = $("#superLevel");
                $dom.empty();
                $dom.append('<option value="0">请选择</option>');
                superLevelCount = json.levelList.length;
                $.each(json.levelList, function (o, item) {
                    $dom.append('<option value="' + item.levelId + '">' + item.levelName + '</option>');
                });
                if (superLevelCount == 0) {
                    $("#checkAll").attr("checked", "checked");
                    $("#checkAll").change();
                }
            }, function () {
            }, J.PostMethod);
        }

        function resetSuper() {
            $("#superLevel").html('<option value="0">请选择</option>');
            $("#superAgent").html('<option value="0">请选择</option>');
        }

        function resetGroup() {
            superGroup = "all";
            $("#checkAll").removeAttr("checked")
            $("input[name='chkGroup']").removeAttr("checked", "checked");
            $("input[name='chkGroup']").removeAttr("disabled");
        }
    </script>
</head>
<body style="background-color:#e4e7ea">
<div id="apply_dialog" style="padding: 20px;display: none;">
    <div class="cnt form">
        <!---->
        <form>
            <div class="waps-cpanel-content">
                <div class="waps-step-web plb5" style="width: 362px;">
                    <ul>
                        <li>
                            <span class="title"><i class="red">*</i>审核：</span>
                            <select id="applyStatus">
                                <option value="1">审核通过</option>
                                <option value="2">审核失败</option>
                            </select>
                        </li>
                        <li class="levelLi">
                            <span class="title"><i class="red">*</i>代理级别：</span>
                            <select id="agentLevel">
                                <option value="0">请选择</option>
                                <c:forEach items="${levelList}" var="levelBean" varStatus="index">
                                    <option value="${levelBean.levelId}" ${agentBean.agentLevel.levelId==levelBean.levelId?"selected='selected'":""}>${levelBean.levelName}
                                    </option>
                                </c:forEach>
                            </select>
                        </li>
                        <li class="levelLi">
                            <span class="title"><i class="red">*</i>上级代理：</span>
                            <select id="superLevel">
                                <option value="0">请选择</option>
                            </select>
                            <select id="superAgent">
                                <option value="0">请选择</option>
                            </select>
                        </li>
                        <li class="levelLi">
                            <span class="title"><i class="red">*</i>选择分组：</span>
                            <input value="0" id="checkAll" type="checkbox"/>全部
                            <c:forEach items="${groupList}" var="group">
                                &nbsp; &nbsp; &nbsp;<input name="chkGroup" type="checkbox" value="${group.groupId}"/>${group.groupName}
                            </c:forEach>
                        </li>
                        <li id="refuseLi">
                            <span class="title"><i class="red">*</i><span id="tipSpan">拒绝理由</span>：</span>
                            <textarea id="refuseReason" style="width: 303px;height: 117px;margin-top: 20px;padding: 10px;"></textarea>
                        </li>
                        <li>
                            <span style="color:red;" class="title">如审核通过，代理商登录密码为手机号码后6位</span>
                        </li>
                    </ul>
                </div>
            </div>
        </form>
    </div>
</div>
<div class="contentpanel">
    <div class="block">
        <div class="h">
            <p style="line-height:35px; padding-left:10px;"><i class="fa  fa-file-o"></i>申请详情</p>

        </div>
        <div class="cnt-wp">
            <div class="fg-button clearfix" style="float:right;display: block;" id="backBtn">
                <a href="javascript:window.location.href='<c:url value="/agent/applyAgentList" />'">返回审核列表</a>
            </div>
            <div class="cnt form">
                <!---->
                <form>
                    <div class="waps-cpanel-content">
                        <div class="waps-step-web plb5">
                            <ul>
                                <li>
                                    <span class="title">姓名：</span>
                                    <label>${applyBean.name}</label>
                                </li>
                                <li>
                                    <span class="title">手机号码：</span>
                                    <label>${applyBean.mobile}</label>
                                </li>
                                <li>
                                    <span class="title">微信号：</span>
                                    <label>${applyBean.weixin}</label>
                                </li>
                                <li>
                                    <span class="title">推荐人手机：</span>
                                    <label>${applyBean.referrer}</label>
                                </li>
                                <li>
                                    <span class="title">身份证号码：</span>
                                    <label>${applyBean.cardId}</label>
                                </li>
                                <li>
                                    <span class="title">手持身份证照片：</span>
                                    <label>
                                        <img style="width: 200px;height: 123px;" src="${uploadResourceServer.resourceUri(applyBean.cardIdImg)}"/>
                                    </label>
                                </li>
                                <li>
                                    <span class="title">从事微商时间：</span>
                                    <lable>${applyBean.workOnTime}</lable>
                                </li>
                                <li>
                                    <span class="title">月销售额：</span>
                                    <lable>${applyBean.saleAmount}</lable>
                                </li>
                                <li>
                                    <span class="title">经营品牌类目：</span>
                                    <label>${applyBean.workOnType}</label>
                                </li>
                                <li>
                                    <span class="title">所在地区：</span>
                                    <label>${applyBean.area}</label>
                                </li>
                                <li>
                                    <span class="title">审核状态：</span>
                                    <label>${applyBean.applyStatus==0?"待审核":applyBean.applyStatus==1?"审核通过":"审核失败"}</label>
                                </li>
                                <li>
                                    <span class="title">意向等级：</span>
                                    <label>${applyBean.applyLevelId>0?applyLevel.levelName:"未选择意向等级"}</label>
                                </li>
                                <li>
                                    <span class="title">申请理由：</span>
                                    <label>${applyBean.applyReason}</label>
                                </li>
                                <c:if test="${applyBean.applyStatus!=0}">
                                    <span style="color:red">审核结果：${applyBean.applyStatus==1?"审核通过":"审核失败"}</span>
                                </c:if>

                                <c:if test="${applyBean.applyStatus==1}">
                                    <li>
                                        <span class="title">分配等级：</span>
                                        <label>${applyBean.resultLevel.levelName}</label>
                                    </li>
                                    <li>
                                        <span class="title">分配上级：</span>
                                        <label>${applyBean.resultReferrer}</label>
                                    </li>
                                </c:if>
                                <c:if test="${applyBean.applyStatus!=0}">
                                    <li>
                                        <span class="title">${applyBean.applyStatus==1?"通过":"拒绝"}理由：</span>
                                        <label>${applyBean.refuseReason}</label>
                                    </li>
                                </c:if>
                            </ul>
                        </div>
                        <c:if test="${applyBean.applyStatus!=1}">
                            <div style="padding:20px 5% 20px 5%">
                                <input type="button" value="审核" id="confirmBtn" class=" copybtn6">
                            </div>
                        </c:if>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
</body>
</html>
