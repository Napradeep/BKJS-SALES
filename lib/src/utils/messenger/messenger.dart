

import 'dart:developer';

import 'package:flutter/material.dart';
class Messenger {
  static final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();


  static alertError(String msg) => alert(msg: msg,color:  Colors.red);
  static alertSuccess(String msg) => alert(msg: msg,color:  Colors.green);

  static alert({required String msg, Color? color}) {
    if(msg.trim().isEmpty) return;
    log(msg);

    rootScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        showCloseIcon: true,
        closeIconColor: Colors.white,
        duration: const Duration(milliseconds: 3500),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        shape: const RoundedRectangleBorder(),
        content: Text(
          msg,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  static pop(BuildContext context) {
    showModalBottomSheet<void>(
      constraints: const BoxConstraints.expand(),
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.blue[100],
          child: ListView.builder(
            // controller: scrollController,
            itemCount: 25,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(title: Text('Item $index'));
            },
          ),
        );
      },
    );
  }
}