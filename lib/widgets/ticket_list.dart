import 'package:flutter/cupertino.dart';
import 'package:ticket_app/models/user.dart';
import 'package:ticket_app/screens/ticket_card.dart';

import '../db/tkt_db.dart';

class TicketList extends StatefulWidget {
  List<Animal> animal;
  List<String> statusFilter;
  String from;
  TicketList({
    super.key,
    required this.animal,
    required this.statusFilter,
    required this.from,
  });

  @override
  State<TicketList> createState() => _TicketListState();
}

class _TicketListState extends State<TicketList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: TktDb.instance.getTktList(widget.animal, widget.statusFilter, widget.from),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data;
          var datalength = data!.length;

          return datalength == 0
              ? const SizedBox(
                height: 200,
                child:  Center(
                  child: Text('No data found'),
                ),
              )
             
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: datalength,
                  itemBuilder: (context, i) => TicketCard(
                        tktNo: data[i].tktNo,
                        tktTitle: data[i].tktTitle,
                        tktDesc: data[i].tktDesc,
                        tktCreatedBy: data[i].tktCreatedBy,
                        tktAssignedTo: data[i].tktAssignedTo,
                        tktStatus: data[i].tktStatus,
                        tktCreatedOn: DateTime.parse(data[i].tktCreatedOn),
                        tktReplyOn: DateTime.parse(data[i].tktReplyOn),
                        tktDocCnt: data[i].tktDocCnt,
                      ));
        } else {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }
      },
    );
  }
}
