import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ticket_app/routes/routes.dart';
import 'package:ticket_app/screens/tktDetailView.dart';

class TicketCard extends StatefulWidget {
  final String tktNo;
  final String tktTitle;
  final String tktDesc;
  final String tktCreatedBy;
  final String tktStatus;
  final DateTime tktCreatedOn;
  final DateTime tktReplyOn;

  const TicketCard({
    super.key,
    required this.tktNo,
    required this.tktTitle,
    required this.tktDesc,
    required this.tktCreatedBy,
    required this.tktStatus,
    required this.tktCreatedOn,
    required this.tktReplyOn,
  });

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.30,
      width: MediaQuery.of(context).size.width * 0.90,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 5, left: 15, right: 15),
        child: InkWell(
          splashColor: Colors.red.withAlpha(30),
          onTap: () {
            Get.to(TktDetailView(
              tktNo: widget.tktNo,
            ));
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
                  Text(
                    widget.tktTitle,
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Container(
                      height: 1.0,
                      width: MediaQuery.of(context).size.width * 0.90,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5.0),
                    child: Row(children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.33,
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
                              DateFormat()
                                  .add_yMMMd()
                                  .format(widget.tktCreatedOn),
                              style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.20,
                        child: Column(
                          children: const [
                            Icon(Icons.arrow_circle_right_outlined,
                                size: 30, color: Colors.black),
                          ],
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.33,
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
                              DateFormat()
                                  .add_yMMMd()
                                  .format(widget.tktReplyOn),
                              style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            )
                          ],
                        ),
                      ),
                    ]),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(100.0, 10.0, 0.0, 10.0),
                    child: Row(children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.07,
                          width: MediaQuery.of(context).size.width * 0.20,
                          child: InkWell(
                              splashColor: Colors.red.withAlpha(60),
                              onTap: () {
                                Get.toNamed(RoutesClass.tktAttachmentsRoute());
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
                                    Icons.attach_file_rounded,
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
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.07,
                          width: MediaQuery.of(context).size.width * 0.20,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ]),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5.0),
                    child: Row(children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.33,
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
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.20,
                        child: Column(
                          children: const [
                            Icon(Icons.arrow_circle_right_outlined,
                                size: 30, color: Colors.black),
                          ],
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.33,
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
                              widget.tktStatus,
                              style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            )
                          ],
                        ),
                      ),
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
