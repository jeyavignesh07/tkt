import 'package:get/get.dart';
import 'package:ticket_app/screens/add_new_task.dart';
import 'package:ticket_app/screens/home_page.dart';
import 'package:ticket_app/screens/login.dart';
import 'package:ticket_app/screens/tktForInfo.dart';
import 'package:ticket_app/screens/update_tkt.dart';


class RoutesClass{
  static String home="/home";
  static String login="/login";
  static String addNewTask="/addNewTask";
  static String updateTkt="/updateTkt";
  static String infoTkt="/infoTkt";
  static String tktAttachments="/tktAttachments";


  static String getHomeRoute()=>home;
  static String getLogInRoute()=>login;
  static String addNewTaskRoute()=>addNewTask;
  static String updateTktRoute()=>updateTkt;
  static String infoTktRoute()=>infoTkt;
  static String tktAttachmentsRoute()=>tktAttachments;


  static List<GetPage> routes =[
    GetPage(name: home, page: ()=> const HomePage(), transition: Transition.fade, transitionDuration: const Duration(milliseconds: 500)),
    GetPage(name: login, page: ()=> const Login(), transition: Transition.fade, transitionDuration: const Duration(milliseconds: 500)),
    GetPage(name: addNewTask, page: ()=> const AddNewTask(), transition: Transition.fade, transitionDuration: const Duration(milliseconds: 500)),
    GetPage(name: updateTkt, page: ()=> const UpdateTktPage(), transition: Transition.fade, transitionDuration: const Duration(milliseconds: 500)),
    GetPage(name: infoTkt, page: ()=> const InfoTktPage(), transition: Transition.fade, transitionDuration: const Duration(milliseconds: 500)),
  ];
}