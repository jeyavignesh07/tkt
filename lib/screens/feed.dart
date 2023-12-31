import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:filter_list/filter_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arc_text/flutter_arc_text.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ticket_app/db/tkt_db.dart';
import 'package:ticket_app/models/tkt.dart';
import 'package:ticket_app/models/user.dart';
import 'package:ticket_app/models/userList.dart';
import 'package:ticket_app/service/api_base.dart';
import '../routes/routes.dart';
import '../widgets/ticket_list.dart';
import 'sideMenu/side_menu.dart';
import 'package:http/http.dart' as http;

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with SingleTickerProviderStateMixin {
  bool isSideBarClosed = false;

  bool isSideMenuClosed = true;

  late AnimationController _animationController;
  late Animation animation;
  late Animation scalAnimation;

  List<Animal> userList = [];
  List<Animal> selectedUserList = [];

  List<TktStsCount> tktStsList = [];

  List<String> statusList = ['Raised', 'Progress', 'Completed'];
  List<String> selectedStatusList = [];

  String imgUrl = '';
  String empName = '';
  String empId = '';
  int imgloop=0;
  String imageData = '';
  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200))
      ..addListener(() {
        setState(() {});
      });
    animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn));
    scalAnimation = Tween<double>(begin: 1, end: 0.8).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn));
    super.initState();
    tktStsList
        .add(const TktStsCount(red: '0', blue: '0', yellow: '0', black: '0'));
    startMove();

    //getEmpImg();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future startMove() async {
    await getEmpDetails();
    await getActionByUserList();
    await getTktStsCount();
    await getUserListData();
  }

  Future<String> getProfileImage() async {
    imgloop++;
    if(imgloop>5){
      return imageData;
    }
    if (empId.isNotEmpty) {
      var documentDirectory = await getApplicationDocumentsDirectory();
      imageData = '${documentDirectory.path}/profilepic/$empId.jpg';
      if (!await File(imageData).exists()) {
        await getEmpImg();
        getProfileImage();
      }
    }else{
      getProfileImage(); 
    }
    return imageData;
  }

  Future<dynamic> getEmpImg() async {
    var data = await TktDb.instance.getUserInfo();

    if (data.length > 0) {
      var url = Uri.parse(data[0].imgUrl);
      var response = await http.get(url);
      var documentDirectory = await getApplicationDocumentsDirectory();
      var firstPath = "${documentDirectory.path}/profilepic";
      var filePathAndName =
          '${documentDirectory.path}/profilepic/${data[0].empId}.jpg';
      //comment out the next three lines to prevent the image from being saved
      //to the device to show that it's coming from the internet
      await Directory(firstPath).create(recursive: true);
      File file2 = File(filePathAndName);
      file2.writeAsBytesSync(response.bodyBytes);
    }
  }

  Future<dynamic> getEmpDetails() async {
    var data = await TktDb.instance.getUserInfo();
    if (data.length > 0) {
      imgUrl = data[0].imgUrl;
      empName = data[0].empName;
      empId = data[0].empId;
      setState(() {});
    }
  }

  // Future<dynamic> getEmpImg() async {
  //   var data = await TktDb.instance.getUserInfo();

  //   if (data.length > 0) {
  //     var url = Uri.parse(data[0].imgUrl);
  //     var response = await http.get(url);
  //     var documentDirectory = await getApplicationDocumentsDirectory();
  //     var firstPath = "${documentDirectory.path}/profilepic";
  //     var filePathAndName = '${documentDirectory.path}/profilepic/pic.jpg';
  //     //comment out the next three lines to prevent the image from being saved
  //     //to the device to show that it's coming from the internet
  //     await Directory(firstPath).create(recursive: true);
  //     File file2 = File(filePathAndName);
  //     file2.writeAsBytesSync(response.bodyBytes);
  //     setState(() {
  //       imageData = filePathAndName;
  //     });
  //   }
  // }

  Future<dynamic> getEmpName() async {
    var data = await TktDb.instance.getUserInfo();
    if (data.length > 0) {
      return data[0].empName;
    }
  }

  Future getActionByUserList() async {
    var data = await TktDb.instance.getActionByUserList();
    if (data.length > 0) {
      userList = data;
      setState(() {});
    }
  }

  Future getTktStsCount() async {
    //await TktDb.instance.deleteTktStatusSelect();
    var data = await TktDb.instance.getTktStsCount(empId);
    if (data.length > 0) {
      tktStsList = data;
    }
    setState(() {});
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
    }
  }

  Future insertUserList(List<UserList> ul) async {
    await TktDb.instance.createUserList(ul);
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

  void forMyActionStatClick(String status) async {
    Get.toNamed(RoutesClass.updateTktRoute(), arguments: {
      'status': status,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            width: 258,
            height: MediaQuery.of(context).size.height,
            child: const SideMenu(),
          ),
          SafeArea(
            minimum: const EdgeInsets.only(top: 45.0, left: 210.0),
            child: CircleAvatar(
              backgroundColor: const Color(0x22ffffff),
              child: GestureDetector(
                child: const Icon(
                  CupertinoIcons.xmark,
                  color: Colors.red,
                  size: 30,
                ),
                onTap: () {
                  isSideBarClosed = !isSideBarClosed;
                  if (isSideMenuClosed) {
                    _animationController.forward();
                  } else {
                    _animationController.reverse();
                  }
                  setState(() {
                    isSideMenuClosed = isSideBarClosed;
                  });
                },
              ),
            ),
          ),
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(animation.value - 30 * animation.value * pi / 180),
            child: Transform.translate(
              offset: Offset(animation.value * 248, 0),
              child: Transform.scale(
                  scale: scalAnimation.value,
                  child: Container(
                    color: Colors.white,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(0, 10, 18, 10),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Stack(
                                        children: [
                                          Image.asset(
                                              'assets/img/arrow_logo.png',
                                              width: 230,
                                              height: 80,
                                              fit: BoxFit.fill),
                                          Positioned(
                                            // The Positioned widget is used to position the text inside the Stack widget
                                            top: 16,
                                            left: 10,
                                            child: Text(
                                              'Ticket',
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 40,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.blue),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Row(children: [
                                        Column(
                                          children: [
                                            GestureDetector(
                                              // child: CircleAvatar(
                                              //   radius: 30,
                                              //   backgroundImage: Image.file(
                                              //     File(imageData),
                                              //     fit: BoxFit.fill,
                                              //   ).image,
                                              // ),
                                              child: FutureBuilder(
                                                future: getProfileImage(),
                                                builder: (context,
                                                    AsyncSnapshot snapshot) {
                                                  if (snapshot.hasData) {
                                                    return CircleAvatar(
                                                      backgroundImage:
                                                          Image.file(
                                                        File(imageData),
                                                        fit: BoxFit.fill,
                                                      ).image,
                                                      radius: 30,
                                                    );
                                                  } else {
                                                    return const Center(
                                                      child:
                                                          CupertinoActivityIndicator(),
                                                    );
                                                  }
                                                },
                                              ),
                                              onTap: () {
                                                isSideBarClosed =
                                                    !isSideBarClosed;
                                                if (isSideMenuClosed) {
                                                  _animationController
                                                      .forward();
                                                } else {
                                                  _animationController
                                                      .reverse();
                                                }
                                                setState(() {
                                                  isSideMenuClosed =
                                                      isSideBarClosed;
                                                });
                                              },
                                            ),
                                            Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    Container(
                                                      height: 5,
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    SizedBox(
                                                      width: 100,
                                                      child: FutureBuilder(
                                                          future: getEmpName(),
                                                          builder: (context,
                                                              AsyncSnapshot
                                                                  snapshot) {
                                                            if (snapshot
                                                                .hasData) {
                                                              return Text(
                                                                '${snapshot.data}',
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 1,
                                                                style: GoogleFonts.montserrat(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12,
                                                                    color: const Color(
                                                                        0xff0984e3)),
                                                              );
                                                            } else {
                                                              return const Center(
                                                                child:
                                                                    CupertinoActivityIndicator(),
                                                              );
                                                            }
                                                          }),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            )
                                          ],
                                        )
                                      ]),
                                    ],
                                  )
                                ]),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: Text(
                              'For my Action',
                              style: GoogleFonts.sourceSansPro(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                //color: const Color(0xff0984e3)
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                            //elevation: 5.0,
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(15.0),
                            //   side: const BorderSide(
                            //     color: Color(0x6674b9ff),
                            //   ),
                            // ),
                            color: const Color(0xffffffff),
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      splashColor: Colors.red.withAlpha(60),
                                      onTap: () {
                                        forMyActionStatClick("Overdue");
                                      },
                                      child: Column(
                                        children: [
                                          Container(
                                              width: 65,
                                              height: 65,
                                              margin:
                                                  const EdgeInsets.all(10.0),
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.red.shade400,
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      blurRadius: 2,
                                                      spreadRadius: 3,
                                                      color: Colors.grey,
                                                      offset: Offset(0, 1),
                                                    )
                                                  ]),
                                              child: Center(
                                                  child: Stack(children: [
                                                Center(
                                                  child: Text(
                                                    tktStsList[0].red,
                                                    style: const TextStyle(
                                                      fontSize: 30,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFFffffff),
                                                      shadows: <Shadow>[
                                                        Shadow(
                                                          offset:
                                                              Offset(1.0, 1.0),
                                                          blurRadius: 3.0,
                                                          color: Color.fromARGB(
                                                              255, 0, 0, 0),
                                                        ),
                                                      ],
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                const Center(
                                                    child: ArcText(
                                                        radius: 20,
                                                        text: 'Over due',
                                                        textStyle: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          shadows: <Shadow>[
                                                            Shadow(
                                                              offset: Offset(
                                                                  1.0, 1.0),
                                                              blurRadius: 3.0,
                                                              color: Color
                                                                  .fromARGB(255,
                                                                      0, 0, 0),
                                                            ),
                                                          ],
                                                        ),
                                                        startAngle: pi + 1.1,
                                                        startAngleAlignment:
                                                            StartAngleAlignment
                                                                .start,
                                                        placement:
                                                            Placement.outside,
                                                        direction: Direction
                                                            .counterClockwise)),
                                              ]))),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      splashColor: Colors.blue.withAlpha(60),
                                      onTap: () {
                                        forMyActionStatClick("Completed");
                                      },
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 65,
                                            height: 65,
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
                                            child: Center(
                                                child: Stack(children: [
                                              Center(
                                                child: Text(
                                                  tktStsList[0].blue,
                                                  style: const TextStyle(
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFffffff),
                                                    shadows: <Shadow>[
                                                      Shadow(
                                                        offset:
                                                            Offset(1.0, 1.0),
                                                        blurRadius: 3.0,
                                                        color: Color.fromARGB(
                                                            255, 0, 0, 0),
                                                      ),
                                                    ],
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              const Center(
                                                  child: ArcText(
                                                      radius: 20,
                                                      text: 'Completed',
                                                      textStyle: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                        shadows: <Shadow>[
                                                          Shadow(
                                                            offset: Offset(
                                                                1.0, 1.0),
                                                            blurRadius: 3.0,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    0,
                                                                    0,
                                                                    0),
                                                          ),
                                                        ],
                                                      ),
                                                      startAngle: pi + 1.3,
                                                      startAngleAlignment:
                                                          StartAngleAlignment
                                                              .start,
                                                      placement:
                                                          Placement.outside,
                                                      direction: Direction
                                                          .counterClockwise)),
                                            ])),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      splashColor: Colors.yellow.withAlpha(60),
                                      onTap: () {
                                        forMyActionStatClick("Progress");
                                      },
                                      child: Column(
                                        children: [
                                          Container(
                                              width: 65,
                                              height: 65,
                                              margin:
                                                  const EdgeInsets.all(10.0),
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
                                              child: Center(
                                                  child: Stack(children: [
                                                Center(
                                                  child: Text(
                                                    tktStsList[0].yellow,
                                                    style: const TextStyle(
                                                      fontSize: 30,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFFffffff),
                                                      shadows: <Shadow>[
                                                        Shadow(
                                                          offset:
                                                              Offset(1.0, 1.0),
                                                          blurRadius: 3.0,
                                                          color: Color.fromARGB(
                                                              255, 0, 0, 0),
                                                        ),
                                                      ],
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                const Center(
                                                    child: ArcText(
                                                        radius: 20,
                                                        text: 'Progress',
                                                        textStyle: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          shadows: <Shadow>[
                                                            Shadow(
                                                              offset: Offset(
                                                                  1.0, 1.0),
                                                              blurRadius: 3.0,
                                                              color: Color
                                                                  .fromARGB(255,
                                                                      0, 0, 0),
                                                            ),
                                                          ],
                                                        ),
                                                        startAngle: pi + 1.1,
                                                        startAngleAlignment:
                                                            StartAngleAlignment
                                                                .start,
                                                        placement:
                                                            Placement.outside,
                                                        direction: Direction
                                                            .counterClockwise)),
                                              ]))),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      splashColor: Colors.black.withAlpha(60),
                                      onTap: () {
                                        forMyActionStatClick("Raised");
                                      },
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 65,
                                            height: 65,
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
                                            child: Center(
                                                child: Stack(children: [
                                              Center(
                                                child: Text(
                                                  tktStsList[0].black,
                                                  style: const TextStyle(
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFffffff),
                                                    shadows: <Shadow>[
                                                      Shadow(
                                                        offset:
                                                            Offset(1.0, 1.0),
                                                        blurRadius: 3.0,
                                                        color: Color.fromARGB(
                                                            255, 255, 255, 255),
                                                      ),
                                                    ],
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              const Center(
                                                  child: ArcText(
                                                      radius: 20,
                                                      text: 'Raised',
                                                      textStyle: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                        shadows: <Shadow>[
                                                          Shadow(
                                                            offset: Offset(
                                                                1.0, 1.0),
                                                            blurRadius: 3.0,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255),
                                                          ),
                                                        ],
                                                      ),
                                                      startAngle: pi + 0.9,
                                                      startAngleAlignment:
                                                          StartAngleAlignment
                                                              .start,
                                                      placement:
                                                          Placement.outside,
                                                      direction: Direction
                                                          .counterClockwise)),
                                            ])),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                            ),
                          ),
                          // Container(
                          //     width: MediaQuery.of(context).size.width * 0.95,
                          //     height: 130,
                          //     margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                          //     decoration: BoxDecoration(
                          //       border: Border.all(
                          //         color: const Color(0x6674b9ff),
                          //       ),
                          //       borderRadius:
                          //           const BorderRadius.all(Radius.circular(20)),
                          //       color: const Color(0x6674b9ff),
                          //     ),
                          //     child: ListView(
                          //       scrollDirection: Axis.horizontal,
                          //       children: [
                          //         InkWell(
                          //           child: Container(
                          //             height: 90,
                          //             width: 90,
                          //             margin: const EdgeInsets.fromLTRB(
                          //                 10, 5, 5, 5),
                          //             child: Card(
                          //               margin: const EdgeInsets.fromLTRB(
                          //                   2, 10, 2, 10),
                          //               elevation: 3.0,
                          //               shadowColor:
                          //                   Colors.grey.withOpacity(0.5),
                          //               shape: RoundedRectangleBorder(
                          //                   borderRadius:
                          //                       BorderRadius.circular(15.0)),
                          //               child: Padding(
                          //                 padding: const EdgeInsets.fromLTRB(
                          //                     1, 6, 1, 1),
                          //                 child: Column(children: [
                          //                   const Icon(Icons.add,
                          //                       size: 40, color: Colors.black),
                          //                   Text(
                          //                     "Add new \n Task",
                          //                     textAlign: TextAlign.center,
                          //                     style: GoogleFonts.montserrat(
                          //                         fontSize: 16,
                          //                         fontWeight: FontWeight.bold),
                          //                   )
                          //                 ]),
                          //               ),
                          //             ),
                          //           ),
                          //           onTap: () {
                          //             Get.toNamed(
                          //                 RoutesClass.addNewTaskRoute());
                          //           },
                          //         ),
                          //         InkWell(
                          //           child: Container(
                          //             height: 90,
                          //             width: 90,
                          //             margin:
                          //                 const EdgeInsets.fromLTRB(5, 5, 5, 5),
                          //             child: Card(
                          //               margin: const EdgeInsets.fromLTRB(
                          //                   2, 10, 2, 10),
                          //               elevation: 3.0,
                          //               shadowColor:
                          //                   Colors.grey.withOpacity(0.5),
                          //               shape: RoundedRectangleBorder(
                          //                   borderRadius:
                          //                       BorderRadius.circular(15.0)),
                          //               child: Padding(
                          //                 padding: const EdgeInsets.fromLTRB(
                          //                     1, 6, 1, 1),
                          //                 child: Column(children: [
                          //                   const Icon(Icons.update,
                          //                       size: 40, color: Colors.black),
                          //                   Text(
                          //                     "Update \n Tkt",
                          //                     textAlign: TextAlign.center,
                          //                     style: GoogleFonts.montserrat(
                          //                         fontSize: 16,
                          //                         fontWeight: FontWeight.bold),
                          //                   )
                          //                 ]),
                          //               ),
                          //             ),
                          //           ),
                          //           onTap: () {
                          //             Get.toNamed(RoutesClass.updateTktRoute());
                          //           },
                          //         ),
                          //       ],
                          //     )
                          //   ),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.95,
                              height: 40,
                              margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0x6674b9ff),
                                ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                                color: const Color(0xff74b9ff),
                              ),
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  // InkWell(
                                  //   child: SizedBox(
                                  //     height: 40,
                                  //     width: 40,
                                  //     child: Card(
                                  //       elevation: 3.0,
                                  //       shadowColor:
                                  //           Colors.grey.withOpacity(0.5),
                                  //       shape: RoundedRectangleBorder(
                                  //           borderRadius:
                                  //               BorderRadius.circular(15.0)),
                                  //       child: const Padding(
                                  //         padding:
                                  //             EdgeInsets.fromLTRB(1, 0, 1, 0),
                                  //         child: Center(
                                  //           child: Icon(
                                  //             Icons.filter_list,
                                  //             size: 20,
                                  //           ),
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  //   onTap: () {},
                                  // ),
                                  InkWell(
                                    child: SizedBox(
                                      height: 40,
                                      width: 120,
                                      child: Card(
                                        elevation: 3.0,
                                        shadowColor:
                                            Colors.grey.withOpacity(0.5),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0)),
                                        child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                1, 0, 1, 0),
                                            child: Row(children: [
                                              const Icon(Icons.add,
                                                  size: 16,
                                                  color: Colors.black),
                                              Text(
                                                "Add new Task",
                                                textAlign: TextAlign.center,
                                                style:
                                                    GoogleFonts.sourceSansPro(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              )
                                            ])),
                                      ),
                                    ),
                                    onTap: () {
                                      Get.toNamed(
                                          RoutesClass.addNewTaskRoute());
                                    },
                                  ),
                                  InkWell(
                                    child: SizedBox(
                                      height: 40,
                                      width: 100,
                                      child: Card(
                                        elevation: 3.0,
                                        shadowColor:
                                            Colors.grey.withOpacity(0.5),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0)),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              1, 0, 1, 0),
                                          child: Center(
                                              child: Text(
                                            "Action By",
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
                                        shadowColor:
                                            Colors.grey.withOpacity(0.5),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0)),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              1, 0, 1, 0),
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
                          TicketList(
                            animal: selectedUserList,
                            statusFilter: selectedStatusList,
                            from: "C",
                          ),
                        ],
                      ),
                    ),
                  )),
            ),
          )
        ],
      ),
    );
  }
}
