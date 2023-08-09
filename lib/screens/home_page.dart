import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ticket_app/screens/tktForInfo.dart';
import 'package:ticket_app/screens/update_tkt.dart';


import '../db/tkt_db.dart';
import '../routes/routes.dart';
import 'feed.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
  FeedPage(),
  UpdateTktPage(),
  InfoTktPage(),
];
  @override
  void initState() {
    super.initState();
    getUserData();
  }
  Future<dynamic> getUserData() async {
    var data = await TktDb.instance.getUserInfo();
    var len = data.length;
    if(len==0){
      Get.toNamed(RoutesClass.getLogInRoute());
    }
  }
  void onItemTapped(int index) {
  setState(() {
    selectedIndex = index;
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:  DoubleBackToCloseApp(
        snackBar: const SnackBar(
            content: Text('Tap back again to leave'),
          ),
        child: _pages.elementAt(selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xffffffff),
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        selectedLabelStyle: GoogleFonts.montserrat(fontSize: 10,fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 10,fontWeight: FontWeight.bold),        
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin,size: 40,),
            label: "Raised by Me",
            backgroundColor: Colors.blue,
            ),
            BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions,size: 40,),
            label: "For my Action",
            backgroundColor: Colors.red,
            ),
            BottomNavigationBarItem(
            icon: Icon(Icons.info,size: 40,),
            label: "For my Info",
            backgroundColor: Colors.red,
            ),
        ],
      ),
    );
  }
}