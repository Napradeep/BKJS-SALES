import 'package:bkjs_sales/src/utils/messenger/messenger.dart';
import 'package:bkjs_sales/src/utils/router/router.dart';
import 'package:bkjs_sales/src/utils/spacer/spacer.dart';
import 'package:bkjs_sales/src/view/homescreen.dart';
import 'package:bkjs_sales/src/widget/button.dart';
import 'package:bkjs_sales/src/widget/textformfield.dart';
import 'package:flutter/material.dart';

class RegistrationScreen extends StatelessWidget {
  final usernameCTRL = TextEditingController();
  final regNoCTRL = TextEditingController();
  RegistrationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text("Register"), backgroundColor: Colors.white),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                vSpace36,
                CircleAvatar(
                  maxRadius: 70,
                  backgroundColor: Colors.transparent,
                  child: Image.asset(
                    'assets/download.png',
                    width: 150,
                    height: 150,
                  ),
                ),
                vSpace36,
                // Registration Id
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Register Id",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                vSpace8,
                MyTextfomrfiledbox(controller: regNoCTRL),
                vSpace18,
                // Full Name
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Full Name",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                vSpace8,
                MyTextfomrfiledbox(controller: usernameCTRL),
                vSpace36,
                Button(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.black,
                  onpressed: () {
                    String name = usernameCTRL.text.trim();
                    String regID = regNoCTRL.text.trim();
                    if (name.isEmpty && regID.isEmpty) {
                      Messenger.alertError("Please fill the Filed");
                    }
                    if (name.isEmpty) {
                      Messenger.alertError("Please enter Name");
                    }
                    if (regID.isEmpty) {
                      Messenger.alertError("Please enter the Registration ID");
                    }
                    if (name.isNotEmpty && regID.isNotEmpty) {
                      MyRouter.pushRemoveUntil(
                        screen: HomeScreen(
                          url: 'https://sales.bhangarukalasam.com',
                        ),
                      );
                    }
                  },
                  texxt: "Submit",
                  width: double.infinity,
                  height: 50,
                  txtcolor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
