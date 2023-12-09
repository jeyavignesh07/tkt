import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arc_text/flutter_arc_text.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:ticket_app/db/tkt_db.dart';
import 'package:ticket_app/models/tkt.dart';
import 'package:ticket_app/models/userList.dart';
import 'package:ticket_app/routes/routes.dart';
import 'package:ticket_app/screens/edit_task.dart';
import 'package:ticket_app/service/api_base.dart';
import 'package:ticket_app/widgets/error_warning_ms.dart';
import 'package:http/http.dart' as http;

class TktDetailView extends StatefulWidget {
  final String tktNo;
  const TktDetailView({
    super.key,
    required this.tktNo,
  });
  @override
  State<TktDetailView> createState() => _TktDetailViewState();
}

class _TktDetailViewState extends State<TktDetailView> {
  String dropdownValue = 'Raised';

  Color color = Colors.black;
  late String userId;
  late String title;
  late String desc;
  late String tktCreatedOn;
  late String tktCreatedBy;
  late String tktReplyOn;
  List<UserList> tktAssignedTo = [];
  List<UserList> tktCopiedTo = [];
  List<String> tktAssignedToEdit =[];
  List<String> tktCopiedToEdit =[];
  List<Tags> tktTags = [];
  bool enabled = false;
  @override
  void initState() {
    title = "Ticket Title";
    desc = "Ticket Description";
    tktCreatedOn = DateTime.now().toString();
    tktReplyOn = DateTime.now().toString();
    userId='0';
    tktCreatedBy = '1';
    startMove();
    super.initState();
  }

  Future startMove() async {
    var data = await TktDb.instance.getUserInfo();
    userId = data[0].empId.toString();
    await getTktDetail();
    await checkForStatusUpdtAuthor();
    setState(() {});
  }

  Future checkForStatusUpdtAuthor() async {
    for (var x in tktAssignedTo) {
      if (userId == x.empId) {
        enabled = true;
        break;
      } else {
        enabled = false;
      }
    }
  }

  Future getTktDetail() async {
    var data = await TktDb.instance.getTktDetail(widget.tktNo);
    tktAssignedTo = await TktDb.instance.getTktDetailAssignTo(widget.tktNo);
    tktCopiedTo = await TktDb.instance.getTktDetailCopyTo(widget.tktNo);
    tktTags = await TktDb.instance.getTktDetailTags(widget.tktNo);
    if (data.length > 0) {
      title = data[0].tktTitle;
      desc = data[0].tktDesc;
      tktCreatedOn = data[0].tktCreatedOn;
      tktCreatedBy = data[0].tktCreatedBy;
      tktReplyOn = data[0].tktReplyOn;
      dropdownValue = data[0].tktStatus;
      if (dropdownValue == 'Completed') {
        color = Colors.blue;
      } else if (dropdownValue == 'Progress') {
        color = Colors.yellow;
      } else {
        color = Colors.black;
      }
    }
    for (var x in tktAssignedTo) {
      tktAssignedToEdit.add(x.empId);
    }
    for (var x in tktCopiedTo) {
      tktCopiedToEdit.add(x.empId);
    }
  }

