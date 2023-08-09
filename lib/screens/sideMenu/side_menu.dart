import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rive/rive.dart';
import 'package:ticket_app/db/tkt_db.dart';
import '../../models/rive_asset.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  RiveAsset selectedMenu = sideMenus.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: 258,
          height: MediaQuery.of(context).size.height,
          color: const Color(0xFF17203A),
          child: Column(children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, top: 12,right: 20),
              child: InfoCard(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
              child: Text(
                "Browse".toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.white70),
              ),
            ),
            ...sideMenus.map((menu) => SideMenuTile(
                  menu: menu,
                  riveonInit: (artboard) {
                    StateMachineController controller =
                        RiveUtils.getRiveController(artboard,
                            stateMachineName: menu.stateMachineName);
                    menu.input = controller.findSMI("active") as SMIBool;
                  },
                  press: () {
                    menu.input!.change(true);
                    Future.delayed(const Duration(seconds: 1), () {
                      menu.input!.change(false);
                    });
                    setState(() {
                      selectedMenu = menu;
                    });
                  },
                  isActive: selectedMenu == menu,
                )),
          ]),
        ),
      ),
    );
  }
}

class RiveUtils {
  static StateMachineController getRiveController(Artboard artboard,
      {stateMachineName = "State Machine 1"}) {
    StateMachineController? controller =
        StateMachineController.fromArtboard(artboard, stateMachineName);
    artboard.addController(controller!);
    return controller;
  }
}

class SideMenuTile extends StatelessWidget {
  const SideMenuTile({
    super.key,
    required this.menu,
    required this.press,
    required this.riveonInit,
    required this.isActive,
  });

  final RiveAsset menu;
  final VoidCallback press;
  final ValueChanged<Artboard> riveonInit;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 24),
          child: Divider(
            color: Colors.white24,
            height: 1,
          ),
        ),
        Stack(children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            height: 56,
            width: isActive ? 258 : 0,
            left: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0XFF6792FF),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
          ListTile(
            onTap: press,
            leading: SizedBox(
                height: 34,
                width: 34,
                child: RiveAnimation.asset(
                  menu.src,
                  artboard: menu.artboard,
                  onInit: riveonInit,
                )),
            title: Text(
              menu.title,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ]),
      ],
    );
  }
}

class InfoCard extends StatefulWidget {
  const InfoCard({
    super.key,
  });

  @override
  State<InfoCard> createState() => _InfoCardState();
  
}

class _InfoCardState extends State<InfoCard> {
  Future<dynamic> getEmpImg() async {
    var data = await TktDb.instance.getUserInfo();
    if (data.length > 0) {
      return data[0].imgUrl;
    }
  }

  Future<dynamic> getEmpName() async {
    var data = await TktDb.instance.getUserInfo();
    if (data.length > 0) {
      return data[0].empName;
    }
  }

  Future<dynamic> getEmpDesg() async {
    var data = await TktDb.instance.getUserInfo();
    if (data.length > 0) {
      return data[0].dsgntn;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        child: FutureBuilder(
          future: getEmpImg(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return CircleAvatar(
                backgroundImage: NetworkImage('${snapshot.data}'),
                radius: 30,
              );
            } else {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }
          },
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 7.0),
        child: FutureBuilder(
            future: getEmpName(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return Text(
                  '${snapshot.data}',
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: const Color(0xffffffff)),
                );
              } else {
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              }
            }),
      ),
      subtitle: FutureBuilder(
          future: getEmpDesg(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return Text(
                '${snapshot.data}',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: const Color(0xffffffff)),
              );
            } else {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }
          }),
    );
  }
}
