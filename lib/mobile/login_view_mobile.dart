import 'package:budget_app_starting/view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginViewMobile extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController _emailField = useTextEditingController();
    TextEditingController _passworDField = useTextEditingController();

    final viewModelProvider = ref.watch(viewModel);
    final double deviceHeight = MediaQuery.of(context).size.height;

    return SafeArea(child: Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: deviceHeight/5.5,),
            Image.asset("assets/logo.png", fit: BoxFit.contain, width: 210.0,),
            SizedBox(height: 30.0,),
            SizedBox(
              width: 350.0,
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                controller: _emailField,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                  ),
                  prefixIcon: Icon(Icons.email, color: Colors.black, size: 30.0,),
                  hintText: "Email",
                  hintStyle: GoogleFonts.openSans(),
                ),
              ),
            ),
            SizedBox(height: 20.0,),
            //Password
            SizedBox(
              width: 350.0,
              child: TextFormField(
                textAlign: TextAlign.center,
                controller: _passworDField,
                obscureText: viewModelProvider.isObscure,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                  ),
                  prefixIcon: IconButton(
                    icon: Icon(viewModelProvider.isObscure ? Icons.visibility : Icons.visibility_off, color: Colors.black, size: 30.0,),
                    onPressed: () {
                      viewModelProvider.toggleObscure();
                    },
                  ),
                  hintText: "Password",
                  hintStyle: GoogleFonts.openSans(),
                ),
              ),
            ),
            SizedBox(height: 30.0,),
            Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50.0, width: 150.0,)
            ],)
          ],
        ),
      ),
    ));

  }
}
