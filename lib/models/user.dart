
class UserFields{
  static const String devId='devId';
  static const String empId='empId';
  static const String empName='empName';
  static const String dsgntn='dsgntn';
  static const String mob='mob';
  static const String loctn='loctn';
  static const String usrTyp='usrTyp';
  static const String dpt='dpt';
  static const String gender='gender';
  static const String imgUrl='imgUrl';
}

class User {
  final int devid;
  final String empId;
  final String empName;
  final String dsgntn;
  final String mob;
  final String loctn;
  final String usrTyp;
  final String dpt;
  final String gender;
  final String imgUrl;

  const User(
      {required this.devid,
      required this.empId,
      required this.empName,
      required this.dsgntn,
      required this.mob,
      required this.loctn,
      required this.usrTyp,
      required this.dpt,
      required this.gender,
      required this.imgUrl});

  Map<String, Object?> toJson() => {
    UserFields.devId: devid,
    UserFields.empId: empId,
    UserFields.empName: empName,
    UserFields.dsgntn: dsgntn,
    UserFields.mob: mob,
    UserFields.loctn: loctn,
    UserFields.usrTyp: usrTyp,
    UserFields.dpt: dpt,
    UserFields.gender: gender,
    UserFields.imgUrl: imgUrl
  };
  static User fromJson(Map<String, Object?> json)=>User(
    devid:json['devid'] as int,
    empId: json['emp_id'] as String,
    empName: json['emp_name'] as String,
    dsgntn: json['dsgntn'] as String,
    mob: json['mob'] as String,
    loctn: json['loctn'] as String,
    usrTyp: json['usr_typ'] as String,
    dpt: json['dpt'] as String,
    gender: json['gender'] as String,
    imgUrl: json['img_url'] as String
  ); 
}

class Animal {
  final String empId;
  final String empName;
  Animal({
    required this.empId,
    required this.empName,
  });
}
class TktSharedFile {
  final String file;
  TktSharedFile({
    required this.file
  });
}
