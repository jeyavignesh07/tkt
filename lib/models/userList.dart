class UserListFields{
  static const String empId='empId';
  static const String empName='empName';
  static const String email='email';
}
class UserList{
  final String empId;
  final String empName;
  final String email;
  
  const UserList(
      {required this.empId,
      required this.empName,
      required this.email});

  
  Map<String, Object?> toJson() => {
    UserListFields.empId: empId,
    UserListFields.empName: empName,
    UserListFields.email: email
  };
  static UserList fromJson(Map<String, Object?> json)=>UserList(
    empId:json['emp_id'] as String,
    empName: json['emp_name'] as String,
    email: json['email'] as String,
  ); 
}