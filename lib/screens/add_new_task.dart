import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:ticket_app/models/tkt.dart';
import 'package:ticket_app/widgets/category_card';
import 'package:http/http.dart' as http;
import 'package:ticket_app/widgets/error_warning_ms.dart';
import '../db/tkt_db.dart';
import '../models/userList.dart';
import '../routes/routes.dart';
import 'package:ticket_app/models/user.dart';
import 'package:ticket_app/service/api_base.dart';
class Tags {
  final int id;
  final String name;

  Tags({
    required this.id,
    required this.name,
  });
}
class AddNewTask extends StatefulWidget {
  const AddNewTask({Key? key}) : super(key: key);

  @override
  State<AddNewTask> createState() => _AddNewTaskState();
}

class _AddNewTaskState extends State<AddNewTask> {
  late TextEditingController _Titlecontroller;
  late TextEditingController _Descriptioncontroller;
  late TextEditingController _Datecontroller;
  late TextEditingController _StartTime;
  late TextEditingController _EndTime;

  bool _isLoading = false;
  bool _isTaskCreated = false;

  List<Animal> userListAssign = [];
  List<Animal> userListCopy = [];
  List<String> selectedAssign = [];
  List<String> selectedCopy = [];

  static final List<Tags> _tags = [
    Tags(id:1, name: "Lion"),
    Tags(id:2, name: "Flamingo"),
    Tags(id:3, name: "Hippo"),
    Tags(id:4, name: "Horse"),
    Tags(id:5, name: "Tiger"),
  ];
  final _items = _tags
      .map((tag) => MultiSelectItem<Tags>(tag,tag.name))
      .toList();

  String? assignTo;
  String? copyTo;
  late String usrId;
  late String devId;
  late String tktNo;
  String tkt = "TKT";
  DateTime SelectedDate = DateTime.now();
  String Category = "Meeting";
  @override
  void initState() {
    super.initState();
    startMove();
    _Titlecontroller = TextEditingController();
    _Descriptioncontroller = TextEditingController();
    _Datecontroller = TextEditingController(
        text: DateFormat("yyyy-MM-dd").format(SelectedDate));
    _StartTime =
        TextEditingController(text: DateFormat.jm().format(DateTime.now()));
    _EndTime = TextEditingController(
        text: DateFormat.jm().format(DateTime.now().add(
      const Duration(hours: 1),
    )));
  }

  Future startMove() async {
    setState(() {
      _isLoading = true;
    });
    await getUserListData();
    await getUserList();
    setState(() {
      _isLoading = false;
    });
  }

  Future getDevId() async {
    var data = await TktDb.instance.getUserInfo();
    var data1 = await TktDb.instance.getTktCount();
    if (data.length > 0) {
      devId = data[0].devid.toString();
      usrId = data[0].empId.toString();
    }
    tktNo = (data1.length + 1).toString();
  }

  Future<dynamic> getUserList() async {
    var data = await TktDb.instance.getUserList();
    if (data.length > 0) {
      userListAssign.clear();
      for (int i = 0; i < data.length; i++) {
        userListAssign
            .add(Animal(empId: data[i].empId, empName: data[i].empName));
      }
      userListCopy = List.from(userListAssign);
    }
  }

  bool _dataValidation() {
    if (_Titlecontroller.text.trim() == '') {
      Message.taskErrorOrWarning("Title", "Title is empty", "#99EFABE5");
      return false;
    } else if (_Descriptioncontroller.text.trim() == '') {
      Message.taskErrorOrWarning(
          "Description", "Description is empty", "#99EFABE5");
      return false;
    } else if (_Datecontroller.text.trim() == '') {
      Message.taskErrorOrWarning(
          "Reply date", "Reply date is empty", "#99EFABE5");
      return false;
    } else if (selectedAssign.isEmpty) {
      Message.taskErrorOrWarning(
          "Assign to", "Assign to is empty", "#99EFABE5");
      return false;
    }
    return true;
  }

