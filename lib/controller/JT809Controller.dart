// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables, empty_statements, non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_overrides, file_names, unused_import

import 'package:get/get.dart';
import '../util/ControllerUtils.dart' as utils;

class JT809Controler extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }

  var dataResult = '';
  var dataResultList = [].obs;
  var data = ''.obs;
  // var BWresult = '';
  var BWresult = [];
  var BWresultList = [];
  
  void clean() {
    dataResult = '';
    data.value = '';
    dataResultList.value = [];
    BWresult = [];
    BWresultList = [];
  }

//主函数
  main(str) {
    print('传参是：${str}');
    var result0 = '';
    var s = str.split('');
    for (var j = 0; j < str.length; j++) {
      if (j % 2 == 0) {
        result0 += s[j];
      } else {
        if (j == str.length - 1) {
          result0 += s[j];
        } else {
          result0 += s[j] + ' ';
        }
      }
    }
    // print(result0)
    var result1 = result0.split(' ');
    // print(result1)

    //数据拆分
    for (var i = 1; i < 12; i++) {
      switch (i) {
        case 1: //头标识
          dataResultList.add('头标识: ${result1[0]}\n');
          print('头标识:, ${result1[0]}');
          break;
        case 2: //数据长度
          dataResultList.add('数据长度: ${utils.combination(result1.sublist(1, 5))}\n');
          print('数据长度: ${utils.combination(result1.sublist(1, 5))}');
          break;
        case 3: //报文序列号
          dataResultList.add('报文序列号: ${utils.combination(result1.sublist(5, 9))}\n');
          print('报文序列号: ${utils.combination(result1.sublist(5, 9))}');
          break;
        case 4: //业务数据类型
          dataResultList.add(
              '业务数据类型: ${utils.combination(result1.sublist(9, 11))}, ${type(utils.combination(result1.sublist(9, 11)))}\n');
          print(
              '业务数据类型: ${utils.combination(result1.sublist(9, 11))}, ${type(utils.combination(result1.sublist(9, 11)))}');
          break;
        case 5: //下级平台接入码
          dataResultList.add(
              '下级平台接入码: ${utils.combination(result1.sublist(11, 15))},解析后： ${utils.hexToDecCombination(result1.sublist(11, 15))}\n');
          print(
              '下级平台接入码: ${utils.combination(result1.sublist(11, 15))},解析后： ${utils.hexToDecCombination(result1.sublist(11, 15))}');
          break;
        case 6: //协议版本号标识
          dataResultList.add('协议版本号标识: ${utils.combination(result1.sublist(15, 18))}\n');
          print('协议版本号标识: ${utils.combination(result1.sublist(15, 18))}');
          break;
        case 7: //报文加密标识位
          dataResultList.add('报文加密标识位: ${result1[18]}\n');
          print('报文加密标识位: ${result1[18]}');
          break;
        case 8: //数据加密秘钥
          dataResultList.add('数据加密秘钥: ${utils.combination(result1.sublist(19, 23))}\n');
          print('数据加密秘钥: ${utils.combination(result1.sublist(19, 23))}');
          break;
        case 9: //数据体
          // dataResultList += '头标识:, ${result1[0]}\n';
          chooseType(utils.combination(result1.sublist(9, 11)), result1);
          break;
        case 10: //校验码
          dataResultList.add(
              "\n校验码: ${result1[result1.length - 3]}${result1[result1.length - 2]}");
          print(
              '校验码： ${result1[result1.length - 3]}, ${result1[result1.length - 2]}');
          break;
        case 11: //尾标识
          dataResultList.add("\n尾标识：${result1[result1.length - 1]}");
          print('尾标识: ${result1[result1.length - 1]}');
          break;
        // default:
        //     print('报文：',result1[0],result1[1])
        //     break
      }
    }
    ;
    // print(dataResult);
    // data.value = dataResult;
    return dataResultList;
  }

