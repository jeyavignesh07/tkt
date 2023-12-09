import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ticket_app/db/tkt_db.dart';
import 'package:ticket_app/screens/chat.dart';
import 'package:ticket_app/screens/tktDetailView.dart';
import 'package:ticket_app/screens/tkt_attachments.dart';
import 'package:badges/badges.dart' as badges;

class TicketCard extends StatefulWidget {
  final String tktNo;
  final String tktTitle;
  final String tktDesc;
  final String tktCreatedBy;
  final String tktAssignedTo;
  final String tktStatus;
  final DateTime tktCreatedOn;
  final DateTime tktReplyOn;
  final int tktDocCnt;

  const TicketCard({
    super.key,
    required this.tktNo,
    required this.tktTitle,
    required this.tktDesc,
    required this.tktCreatedBy,
    required this.tktAssignedTo,
    required this.tktStatus,
    required this.tktCreatedOn,
    required this.tktReplyOn,
    required this.tktDocCnt,
  });

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  String tktNumber = '';
  @override
  void initState() {
    super.initState();
    tktNumber = widget.tktNo.replaceAll('TKT', '');
  }

  Future<void> ticketCardClick() async {
    var data = await TktDb.instance.getSharedFiles();
    if (data.length > 0) {
      Get.to(TktAttachments(
        tktNo: widget.tktNo,
      ));
    } else {
      Get.to(TktDetailView(
        tktNo: widget.tktNo,
      ));
    }
  }

