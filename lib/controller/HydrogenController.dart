// ignore_for_file: unused_import, unnecessary_import, avoid_web_libraries_in_flutter, unused_local_variable, unrelated_type_equality_checks, unnecessary_new, avoid_print, prefer_typing_uninitialized_variables, non_constant_identifier_names, unnecessary_overrides, file_names

import 'dart:html';
import 'dart:math';

import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
// import 'dart:js' as js;
import 'package:intl/intl.dart';
import '../util/ControllerUtils.dart' as utils;

class HydrogenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }

  var username = ''.obs;
  var password = ''.obs;
  var hydrogen_code = ''.obs;
  var hydrogen_gun_code = ''.obs;
  var hydrogen_containers_num = ''.obs;
  var dataResultList = [].obs;
  var show = false.obs;
  var buttonText = '生成SQL'.obs;
  var sqlName = [].obs;
  


  // getter() {
  //   print(
  //       'metrusernameic:${username.value},password:${password.value},hydrogen_code:${hydrogen_code.value},hydrogen_gun_code:${hydrogen_gun_code.value},hydrogen_containers_num:${hydrogen_containers_num.value}');
  // }

  clean(){
    dataResultList.length = 0;
    sqlName.length = 0;
    show.value = false;
    buttonText.value = '生成SQL';
  }

  product() {
    show.value = true;
    buttonText.value = '清空结果';
    //调用所有创建表的方法
    createAPITable();
    createRealDataTable();
    createStatusTable();
    createGunRealTimeTable();
    createTransactionTable();
    createContainerRealTimeTable();
    createStorageRealTimeTable();
    createStorageTable();
    createAlarmTable();
    // print(dataResultList);
    // print(sqlName);
  }

  //创建加氢站接口账密表
  createAPITable(){
    if(hydrogen_code.value!=''&&password.value!=''){
      sqlName.add('加氢站接口账密表:');
      dataResultList.add('CREATE TABLE IF NOT EXISTS db_hydrogen_station_event_${hydrogen_code.value} USING db_hydrogen_station_event TAGS ("${hydrogen_code.value}","${password.value}");\n');
    }
  }
  
  //创建平台实时数据用户名密码表
  createRealDataTable(){
    if(username.value!=''&&password.value!=''){
      sqlName.add('平台实时数据用户名密码表:');
      dataResultList.add('CREATE TABLE IF NOT EXISTS db_hydrogen_platform_event_${username.value} USING db_hydrogen_platform_event TAGS ("${username.value}","${password.value}");\n');
    }
  }

  //加氢站状态数据子表
  createStatusTable(){
    if(hydrogen_code.value!=''){
      sqlName.add('加氢站状态数据子表:');
      dataResultList.add('CREATE TABLE IF NOT EXISTS db_hydrogen_operation_status_${hydrogen_code.value} USING db_hydrogen_operation_status TAGS ("${hydrogen_code.value}");\n');
    }
  }

  //加氢机实时信息子表
  createGunRealTimeTable(){
    if(hydrogen_code.value!=''){
      sqlName.add('加氢机实时信息子表:');
      dataResultList.add('CREATE TABLE IF NOT EXISTS db_hydrogenator_real_time_info_${hydrogen_code.value} USING db_hydrogenator_real_time_info TAGS ("${hydrogen_code.value}");\n');
    }
  }
  
  //加氢机交易记录子表
  createTransactionTable(){
    if(hydrogen_gun_code.value!=''){
      //按照逗号分割字符串hydrogen_gun_code
      List<String> list = hydrogen_gun_code.value.split(',');
      //循环创建表
      for(int i=0;i<list.length;i++){
        sqlName.add('加氢机交易记录子表:');
        // dataResultList.add('CREATE TABLE IF NOT EXISTS db_hydrogenator_transaction_record_${list[i]} USING db_hydrogenator_transaction_record TAGS ("${hydrogen_code.value}","${list[i]}");\n');
        dataResultList.add('CREATE TABLE IF NOT EXISTS db_hydrogenator_transaction_record_${hydrogen_code.value}_${list[i]} USING db_hydrogenator_transaction_record TAGS ("${hydrogen_code.value}","${list[i]}");\n');
      }
    }
  }

  //压缩机实时信息子表
  createContainerRealTimeTable(){
    if(hydrogen_code.value!=''){
      sqlName.add('压缩机实时信息子表:');
      dataResultList.add('CREATE TABLE IF NOT EXISTS db_compressor_real_time_info_${hydrogen_code.value} USING db_compressor_real_time_info TAGS ("${hydrogen_code.value}");\n');
    }
  }

  //储氢容器实时信息子表
  createStorageRealTimeTable(){
    if(hydrogen_code.value!=''){
      sqlName.add('储氢容器实时信息子表:');
      dataResultList.add('CREATE TABLE IF NOT EXISTS db_hydrogen_containers_real_time_info_${hydrogen_code.value} USING db_hydrogen_containers_real_time_info TAGS ("${hydrogen_code.value}");\n');
    }
  }

  //储氢容器定期更新数据子表（有几个储氢容器就执行几条语句）
  createStorageTable(){
    if(hydrogen_containers_num.value!=''){
      //按照逗号分割字符串hydrogen_containers_num
      List<String> list = hydrogen_containers_num.value.split(',');
      //循环创建表
      for(int i=0;i<list.length;i++){
        sqlName.add('储氢容器定期更新数据子表:');
        // dataResultList.add('CREATE TABLE IF NOT EXISTS db_hydrogen_containers_periodic_update_${list[i]} USING db_hydrogen_containers_periodic_update TAGS ("${hydrogen_code.value}","${list[i]}");\n');
        dataResultList.add('CREATE TABLE IF NOT EXISTS db_hydrogen_containers_periodic_update_${hydrogen_code.value}_${list[i]} USING db_hydrogen_containers_periodic_update TAGS ("${hydrogen_code.value}","${list[i]}");\n');
      }
    }
  }

  //创建加氢站报警数据
  createAlarmTable(){
    if(hydrogen_code.value!=''){
      sqlName.add('加氢站报警数据表:');
      dataResultList.add('CREATE TABLE IF NOT EXISTS db_hydrogen_abnormal_alarm_${hydrogen_code.value} USING db_hydrogen_abnormal_alarm TAGS ("${hydrogen_code.value}");\n');
    }
  }

  

  // packaging(int time) {
  //   String demo =
  //       '${metric.value} $time ${utils.round(hydrogen_code,hydrogen_gun_code)} hydrogen_containers_num=${hydrogen_containers_num.value} ec=${ec.value} mp=${mp.value} md=${md.value} mpType=${mp_type.value}\n';
  //   // print(demo);
  //   return demo;
  // }

  

  

}