//根据业务数据类型，选择函数进行数据体解析
  chooseType(type, List message) {
    // print('判断业务类型');
    switch (type) {
      case '1001':
        // print(1001);
        resolving1001(message);
        break;
      case '1002':
        // print(1002);
        resolving1002(message);
        break;
      case '1200':
        // print(1200);
        resolving1200(message);
        break;
      default:
        print('未知类型');
    }
  }

//主链路登录请求数据体解析
  resolving1001(List a) {
    // print('1001里面');
    BWresult = a.sublist(23, a.length - 3);
    for (var i = 0; i < 9; i++) {
      switch (i) {
        case 0: //用户名
          dataResultList.add(
              '用户名:${utils.combination(BWresult.sublist(0, 4))}，解析：${utils.hexToDecCombination(BWresult.sublist(0, 4))}\n');
          print(
              '用户名:,${BWresult[0]},${BWresult[1]},${BWresult[2]},${BWresult[3]}');
          break;
        case 1: //密码
          var pwd = BWresult.sublist(4, 12);
          dataResultList.add('密码:${utils.combination(pwd)}，解析后的密码：${utils.changetoHexCombination(pwd)}\n');
          print('密码:${utils.combination(pwd)}，解析后的密码：${utils.changetoHexCombination(pwd)}');
          // print('密码:',BWresult[4],BWresult[5],BWresult[6],BWresult[7],BWresult[8],BWresult[9],BWresult[10],BWresult[11])
          break;
        case 2: //下级IP
          var ip = BWresult.sublist(12, BWresult.length - 3);
          dataResultList.add(
              "下级IP:${utils.combination(ip)}\n解析后的IP：${utils.changetoHexCombination(ip)}\n");
          print('下级IP:${utils.combination(ip)}');
          print('解析后的IP：${utils.changetoHexCombination(ip)}');
          break;
        case 3: //遥测站地址
          dataResultList.add(
              "下级端口：${BWresult[BWresult.length - 2]}${BWresult[BWresult.length - 1]}");
          print(
              '下级端口:${BWresult[BWresult.length - 2]},${BWresult[BWresult.length - 1]}');
          break;
      }
    }
    // print('报文:',BWresult.substring(22,BWresult.length))
  }

//主链路登录应答数据体解析
  resolving1002(List a) {
    BWresult = a.sublist(23, a.length - 3);
    for (var i = 0; i < 9; i++) {
      switch (i) {
        case 0: //用户名
          if (BWresult[0] == '00') {
            dataResultList.add('${BWresult[0]},成功\n');
            print('${BWresult[0]},成功');
          } else if (BWresult[0] == '01') {
            dataResultList.add('${BWresult[0]},ip地址错误\n');
            print('${BWresult[0]},ip地址错误');
          } else if (BWresult[0] == '02') {
            dataResultList.add('${BWresult[0]},接入码错误\n');
            print('${BWresult[0]},接入码错误');
          } else if (BWresult[0] == '03') {
            dataResultList.add('${BWresult[0]},用户未注册\n');
            print('${BWresult[0]},用户未注册');
          } else if (BWresult[0] == '04') {
            dataResultList.add('${BWresult[0]},密码错误\n');
            print('${BWresult[0]},密码错误');
          } else if (BWresult[0] == '05') {
            dataResultList.add('${BWresult[0]},资源紧张\n');
            print('${BWresult[0]},资源紧张');
          } else if (BWresult[0] == '06') {
            dataResultList.add('${BWresult[0]},其他\n');
            print('${BWresult[0]},其他');
          }
          break;
        case 1: //校验码
          var pwd = BWresult.sublist(1, 5);
          dataResultList.add('校验码:${utils.combination(pwd)}\n');
          print('校验码:${utils.combination(pwd)}');
          break;
      }
    }
  }