  chatClick() async {
    final doc = await FirebaseChatCore.instance
        .getFirebaseFirestore()
        .collection('rooms')
        .doc(widget.tktNo)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      List<String> userId = List<String>.from(data['userIds'] as List);
      fa.User? firebaseUser = fa.FirebaseAuth.instance.currentUser;
      if (!userId.contains(firebaseUser!.uid)) {
        userId.add(firebaseUser.uid);
        await FirebaseChatCore.instance
            .getFirebaseFirestore()
            .collection('rooms')
            .doc(widget.tktNo)
            .set({
          'createdAt': data['createdAt'],
          'imageUrl': data['imageUrl'],
          'metadata': data['metadata'],
          'name': data['name'],
          'type': 'group',
          'updatedAt': data['updatedAt'],
          'userIds': userId,
        });
        Get.to(ChatPage(
          room: widget.tktNo,
        ));
      } else {
        Get.to(ChatPage(
          room: widget.tktNo,
        ));
      }
    } else {
      await FirebaseChatCore.instance
          .createGroupRoom(ids: widget.tktNo, name: widget.tktNo);
      chatClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.14,
      width: MediaQuery.of(context).size.width * 0.90,
      child: Padding(
        padding: const EdgeInsets.only(top: 3, bottom: 3, left: 15, right: 15),
        child: InkWell(
          splashColor: Colors.red.withAlpha(30),
          onTap: () {
            ticketCardClick();
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0x6674b9ff),
              ),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: const Color(0x6674b9ff),
            ),
            padding: const EdgeInsets.all(0),
            child: Container(
              margin: const EdgeInsets.only(top: 5),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 14, right: 4),
                      //   child: Text(
                      //     widget.tktCreatedBy,
                      //     overflow: TextOverflow.ellipsis,
                      //     style: GoogleFonts.montserrat(
                      //       color: Colors.black,
                      //       fontWeight: FontWeight.w600,
                      //       fontSize: 16,
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 4, right: 4),
                      //   child: Text(
                      //     tktNumber,
                      //     overflow: TextOverflow.ellipsis,
                      //     style: GoogleFonts.montserrat(
                      //       color: Colors.black,
                      //       fontWeight: FontWeight.w600,
                      //       fontSize: 16,
                      //     ),
                      //   ),
                      // ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4, right: 4),
                          child: Text(
                            widget.tktTitle,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('d/M').format(widget.tktCreatedOn),
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const Icon(Icons.arrow_forward,
                          size: 16, color: Colors.black),
                      Text(
                        DateFormat('d/M').format(widget.tktReplyOn),
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 14),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Container(
                      height: 1.0,
                      width: MediaQuery.of(context).size.width * 0.90,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(2, 2, 2, 2),
                    //padding: const EdgeInsets.fromLTRB(4, 1, 4, 1),
                    child: Row(children: [
                      // Container(
                      //   height: MediaQuery.of(context).size.height * 0.05,
                      //   width: MediaQuery.of(context).size.width * 0.30,
                      //   decoration: BoxDecoration(
                      //     border: Border.all(
                      //       color: const Color(0x6674b9ff),
                      //     ),
                      //     borderRadius:
                      //         const BorderRadius.all(Radius.circular(3)),
                      //     //color: const Color(0x6674b9ff),
                      //   ),
                      //   child: Column(
                      //     children: [
                      //       const Padding(padding: EdgeInsets.only(top: 8)),
                      //       Text(
                      //         DateFormat()
                      //             .add_yMMMd()
                      //             .format(widget.tktCreatedOn),
                      //         style: GoogleFonts.montserrat(
                      //           color: Colors.black,
                      //           fontWeight: FontWeight.w600,
                      //           fontSize: 15,
                      //         ),
                      //       )
                      //     ],
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: MediaQuery.of(context).size.height * 0.05,
                      //   width: MediaQuery.of(context).size.width * 0.10,
                      //   child: const Column(
                      //     children: [
                      //       Icon(Icons.arrow_circle_right_outlined,
                      //           size: 30, color: Colors.black),
                      //     ],
                      //   ),
                      // ),
                      // Container(
                      //   height: MediaQuery.of(context).size.height * 0.05,
                      //   width: MediaQuery.of(context).size.width * 0.30,
                      //   decoration: BoxDecoration(
                      //     border: Border.all(
                      //       color: const Color(0x6674b9ff),
                      //     ),
                      //     borderRadius:
                      //         const BorderRadius.all(Radius.circular(3)),
                      //     //color: const Color(0x6674b9ff),
                      //   ),
                      //   child: Column(
                      //     children: [
                      //       const Padding(padding: EdgeInsets.only(top: 8)),
                      //       Text(
                      //         DateFormat()
                      //             .add_yMMMd()
                      //             .format(widget.tktReplyOn),
                      //         style: GoogleFonts.montserrat(
                      //           color: Colors.black,
                      //           fontWeight: FontWeight.w600,
                      //           fontSize: 15,
                      //         ),
                      //       )
                      //     ],
                      //   ),
                      // ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.20,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0x6674b9ff),
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(3)),
                          //color: const Color(0x6674b9ff),
                        ),
                        child: Column(
                          children: [
                            const Padding(padding: EdgeInsets.only(top: 8)),
                            Text(
                              widget.tktCreatedBy,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.10,
                        child: const Column(
                          children: [
                            Icon(Icons.arrow_circle_right_outlined,
                                size: 30, color: Colors.black),
                          ],
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.20,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0x6674b9ff),
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(3)),
                          //color: const Color(0x6674b9ff),
                        ),
                        child: Column(
                          children: [
                            const Padding(padding: EdgeInsets.only(top: 8)),
                            Text(
                              widget.tktAssignedTo,
                              style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                          width: MediaQuery.of(context).size.width * 0.20,
                          child: InkWell(
                              splashColor: Colors.red.withAlpha(60),
                              onTap: () {
                                Get.to(TktAttachments(
                                  tktNo: widget.tktNo,
                                ));
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: widget.tktDocCnt == 0
                                        ? Colors.red
                                        : Colors.blue,
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 2,
                                        spreadRadius: 3,
                                        color: Colors.grey,
                                        offset: Offset(0, 1),
                                      )
                                    ]),
                                child: widget.tktDocCnt == 0
                                    ? const Center(
                                        child: Icon(
                                          Icons.attach_file_rounded,
                                          size: 30,
                                          color: Colors.white,
                                          shadows: <Shadow>[
                                            Shadow(
                                              offset: Offset(1.0, 1.0),
                                              blurRadius: 1.0,
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Center(
                                        child: badges.Badge(
                                          badgeStyle: const badges.BadgeStyle(
                                            badgeColor: Colors.red,
                                          ),
                                          badgeContent: Text(
                                            widget.tktDocCnt.toString(),
                                            style: GoogleFonts.montserrat(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.attach_file_rounded,
                                            size: 30,
                                            color: Colors.white,
                                            shadows: <Shadow>[
                                              Shadow(
                                                offset: Offset(1.0, 1.0),
                                                blurRadius: 1.0,
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ))),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                          width: MediaQuery.of(context).size.width * 0.20,
                          child: InkWell(
                              splashColor: Colors.red.withAlpha(60),
                              onTap: () {
                                chatClick();
                              },
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                margin: const EdgeInsets.all(0.0),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 2,
                                        spreadRadius: 3,
                                        color: Colors.grey,
                                        offset: Offset(0, 1),
                                      )
                                    ]),
                                child: const Center(
                                  child: Icon(
                                    Icons.message_rounded,
                                    size: 30,
                                    color: Colors.white,
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 1.0,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                    ],
                                  ),
                                ),
                              ))),
                      //     SizedBox(
                      // height: MediaQuery.of(context).size.height * 0.05,
                      // width: MediaQuery.of(context).size.width * 0.20,
                      // child: InkWell(
                      //     splashColor: Colors.red.withAlpha(60),
                      //     onTap: () {
                      //       chatClick();
                      //     },
                      //     child: Container(
                      //       padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      //       margin: const EdgeInsets.all(0.0),
                      //       decoration: const BoxDecoration(
                      //           shape: BoxShape.circle,
                      //           color: Colors.red,
                      //           boxShadow: [
                      //             BoxShadow(
                      //               blurRadius: 2,
                      //               spreadRadius: 3,
                      //               color: Colors.grey,
                      //               offset: Offset(0, 1),
                      //             )
                      //           ]),
                      //       child: const Center(
                      //         child: Icon(
                      //           Icons.message_rounded,
                      //           size: 30,
                      //           color: Colors.white,
                      //           shadows: <Shadow>[
                      //             Shadow(
                      //               offset: Offset(1.0, 1.0),
                      //               blurRadius: 1.0,
                      //               color:
                      //                   Color.fromARGB(255, 255, 255, 255),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ))),
                    ]),
                  ),
                  // Container(
                  //   margin: const EdgeInsets.fromLTRB(100.0, 10.0, 0.0, 10.0),
                  //   child: Row(children: [
                  //     SizedBox(
                  //         height: MediaQuery.of(context).size.height * 0.07,
                  //         width: MediaQuery.of(context).size.width * 0.20,
                  //         child: InkWell(
                  //             splashColor: Colors.red.withAlpha(60),
                  //             onTap: () {
                  //               Get.to(TktAttachments(
                  //                 tktNo: widget.tktNo,
                  //               ));
                  //             },
                  //             child: Container(
                  //               padding:
                  //                   const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  //               decoration: const BoxDecoration(
                  //                   shape: BoxShape.circle,
                  //                   color: Colors.red,
                  //                   boxShadow: [
                  //                     BoxShadow(
                  //                       blurRadius: 2,
                  //                       spreadRadius: 3,
                  //                       color: Colors.grey,
                  //                       offset: Offset(0, 1),
                  //                     )
                  //                   ]),
                  //               child: const Center(
                  //                 child: Icon(
                  //                   Icons.attach_file_rounded,
                  //                   size: 30,
                  //                   color: Colors.white,
                  //                   shadows: <Shadow>[
                  //                     Shadow(
                  //                       offset: Offset(1.0, 1.0),
                  //                       blurRadius: 1.0,
                  //                       color:
                  //                           Color.fromARGB(255, 255, 255, 255),
                  //                     ),
                  //                   ],
                  //                 ),
                  //               ),
                  //             ))),
                  //     SizedBox(
                  //         height: MediaQuery.of(context).size.height * 0.07,
                  //         width: MediaQuery.of(context).size.width * 0.20,
                  //         child: Container(
                  //           padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  //           margin: const EdgeInsets.all(0.0),
                  //           decoration: const BoxDecoration(
                  //               shape: BoxShape.circle,
                  //               color: Colors.red,
                  //               boxShadow: [
                  //                 BoxShadow(
                  //                   blurRadius: 2,
                  //                   spreadRadius: 3,
                  //                   color: Colors.grey,
                  //                   offset: Offset(0, 1),
                  //                 )
                  //               ]),
                  //           child: const Center(
                  //             child: Icon(
                  //               Icons.message_rounded,
                  //               size: 30,
                  //               color: Colors.white,
                  //               shadows: <Shadow>[
                  //                 Shadow(
                  //                   offset: Offset(1.0, 1.0),
                  //                   blurRadius: 1.0,
                  //                   color: Color.fromARGB(255, 255, 255, 255),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         )),
                  //   ]),
                  // ),
                  const SizedBox(
                    height: 3,
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 4),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            child: Column(
                              children: [
                                Text(
                                  widget.tktStatus,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                )
                              ],
                            ),
                          ),
                          // SizedBox(
                          //   height: MediaQuery.of(context).size.height * 0.05,
                          //   width: MediaQuery.of(context).size.width * 0.10,
                          //   child: const Column(
                          //     children: [
                          //       Icon(Icons.arrow_circle_right_outlined,
                          //           size: 30, color: Colors.black),
                          //     ],
                          //   ),
                          // ),
                          // Container(
                          //   height: MediaQuery.of(context).size.height * 0.05,
                          //   width: MediaQuery.of(context).size.width * 0.30,
                          //   decoration: BoxDecoration(
                          //     border: Border.all(
                          //       color: const Color(0x6674b9ff),
                          //     ),
                          //     borderRadius:
                          //         const BorderRadius.all(Radius.circular(3)),
                          //     //color: const Color(0x6674b9ff),
                          //   ),
                          //   child: Column(
                          //     children: [
                          //       const Padding(padding: EdgeInsets.only(top: 8)),
                          //       Text(
                          //         widget.tktStatus,
                          //         style: GoogleFonts.montserrat(
                          //           color: Colors.black,
                          //           fontWeight: FontWeight.w600,
                          //           fontSize: 15,
                          //         ),
                          //       )
                          //     ],
                          //   ),
                          // ),
                          // SizedBox(
                          //     height: MediaQuery.of(context).size.height * 0.05,
                          //     width: MediaQuery.of(context).size.width * 0.20,
                          //     child: InkWell(
                          //         splashColor: Colors.red.withAlpha(60),
                          //         onTap: () {
                          //           chatClick();
                          //         },
                          //         child: Container(
                          //           padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          //           margin: const EdgeInsets.all(0.0),
                          //           decoration: const BoxDecoration(
                          //               shape: BoxShape.circle,
                          //               color: Colors.red,
                          //               boxShadow: [
                          //                 BoxShadow(
                          //                   blurRadius: 2,
                          //                   spreadRadius: 3,
                          //                   color: Colors.grey,
                          //                   offset: Offset(0, 1),
                          //                 )
                          //               ]),
                          //           child: const Center(
                          //             child: Icon(
                          //               Icons.message_rounded,
                          //               size: 30,
                          //               color: Colors.white,
                          //               shadows: <Shadow>[
                          //                 Shadow(
                          //                   offset: Offset(1.0, 1.0),
                          //                   blurRadius: 1.0,
                          //                   color:
                          //                       Color.fromARGB(255, 255, 255, 255),
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //         ))),
                        ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
