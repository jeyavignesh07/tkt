import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Message {
  static void taskErrorOrWarning(
      String taskName, String taskErrorOrWarning, String bgColor) {
    Get.snackbar(taskName, taskErrorOrWarning,
        backgroundColor: Color(int.parse(bgColor.replaceAll('#', '0xff'))),
        titleText: Text(
          taskName,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        messageText: Text(
          taskErrorOrWarning,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ));
    
  }
}