//主链路动态信息交换数据体解析
  resolving1200(List a) {
    BWresult = a.sublist(23, a.length - 3);

    for (int i = 0; i < 9; i++) {
      switch (i) {
        case 0:
          // 车牌号
          dataResultList.add('车牌号:${utils.combination(BWresult.sublist(0, 22))}\n');
          dataResultList.add(
              '解析后的车牌:${utils.changetoHexCombination(BWresult.sublist(0, 22))}\n');
          print('车牌号:${utils.combination(BWresult.sublist(0, 22))}');
          print('解析后的车牌:${utils.changetoHexCombination(BWresult.sublist(0, 22))}');
          break;

        case 1:
          // 车牌颜色
          // var pwd = BWresult.substring(22, 23);
          dataResultList.add(
              '车牌颜色:${utils.combination(BWresult[23])}, ${carColor(utils.combination(BWresult[23]))}\n');
          print(
              '车牌颜色:${utils.combination(BWresult[23])}, ${carColor(utils.combination(BWresult[23]))}');
          break;

        case 2:
          // 子业务标识
          dataResultList.add('子业务标识:${utils.combination(BWresult.sublist(24, 25))}\n');
          print('子业务标识:${utils.combination(BWresult.sublist(24, 25))}');
          break;

        case 3:
          // 后续数据长度
          dataResultList.add('后续数据长度:${utils.combination(BWresult.sublist(25, 29))}\n');
          print('后续数据长度:${utils.combination(BWresult.sublist(25, 29))}');
          break;

        case 4:
          // 数据部分
          dataResultList.add(
              '数据部分:${utils.combination(BWresult.sublist(29, BWresult.length - 1))}\n');
          print(
              '数据部分:${utils.combination(BWresult.sublist(29, BWresult.length - 1))}');
          break;
      }
    }
  }



//数据类型判断
  type(a) {
    var type;
    // print('数据类型',typeof(a))
    switch (a) {
      case '1001':
        type = '主链路登录请求';
        break;
      case '1002':
        type = '主链路登录应答';
        break;
      case '1003':
        type = '主链路注销请求';
        break;
      case '1004':
        type = '主链路注销应答';
        break;
      case '1005':
        type = '主链路连接保持请求';
        break;
      case '1006':
        type = '主链路连接保持应答';
        break;
      case '1007':
        type = '主链路断开通知';
        break;
      case '1008':
        type = '下级主动断开通知';
        break;
      case '9001':
        type = '从链路连接请求';
        break;
      case '9002':
        type = '从链路连接应答';
        break;
      case '9003':
        type = '从链路注销请求';
        break;
      case '9004':
        type = '从链路注销应答';
        break;
      case '9005':
        type = '从链路连接保持请求';
        break;
      case '9006':
        type = '从链路连接保持应答';
        break;
      case '9007':
        type = '从链路断开通知';
        break;
      case '9008':
        type = '上级平台主动关闭链路通知';
        break;
      case '9101':
        type = '接收定位信息数量通知';
        break;
      case '1200':
        type = '主链路动态信息交换';
        break;
      case '9200':
        type = '从链路动态信息交换';
        break;
      case '1300':
        type = '主链路平台间信息交互';
        break;
      case '9300':
        type = '从链路平台间信息交互';
        break;
      case '1400':
        type = '主链路报警信息交互';
        break;
      case '9400':
        type = '从链路报警信息交互';
        break;
      case '1500':
        type = '主链路车辆监管消息';
        break;
      case '9500':
        type = '从链路车辆监管消息';
        break;
      case '1600':
        type = '主链路静态信息交互';
        break;
      case '9600':
        type = '从链路静态信息交互';
        break;
    }
    return type;
  }


//车辆颜色
  carColor(a) {
    var color = '';
    switch (a) {
      case '01':
        color = '蓝色';
        break;
      case '02':
        color = '黄色';
        break;
      case '03':
        color = '黑色';
        break;
      case '04':
        color = '白色';
        break;
      case '09':
        color = '其他';
        break;
      default:
        color = '没有该颜色代码';
    }
    return color;
  }

}