  Future createTask() async {
    if (_dataValidation()) {
      setState(() {
        _isTaskCreated = true;
      });

      await getDevId();
      TktHdr th = TktHdr(
          tktNo: tkt + devId + tktNo,
          tktTitle: _Titlecontroller.text,
          tktDesc: _Descriptioncontroller.text,
          tktCreatedBy: usrId,
          tktCreatedOn: DateTime.now().toString().substring(0, 23),
          tktReplyOn:
              DateFormat("yyyy-MM-dd").parse(_Datecontroller.text).toString(),
          tktStatus: 'Raised');
      await TktDb.instance.createTktHdr(th);
      for (String x in selectedAssign) {
        TktDtlAssign td =
            TktDtlAssign(tktNo: tkt + devId + tktNo, tktAssignedTo: x);
        await TktDb.instance.createTktDtlAssignTo(td);
      }
      for (String x in selectedCopy) {
        TktDtlCopy td = TktDtlCopy(tktNo: tkt + devId + tktNo, tktCopiedTo: x);
        await TktDb.instance.createTktDtlCopyTo(td);
      }
      await createTkt(th);
      setState(() {
        _isTaskCreated = false;
      });
      Get.toNamed(RoutesClass.getHomeRoute());
    }
  }

  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: SelectedDate,
      firstDate: DateTime(2005),
      lastDate: DateTime(2030),
    );
    if (selected != null && selected != SelectedDate) {
      setState(() {
        SelectedDate = selected;
        _Datecontroller.text = DateFormat("yyyy-MM-dd").format(selected);
      });
    }
  }

  _selectTime(BuildContext context, String Timetype) async {
    final TimeOfDay? result =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (result != null) {
      setState(() {
        if (Timetype == "StartTime") {
          _StartTime.text = result.format(context);
        } else {
          _EndTime.text = result.format(context);
        }
      });
    }
  }

  _SetCategory(String Category) {
    setState(() {
      this.Category = Category;
    });
  }

  Future insertUserList(List<UserList> ul) async {
    await TktDb.instance.createUserList(ul);
  }

  Future getUserListData() async {
    var request = http.Request(
        'GET', Uri.parse(ApiBase.baseUrl + ApiBase.userListEndpoint));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      var data1 = jsonDecode(data);
      var data2 = data1["userList"] as List;
      List<UserList> usrList =
          data2.map((tagJson) => UserList.fromJson(tagJson)).toList();
      await TktDb.instance.deleteUserList();
      await insertUserList(usrList);
    } else {
      print(response.reasonPhrase);
    }
  }

  Future createTkt(TktHdr th) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse(ApiBase.baseUrl + ApiBase.createTktEndPoint));
    request.body = json.encode({
      "tktNo": th.tktNo,
      "tktTitle": th.tktTitle,
      "tktDesc": th.tktDesc,
      "tktCreatedBy": th.tktCreatedBy,
      "tktCreatedOn": th.tktCreatedOn,
      "tktReplyOn": th.tktReplyOn,
      "tktAssignedTo": selectedAssign,
      "tktCopiedTo": selectedCopy,
      "tktStatus": th.tktStatus
    });
    request.headers.addAll(headers);
    try {
      http.StreamedResponse response =
          await request.send().timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        var data = await response.stream.bytesToString();
        var data1 = jsonDecode(data);
        var data2 = data1["tkt"] as List;
        if (data2[0]['RES'] == 'OK') {
          Message.taskErrorOrWarning(
              "Task Created", "Succesfully", "#99EFABE5");
          return;
        }
      } else {
        Message.taskErrorOrWarning(
            "Server Error", "Please try again later.", "#103463");
      }
    } on Exception catch (ex) {
      Message.taskErrorOrWarning(
          "Server Error", "Please try again later.", "#103463");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          SafeArea(
            child: Container(
              color: const Color.fromRGBO(130, 0, 255, 1),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 20, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(Icons.arrow_back,
                                size: 30, color: Colors.white),
                          ),
                          const SizedBox(
                            width: 50,
                          ),
                          Text(
                            "Create New Task",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 20,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(
                            width: 40,
                          ),
                          // GestureDetector(
                          //   onTap: () async {

                          //   },
                          //   child: const Icon(Icons.refresh_rounded,
                          //       size: 30, color: Colors.white),
                          // ),
                        ],
                      ),
                    ),
                    Center(
                      child: !_isLoading
                          ? const Center()
                          : const CircularProgressIndicator(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 10),
                      child: TextFormField(
                        controller: _Titlecontroller,
                        cursorColor: Colors.white,
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          labelText: "Title",
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          fillColor: Colors.white,
                          labelStyle: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 10),
                      child: TextFormField(
                        controller: _Datecontroller,
                        cursorColor: Colors.white,
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Reply Date",
                          suffixIcon: GestureDetector(
                            onTap: () {
                              _selectDate(context);
                            },
                            child: const Icon(
                              Icons.calendar_month_outlined,
                              color: Colors.white,
                            ),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          fillColor: Colors.white,
                          labelStyle: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 40),
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 20),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          )),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: Row(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.88,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50)
                                        .copyWith(
                                            bottomRight:
                                                const Radius.circular(10),
                                            topLeft: const Radius.circular(10)),
                                    color: const Color(0XFFFFFFFF),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xcc000000),
                                        blurRadius: 3.0,
                                      ),
                                    ],
                                  ),
                                  child: MultiSelectDialogField(
                                    itemsTextStyle: GoogleFonts.montserrat(
                                      fontSize: 15,
                                    ),
                                    searchable: true,
                                    selectedItemsTextStyle:
                                        GoogleFonts.montserrat(
                                      fontSize: 15,
                                      color: const Color(0xFF8200FF),
                                    ),
                                    items: //userList.map((e, f) => MultiSelectItem(e,f)),
                                        userListAssign
                                            .map((e) => MultiSelectItem(
                                                e.empId, e.empName))
                                            .toList(),
                                    title: Text(
                                      "Assign to",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    selectedColor:
                                        const Color.fromRGBO(130, 0, 255, 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0x22EFABE5),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(40)),
                                      border: Border.all(
                                        color: const Color.fromRGBO(
                                            130, 0, 255, 1),
                                        width: 0.5,
                                      ),
                                    ),
                                    buttonIcon: const Icon(
                                      Icons.person,
                                      color: Color.fromRGBO(130, 0, 255, 1),
                                    ),
                                    buttonText: Text(
                                      "Assign to",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.none,
                                        color: const Color.fromRGBO(
                                            130, 0, 255, 1),
                                      ),
                                    ),
                                    onConfirm: (results) {
                                      selectedAssign = results;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: Row(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.88,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50)
                                        .copyWith(
                                            bottomRight:
                                                const Radius.circular(10),
                                            topLeft: const Radius.circular(10)),
                                    color: const Color(0XFFFFFFFF),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xcc000000),
                                        blurRadius: 3.0,
                                      ),
                                    ],
                                  ),
                                  child: MultiSelectDialogField(
                                    itemsTextStyle: GoogleFonts.montserrat(
                                      fontSize: 15,
                                    ),
                                    searchable: true,
                                    selectedItemsTextStyle:
                                        GoogleFonts.montserrat(
                                      fontSize: 15,
                                      color:
                                          const Color.fromRGBO(130, 0, 255, 1),
                                    ),
                                    items: userListCopy
                                        .map((e) =>
                                            MultiSelectItem(e.empId, e.empName))
                                        .toList(),
                                    title: Text(
                                      "Copy to",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    selectedColor:
                                        const Color.fromRGBO(130, 0, 255, 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0x22EFABE5),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(40)),
                                      border: Border.all(
                                        color: const Color.fromRGBO(
                                            130, 0, 255, 1),
                                        width: 0.5,
                                      ),
                                    ),
                                    buttonIcon: const Icon(
                                      Icons.person,
                                      color: Color.fromRGBO(130, 0, 255, 1),
                                    ),
                                    buttonText: Text(
                                      "Copy to",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.none,
                                        color: const Color.fromRGBO(
                                            130, 0, 255, 1),
                                      ),
                                    ),
                                    onConfirm: (results) {
                                      selectedCopy = results;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 20),
                            child: TextFormField(
                              keyboardType: TextInputType.multiline,
                              controller: _Descriptioncontroller,
                              minLines: 4,
                              maxLines: 8,
                              cursorColor: Colors.black26,
                              style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                labelText: "Description",
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black26),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black26),
                                ),
                                fillColor: Colors.black26,
                                labelStyle: GoogleFonts.montserrat(
                                  color: Colors.black26,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Category",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontSize: 20,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                Wrap(
                                  alignment: WrapAlignment.spaceEvenly,
                                  crossAxisAlignment: WrapCrossAlignment.start,
                                  children: [
                                    MultiSelectChipField(
                                      items: _items,
                                      title: const Text("Category"),
                                      headerColor: Colors.blue.withOpacity(0.5),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.blue,
                                            width: 1.8),
                                      ),
                                      selectedChipColor:
                                          Colors.blue.withOpacity(0.5),
                                      selectedTextStyle:
                                          TextStyle(color: Colors.blue[800]),
                                      onTap: (values) {
                                        //_selectedAnimals4 = values;
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          GestureDetector(
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: const Color.fromRGBO(130, 0, 255, 1),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Create Task",
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            onTap: () async {
                              await createTask();
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isTaskCreated)
            const Opacity(
              opacity: 0.8,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          if (_isTaskCreated)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