  Future postStatus(String status) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse(ApiBase.baseUrl + ApiBase.updateTktStatsEndPoint));
    request.body = json.encode({"tktNo": widget.tktNo, "tktStatus": status});
    request.headers.addAll(headers);
    try {
      http.StreamedResponse response =
          await request.send().timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        var data = await response.stream.bytesToString();
        var data1 = jsonDecode(data);
        var data2 = data1["tktStatus"] as List;
        if (data2[0]['USR'] == 'ERR') {
          Message.taskErrorOrWarning(
              "Server Error", "Status not updated.", "#ff4d4d");
          return;
        }
        await TktDb.instance
            .updateTktStats(data2[0]['tktNo'], data2[0]['tktStatus']);
        Message.taskErrorOrWarning("Success", "Status updated.", "#ff4d4d");
        Navigator.of(context).pop();
        if (status == 'Completed') {
          color = Colors.blue;
        } else if (status == 'Progress') {
          color = Colors.yellow;
        } else {
          color = Colors.black;
        }
        setState(() {});
      } else {
        Message.taskErrorOrWarning(
            "Server Error", "Please try again later.", "#103463");
      }
    } on Exception catch (ex) {
      Message.taskErrorOrWarning(
          "Server Error", "Please try again later.", "#103463");
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Status'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        InkWell(
                          splashColor: Colors.blue.withAlpha(60),
                          onTap: () {
                            postStatus("Completed");
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                margin: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue.shade400,
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 2,
                                        spreadRadius: 3,
                                        color: Colors.grey,
                                        offset: Offset(0, 1),
                                      )
                                    ]),
                                child: const Center(
                                    child: ArcText(
                                        radius: 25,
                                        text: 'Completed',
                                        textStyle: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          shadows: <Shadow>[
                                            Shadow(
                                              offset: Offset(0.4, 0.4),
                                              blurRadius: 2.0,
                                              color:
                                                  Colors.black,
                                            ),
                                          ],
                                        ),
                                        startAngle: pi + 1.1,
                                        startAngleAlignment:
                                            StartAngleAlignment.start,
                                        placement: Placement.outside,
                                        direction: Direction.counterClockwise)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        InkWell(
                          splashColor: Colors.yellow.withAlpha(60),
                          onTap: () {
                            postStatus("Progress");
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                margin: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.yellow.shade400,
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 2,
                                        spreadRadius: 3,
                                        color: Colors.grey,
                                        offset: Offset(0, 1),
                                      )
                                    ]),
                                child: const Center(
                                    child: ArcText(
                                        radius: 25,
                                        text: 'Progress',
                                        textStyle: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          shadows: <Shadow>[
                                            Shadow(
                                              offset: Offset(0.4, 0.4),
                                              blurRadius: 2.0,
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                            ),
                                          ],
                                        ),
                                        startAngle: pi + 0.9,
                                        startAngleAlignment:
                                            StartAngleAlignment.start,
                                        placement: Placement.outside,
                                        direction: Direction.counterClockwise)),
                              ),
                            ],
                          ),
                        ),
                        // const SizedBox(
                        //   width: 50,
                        //   child: Center(
                        //     child: Text(
                        //       'Progress',
                        //       style: TextStyle(
                        //         fontSize: 15,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //       textAlign: TextAlign.center,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    Column(
                      children: [
                        InkWell(
                          splashColor: Colors.black.withAlpha(60),
                          onTap: () {
                            postStatus("Raised");
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                margin: const EdgeInsets.all(10.0),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black87,
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 2,
                                        spreadRadius: 3,
                                        color: Colors.grey,
                                        offset: Offset(0, 1),
                                      )
                                    ]),
                                child: const Center(
                                    child: ArcText(
                                        radius: 25,
                                        text: 'Raised',
                                        textStyle: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          shadows: <Shadow>[
                                            Shadow(
                                              offset: Offset(0.4, 0.4),
                                              blurRadius: 2.0,
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                            ),
                                          ],
                                        ),
                                        startAngle: pi + 0.6,
                                        startAngleAlignment:
                                            StartAngleAlignment.start,
                                        placement: Placement.outside,
                                        direction: Direction.counterClockwise)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // actions: <Widget>[
          //   TextButton(
          //     child: const Text('Approve'),
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //     },
          //   ),
          // ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          SafeArea(
            child: Container(
              color: const Color.fromRGBO(130, 0, 255, 1),
              height: MediaQuery.of(context).size.height,
              child: ListView(
                shrinkWrap: true,
                //scrollDirection: Axis.vertical,
                children: [
                  Column(
                    children: [
                      Container(
                        margin:
                            const EdgeInsets.only(top: 40, left: 10, right: 10),
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 5, bottom: 20),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: ListView(
                          children: [
                            Padding(
                                padding:
                                    const EdgeInsets.only(top: 0, bottom: 1),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: GoogleFonts.montserrat(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      splashColor: color,
                                      onTap: () {
                                        _showMyDialog();
                                      },
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 65,
                                            height: 65,
                                            margin: const EdgeInsets.all(10.0),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: color,
                                              // boxShadow: [
                                              //   BoxShadow(
                                              //     blurRadius: 2,
                                              //     spreadRadius: 3,
                                              //     color: color,
                                              //     offset: const Offset(0, 1),
                                              //   )
                                              // ]
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                            Container(
                              padding: const EdgeInsets.only(top: 1, bottom: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    child: Text(
                                      desc,
                                      style: GoogleFonts.montserrat(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.only(
                            //       top: 5, bottom: 20, right: 5),
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //     children: [
                            //       Text(
                            //         "Status",
                            //         style: GoogleFonts.montserrat(
                            //           color: Colors.black,
                            //           fontWeight: FontWeight.w500,
                            //           fontSize: 18,
                            //         ),
                            //       ),
                            //       Container(
                            //         width:
                            //             MediaQuery.of(context).size.width * 0.60,
                            //         height: 45,
                            //         padding: const EdgeInsets.symmetric(
                            //             horizontal: 20, vertical: 5),
                            //         decoration: BoxDecoration(
                            //           borderRadius: BorderRadius.circular(50)
                            //               .copyWith(
                            //                   bottomRight:
                            //                       const Radius.circular(10),
                            //                   topLeft: const Radius.circular(10)),
                            //           color: const Color(0XFFFFFFFF),
                            //           boxShadow: const [
                            //             BoxShadow(
                            //               color: Color(0xcc000000),
                            //               blurRadius: 3.0,
                            //             ),
                            //           ],
                            //         ),
                            //         child: DropdownButton<String>(
                            //           // Step 3.
                            //           value: dropdownValue,
                            //           isExpanded: true,
                            //           // Step 4.
                            //           items: <String>[
                            //             'Raised',
                            //             'Progress',
                            //             'Completed'
                            //           ].map<DropdownMenuItem<String>>(
                            //               (String value) {
                            //             return DropdownMenuItem<String>(
                            //               value: value,
                            //               child: Text(
                            //                 value,
                            //                 style: GoogleFonts.montserrat(
                            //                   color: Colors.black,
                            //                   fontWeight: FontWeight.w400,
                            //                   fontSize: 16,
                            //                 ),
                            //               ),
                            //             );
                            //           }).toList(),
                            //           // Step 5.
                            //           onChanged: enabled
                            //               ? (String? newValue) {
                            //                   setState(() {
                            //                     dropdownValue = newValue!;
                            //                   });
                            //                   //postStatus();
                            //                 }
                            //               : null,
                            //         ),
                            //       )
                            //     ],
                            //   ),
                            // ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 5, bottom: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Dates",
                                    style: GoogleFonts.montserrat(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    DateFormat.yMMMd()
                                        .format(DateTime.parse(tktCreatedOn)),
                                    style: GoogleFonts.montserrat(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_right_alt_rounded,
                                    size: 24,
                                    color: Colors.black87,
                                  ),
                                  Text(
                                    DateFormat.yMMMd()
                                        .format(DateTime.parse(tktReplyOn)),
                                    style: GoogleFonts.montserrat(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 5, bottom: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Wrap(
                                      children: [
                                        Text(
                                          "Assignees",
                                          style: GoogleFonts.montserrat(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 100,
                                          child: ListView.builder(
                                              padding: const EdgeInsets.all(8),
                                              itemCount: tktAssignedTo.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return Text(
                                                  tktAssignedTo[index].empName,
                                                  style: GoogleFonts.montserrat(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 15,
                                                  ),
                                                );
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                      child: Wrap(children: [
                                    Text(
                                      "Copied",
                                      style: GoogleFonts.montserrat(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 100,
                                      child: ListView.builder(
                                          padding: const EdgeInsets.all(8),
                                          itemCount: tktCopiedTo.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Text(
                                              tktCopiedTo[index].empName,
                                              style: GoogleFonts.montserrat(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 15,
                                              ),
                                            );
                                          }),
                                    ),
                                  ]))
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 5, bottom: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Wrap(
                                      children: [
                                        Text(
                                          "Tags",
                                          style: GoogleFonts.montserrat(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 100,
                                          child: ListView.builder(
                                              padding: const EdgeInsets.all(8),
                                              itemCount: tktTags.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return Text(
                                                  tktTags[index].tag,
                                                  style: GoogleFonts.montserrat(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 15,
                                                  ),
                                                );
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            tktCreatedBy==userId?
                            InkWell(
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color.fromRGBO(130, 0, 255, 1),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.edit,
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "Edit",
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                Get.to(()=>EditTask(
                                  tktNo: widget.tktNo,
                                  initSelectedAssign: tktAssignedToEdit,
                                  initSelectedCopy: tktCopiedToEdit,
                                ));
                              },
                            ): const SizedBox(height: 1,),
                            const SizedBox(
                              height: 10,
                            ),
                            InkWell(
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color.fromRGBO(130, 0, 255, 1),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.close,
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "Close",
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                Get.toNamed(RoutesClass.getHomeRoute());
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
