import 'package:rive/rive.dart';

class RiveAsset {
  final String src, artboard, stateMachineName, title;
  late SMIBool? input;
  RiveAsset(
    this.src,
    {required this.artboard,
    required this.stateMachineName,
    required this.title,
    this.input}
  );
  set setInput(SMIBool status){
    input = status;
  }
}


List<RiveAsset> sideMenus=[
  RiveAsset(
    "assets/img/iconset.riv",
    artboard: "HOME",
    stateMachineName: "HOME_interactivity",
     title: "Home"
  ),
   RiveAsset(
    "assets/img/iconset.riv",
    artboard: "SEARCH",
    stateMachineName: "SEARCH_Interactivity",
     title: "Search"
  ),
   RiveAsset(
    "assets/img/iconset.riv",
    artboard: "CHAT",
    stateMachineName: "CHAT_Interactivity",
     title: "Help"
  ),
];