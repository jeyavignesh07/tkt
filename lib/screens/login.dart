import 'dart:convert';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:rive/rive.dart';
import 'package:ticket_app/db/tkt_db.dart';
import 'package:ticket_app/routes/routes.dart';
import 'package:ticket_app/service/api_base.dart';
import 'package:ticket_app/widgets/error_warning_ms.dart';

import '../models/user.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController uidController = TextEditingController();
  TextEditingController pwdController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future insertUser(User user) async {
    await TktDb.instance.createUser(user);
  }

  Future<dynamic> getUserData() async {
    var data = await TktDb.instance.getUserInfo();
    var len = data.length;
    if (len > 0) {
      Get.toNamed(RoutesClass.getHomeRoute());
    }
  }

  bool _dataValidation() {
    if (uidController.text.trim() == '') {
      Message.taskErrorOrWarning("User Id", "User Id is empty", "#103463");
      return false;
    } else if (pwdController.text.trim() == '') {
      Message.taskErrorOrWarning("Password", "Password is empty", "#103463");
      return false;
    }
    return true;
  }

  Future postData() async {
    if (_dataValidation()) {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
          'POST', Uri.parse(ApiBase.baseUrl+ApiBase.loginEndPoint));
      request.body = json.encode({
        "uid": uidController.text,
        "upwd": pwdController.text,
        "devid": "0"
      });
      request.headers.addAll(headers);
      try {
        http.StreamedResponse response =
            await request.send().timeout(const Duration(seconds: 30));
        if (response.statusCode == 200) {
          var data = await response.stream.bytesToString();
          var data1 = jsonDecode(data);
          var data2 = data1["profile"] as List;
          if (data2[0]['USR'] == 'ERR') {
            Message.taskErrorOrWarning("Invalid Credentials",
                "Please enter valid Credentials.", "#ff4d4d");
            return;
          }
          List<User> usrObjs =
              data2.map((tagJson) => User.fromJson(tagJson)).toList();
          TktDb.instance.deleteUserInfo();
          insertUser(usrObjs[0]);
          TktDb.instance.getUserInfo();
          Get.toNamed(RoutesClass.getHomeRoute());
        } else {
          Message.taskErrorOrWarning(
              "Server Error", "Please try again later.", "#103463");
        }
      } on Exception catch (ex) {
        Message.taskErrorOrWarning(
            "Server Error", "Please try again later.", "#103463");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
         DoubleBackToCloseApp(
        snackBar: const SnackBar(
            content: Text('Tap back again to leave'),
          ),
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: ListView(
                children: <Widget>[
                  SizedBox(
                      width: 120,
                      height: 120,
                      child: Image.asset('assets/img/logo.jpg'),
                    ),
                  Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'Ticket',
                        style: GoogleFonts.montserrat(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                            fontSize: 30),
                      )),
                  Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'Sign in',
                        style: GoogleFonts.montserrat(fontSize: 20),
                      )),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      controller: uidController,
                      maxLength: 5,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'User Id',
                        
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter User Id";
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: TextField(
                      obscureText: true,
                      controller: pwdController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                    ),
                  ),
                  const SizedBox(height: 40,),
                  GestureDetector(
                    // When the child is tapped, show a snackbar
                    onTap: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      await postData();
                      setState(() {
                        _isLoading = false;
                      });
                    },
                    // Our Custom Button!
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'Login',
                        style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Center(
                    child: !_isLoading
                        ? const Center()
                        : const CircularProgressIndicator(),
                  ),
                ],
              ))),
    );
  }
}
