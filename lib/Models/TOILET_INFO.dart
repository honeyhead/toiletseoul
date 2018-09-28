import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class TOILET_INFO{
  String COT_ID; //아이디
  String COT_ADDR_FULL_OLD; //지번주소
  String COT_ADDR_FULL_NEW; //신규 주소
  String COT_DONG_NAME; //동명
  String COT_GU_NAME; //구명
  String COT_COORD_X; //좌표 X
  String COT_COORD_Y; //좌표 Y
  String DISTANCE; //현재 지점과의 거리

  String COT_TEL_NO; //전화번호
  String COT_REG_DATE; //등록일
  String COT_UPDATE_DATE; //수정일

  String COT_KIND; //유형 COT_VALUE_01
  String COT_OPENTIME; //개방시간 COT_VALUE_02
  String COT_TYPE; //화장실 타입 COT_VALUE_03
  String COT_SEX; //성별 구분 COT_VALUE_04
  String COT_OPTION; //옵션 COT_VALUE_05
  String COT_TEL_NO_MANAGE; //옵션 COT_VALUE_20


  String COT_NAME; //명칭  cot_conts_name
}

Future<String> _loadCrosswordAsset() async {
  return await rootBundle.loadString('data_repo/toiletdata.json');
}

Future<List<TOILET_INFO>> loadCrossword() async {
  String jsonCrossword = await _loadCrosswordAsset();
  final jsonResponse = json.decode(jsonCrossword);
  List<TOILET_INFO> infoSet =new List<TOILET_INFO>();

  for(var item in jsonResponse["DATA"]){
    TOILET_INFO _info = new TOILET_INFO();
    if(!(item["cot_conts_name"].toString() == 'test')){
      _info.COT_NAME = item["cot_conts_name"];
      _info.COT_ID = item['cot_conts_id'];
      _info.COT_ADDR_FULL_OLD = item["cot_addr_full_old"];
      _info.COT_ADDR_FULL_NEW = item["cot_addr_full_new"];
      _info.COT_COORD_X = item["cot_coord_x"].toString();
      _info.COT_COORD_Y = item["cot_coord_y"].toString();
      _info.COT_DONG_NAME = item["cot_dong_name"];
      _info.COT_GU_NAME = item["cot_gu_name"];
      _info.COT_TEL_NO = item["cot_tel_no"];
      _info.COT_REG_DATE = item["cot_reg_date"].toString();
      _info.COT_UPDATE_DATE = item["cot_update_date"].toString();
      _info.COT_KIND = item["cot_value_01"];
      _info.COT_OPENTIME = item["cot_value_02"];
      _info.COT_TYPE  = item["cot_value_03"];
      _info.COT_SEX  = item["cot_value_04"];
      _info.COT_OPTION  = item["cot_value_05"];
      _info.COT_TEL_NO_MANAGE  = item["cot_value_20"];
      infoSet.add(_info);
    }
  }
  return infoSet;
}