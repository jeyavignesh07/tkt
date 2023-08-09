import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ticket_app/db/tkt_db.dart';
import 'package:ticket_app/models/tkt.dart';
import 'package:ticket_app/models/userList.dart';
import 'package:ticket_app/routes/routes.dart';
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
  late String userId;
  late String title;
  late String desc;
  late String tktCreatedOn;
  late String tktCreatedBy;
  late String tktReplyOn;
  List<UserList> tktAssignedTo = [];
  bool enabled = false;
  @override
  void initState() {
    title = "Ticket Title";
    desc = "Ticket Description";
    tktCreatedOn = DateTime.now().toString();
    tktReplyOn = DateTime.now().toString();
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
  Future checkForStatusUpdtAuthor() async{
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
    if (data.length > 0) {
      title = data[0].tktTitle;
      desc = data[0].tktDesc;
      tktCreatedOn = data[0].tktCreatedOn;
      tktCreatedBy = data[0].tktCreatedBy;
      tktReplyOn = data[0].tktReplyOn;
      dropdownValue = data[0].tktStatus;
    }
  }

  Future postStatus() async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse(ApiBase.baseUrl + ApiBase.updateTktStatsEndPoint));
    request.body =
        json.encode({"tktNo": widget.tktNo, "tktStatus": dropdownValue});
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
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 20, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0x22ffffff),
                            child: GestureDetector(
                              child: const Icon(
                                CupertinoIcons.xmark,
                                color: Colors.red,
                                size: 30,
                              ),
                              onTap: () {
                                Get.toNamed(RoutesClass.getHomeRoute());
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 40, left: 10, right: 10),
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 20),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      height: 500,
                      child: ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 20),
                            child: Text(
                              title,
                              style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 5, bottom: 20, right: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Status",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.60,
                                  height: 45,
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
                                  child: DropdownButton<String>(
                                    // Step 3.
                                    value: dropdownValue,
                                    isExpanded: true,
                                    // Step 4.
                                    items: <String>[
                                      'Raised',
                                      'Progress',
                                      'Completed'
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: GoogleFonts.montserrat(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    // Step 5.
                                    onChanged: enabled
                                        ? (String? newValue) {
                                            setState(() {
                                              dropdownValue = newValue!;
                                            });
                                            postStatus();
                                          }
                                        : null,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            padding: const EdgeInsets.only(top: 5, bottom: 20),
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
                                          (BuildContext context, int index) {
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
                          Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: Wrap(
                              children: [
                                Text(
                                  "Description",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  desc,
                                  style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
