class UserListFields{
  static const String empId='empId';
  static const String empName='empName';
  static const String email='email';
  static const String shrtName='shrtName';
}
class UserList{
  final String empId;
  final String empName;
  final String email;
  final String shrtName;
  
  const UserList(
      {required this.empId,
      required this.empName,
      required this.email,
      required this.shrtName});

  
  Map<String, Object?> toJson() => {
    UserListFields.empId: empId,
    UserListFields.empName: empName,
    UserListFields.email: email
  };
  static UserList fromJson(Map<String, Object?> json)=>UserList(
    empId:json['emp_id'] as String,
    empName: json['emp_name'] as String,
    email: json['email'] as String,
    shrtName: json['shrt_name'] as String,
  ); 
}