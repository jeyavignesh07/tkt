import 'dart:convert';

import 'package:filter_list/filter_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ticket_app/db/tkt_db.dart';
import 'package:ticket_app/models/tkt.dart';
import 'package:ticket_app/models/user.dart';
import 'package:ticket_app/service/api_base.dart';
import '../widgets/ticket_list.dart';

class InfoTktPage extends StatefulWidget {
  const InfoTktPage({super.key});

  @override
  State<InfoTktPage> createState() => _InfoTktPageState();
}

class _InfoTktPageState extends State<InfoTktPage> {
  late String empId;
  late String lTktNo;

  List<Animal> userList = [];
  List<Animal> selectedUserList = [];

  List<String> statusList = ['Raised', 'Progress', 'Completed'];
  List<String> selectedStatusList = [];

  bool _isLoading = false;
  bool _isTaskCreated = false;

  @override
  void initState() {
    super.initState();
    startMove();
    getActionByUserList();
  }

  Future startMove() async {
    setState(() {
      _isLoading = true;
    });
    empId = await getEmpId();
    lTktNo = await getLastTkt();
    setState(() {});
    await getTktListData();
    setState(() {
      _isLoading = false;
    });
  }

  Future<String> getEmpId() async {
    var data = await TktDb.instance.getUserInfo();
    return data[0].empId;
  }

  Future<String> getLastTkt() async {
    var data = await TktDb.instance.getLastTkt();
    if (data.length > 0) {
      return data[0].tktNo;
    } else {
      return "0";
    }
  }

  Future getActionByUserList() async {
    var data = await TktDb.instance.getRaisedByUserList('I');
    if (data.length > 0) {
      userList = data;
      setState(() {});
    }
  }

  Future getTktListData() async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'GET', Uri.parse(ApiBase.baseUrl + ApiBase.getTktEndPoint));
    request.body = json.encode({"empId": empId, "tktNo": lTktNo});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      var data1 = jsonDecode(data);
      var tktHdr = data1["tkt"] as List;
      var tktAssignedTo = data1["tkt1"] as List;
      var tktCopiedTo = data1["tkt2"] as List;
      var tktAttachments = data1["tkt3"] as List;
      var tktTags = data1["tkt4"] as List;

      List<TktHdr> tktHdrList =
          tktHdr.map((tagJson) => TktHdr.fromJson(tagJson)).toList();
      List<TktDtlAssign> tktAssignedToList = tktAssignedTo
          .map((tagJson) => TktDtlAssign.fromJson(tagJson))
          .toList();
      List<TktDtlCopy> tktCopiedToList =
          tktCopiedTo.map((tagJson) => TktDtlCopy.fromJson(tagJson)).toList();
      List<TktDtlAttachment> tktAttachmentList = tktAttachments
          .map((tagJson) => TktDtlAttachment.fromJson(tagJson))
          .toList();
      List<TktDtlTag> tktTagsList =
          tktTags.map((tagJson) => TktDtlTag.fromJson(tagJson)).toList();
      await TktDb.instance.createTktHdrList(tktHdrList);
      await TktDb.instance.createTktDtlAssignToList(tktAssignedToList);
      await TktDb.instance.createTktDtlCopyToList(tktCopiedToList);
      await TktDb.instance.createTktAttachments(tktAttachmentList);
      await TktDb.instance.createTktDtlTagList(tktTagsList);
    } else {
      print(response.reasonPhrase);
    }
  }

  void openFilterDialog() async {
    await FilterListDialog.display<Animal>(
      context,
      listData: userList,
      selectedListData: selectedUserList,
      choiceChipLabel: (user) => user!.empName,
      validateSelectedItem: (list, val) => list!.contains(val),
      onItemSearch: (user, query) {
        return user.empName.toLowerCase().contains(query.toLowerCase());
      },
      onApplyButtonClick: (list) {
        setState(() {
          selectedUserList = List.from(list!);
        });
        Navigator.pop(context);
      },
    );
  }

  void openStatusFilterDialog() async {
    await FilterListDialog.display<String>(
      context,
      listData: statusList,
      selectedListData: selectedStatusList,
      choiceChipLabel: (stat) => stat!,
      validateSelectedItem: (list, val) => list!.contains(val),
      onItemSearch: (stat, query) {
        return stat.toLowerCase().contains(query.toLowerCase());
      },
      onApplyButtonClick: (list) {
        setState(() {
          selectedStatusList = List.from(list!);
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
            onRefresh: startMove,
            child: ListView(children: [
              Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: 40,
                  margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0x6674b9ff),
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: const Color(0xff74b9ff),
                  ),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      InkWell(
                        child: SizedBox(
                          height: 40,
                          width: 40,
                          child: Card(
                            elevation: 3.0,
                            shadowColor: Colors.grey.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            child: const Padding(
                              padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
                              child: Center(
                                child: Icon(
                                  Icons.filter_list,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        onTap: () {},
                      ),
                      InkWell(
                        child: SizedBox(
                          height: 40,
                          width: 100,
                          child: Card(
                            elevation: 3.0,
                            shadowColor: Colors.grey.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(1, 0, 1, 0),
                              child: Center(
                                  child: Text(
                                "Raised By",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.sourceSansPro(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                            ),
                          ),
                        ),
                        onTap: () {
                          openFilterDialog();
                        },
                      ),
                      InkWell(
                        child: SizedBox(
                          height: 40,
                          width: 100,
                          child: Card(
                            elevation: 3.0,
                            shadowColor: Colors.grey.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(1, 0, 1, 0),
                              child: Center(
                                  child: Text(
                                "Status",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.sourceSansPro(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                            ),
                          ),
                        ),
                        onTap: () {
                          openStatusFilterDialog();
                        },
                      ),
                    ],
                  )),
              Center(
                child: !_isLoading
                    ? const Center()
                    : const CircularProgressIndicator(),
              ),
              TicketList(
                animal: selectedUserList,
                statusFilter: selectedStatusList,
                from: "I",
              ),
            ])));
  }
}
