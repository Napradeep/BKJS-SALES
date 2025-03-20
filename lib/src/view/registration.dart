import 'package:bkjs_sales/src/provider/registerprovider/registerprovider.dart';
import 'package:bkjs_sales/src/utils/const/color.dart';
import 'package:bkjs_sales/src/utils/spacer/spacer.dart';
import 'package:bkjs_sales/src/widget/button.dart';
import 'package:bkjs_sales/src/widget/textformfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RegistrationProvider(),
      child: Consumer<RegistrationProvider>(
        builder: (context, provider, child) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: backgroundClr,
              appBar: AppBar(
                title: const Text(
                  "Register",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: backgroundClr,
              ),
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
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
                      // Registration ID Field
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Register ID",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      vSpace8,
                      MyTextfomrfiledbox(
                        controller: provider.regNoCTRL,
                        keyboardType: TextInputType.number,
                      ),
                      vSpace18,
                      // Full Name Field
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Full Name",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      vSpace8,
                      MyTextfomrfiledbox(controller: provider.usernameCTRL),
                      vSpace36,
                      // Submit Button
                      Button(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.black,
                        onpressed: () => provider.submit(context),
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
        },
      ),
    );
  }
}
