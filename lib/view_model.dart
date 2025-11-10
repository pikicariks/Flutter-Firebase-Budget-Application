import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import 'components.dart';

final viewModel =
    ChangeNotifierProvider.autoDispose<ViewModel>((ref) => ViewModel());

class ViewModel extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  bool isSignedIn = false;
  bool isObscure = true;
  var logger = Logger();
  final GoogleSignIn _google = GoogleSignIn.instance; // v 7+ singleton
  List expensesName = [];
  List expensesAmount = [];
  List incomesName = [];
  List incomesAmount = [];

  //Check if Signed In
  Future<void> isLoggedIn() async {
    await _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        isSignedIn = false;
      } else {
        isSignedIn = true;
      }
    });
    notifyListeners();
  }

  toggleObscure() {
    isObscure = !isObscure;
    notifyListeners();
  }

  Future<void> signInWithGoogleWeb(BuildContext context) async {
    final googleProvider = GoogleAuthProvider();

    await _auth.signInWithPopup(googleProvider).
      then((_) => logger.d("Current user UID present? " '${_auth.currentUser?.uid.isNotEmpty ?? false}',))
      .onError((error,stackTrace) {
        logger.d(error);
        return DialogBox(context, error.toString().replaceAll(RegExp(r'\[.*?\]'), ''));
      });
  }

  Future<void> signInWithGoogleMobile(BuildContext context) async {
    final GoogleSignInAccount account = await _google
        .authenticate(scopeHint: const ['email'])
        .onError((error, stackTrace) {
      logger.d(error);
      DialogBox(
        context,
        error.toString().replaceAll(RegExp(r'\[.*?\]'), ''),
      );
      throw error!;
    });

    // authentication is now synchronous and returns only idToken
    final String? idToken = account.authentication.idToken;

    final credential = GoogleAuthProvider.credential(idToken: idToken);

    await _auth
        .signInWithCredential(credential)
        .then(
          (value) => logger.e('Signed in successfully $value'),
    )
        .onError((error, stackTrace) {
      DialogBox(context, error.toString().replaceAll(RegExp(r'\[.*?\]'), ''));
      logger.d(error);
    });
  }

  //Authewntication
  Future<void> createUserWithEmailAndPassword(
    BuildContext context, String email, String password
  ) async {

    await _auth.createUserWithEmailAndPassword(email: email, password: password).then((value) => logger.d("Reg successful")).onError((error,stackTrace) {
      logger.d("Registration error $error");
      DialogBox(context, error.toString().replaceAll(RegExp('\\[.*?\\]'), ''));
    });

    return;
  }

  Future<void> signInWithEmailPass(
    BuildContext context, String email, String password
  ) async {

    await _auth.signInWithEmailAndPassword(email: email, password: password).then((value) => logger.d("Login successful")).onError((error,stackTrace) {
      logger.d("Login error $error");
      DialogBox(context, error.toString().replaceAll(RegExp('\\[.*?\\]'), ''));
    });

    return;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  //db

  Future<void> addExpense(BuildContext context) async{
    final formKey = GlobalKey<FormState>();

    TextEditingController controllerName = TextEditingController();
    TextEditingController controllerAmount = TextEditingController();

    return await showDialog(context: context, builder: (BuildContext context) => AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      contentPadding: EdgeInsets.all(32.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Form(
        key: formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextForm(text: "Name", containerWidth: 130.0, hintText: "Name", controller: controllerName, validator: (text) {
              if(text.toString().isEmpty) {
                return "Required";
              }
            }),
            SizedBox(width: 10.0,),
            TextForm(text: "Amount", containerWidth: 100.0, hintText: "Amount", controller: controllerAmount, validator: (text) {
              if(text.toString().isEmpty) {
                return "Required";
              }
            }),
            SizedBox(width: 10.0,),
          ],
        ),
      ),
      actions: [
        MaterialButton(
          child: OpenSans(text: "Save", size: 15.0, color: Colors.white,),
          splashColor: Colors.grey,
          color: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              await userCollection.doc(_auth.currentUser!.uid).collection('expenses')
              .add({
                "name":controllerName.text,
                "amount":controllerAmount.text
              }).onError((error,stackTrace) {
                logger.d("add expense error = $error");
                return DialogBox(context, error.toString());
              });
              Navigator.pop(context);
            }
          },
        )
      ],
    ));
  }


  Future<void> addIncome(BuildContext context) async{
    final formKey = GlobalKey<FormState>();

    TextEditingController controllerName = TextEditingController();
    TextEditingController controllerAmount = TextEditingController();

    return await showDialog(context: context, builder: (BuildContext context) => AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      contentPadding: EdgeInsets.all(32.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(width: 1.0, color: Colors.black)
      ),
      title: Form(
        key: formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextForm(text: "Name", containerWidth: 130.0, hintText: "Name", controller: controllerName, validator: (text) {
              if(text.toString().isEmpty) {
                return "Required";
              }
            }),
            SizedBox(width: 10.0,),
            TextForm(text: "Amount", containerWidth: 100.0, hintText: "Amount", digitsOnly: true, controller: controllerAmount, validator: (text) {
              if(text.toString().isEmpty) {
                return "Required";
              }
            }),
            SizedBox(width: 10.0,),
          ],
        ),
      ),
      actions: [
        MaterialButton(
          child: OpenSans(text: "Save", size: 15.0, color: Colors.white,),
          splashColor: Colors.grey,
          color: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              await userCollection.doc(_auth.currentUser!.uid).collection('incomes')
              .add({
                "name":controllerName.text,
                "amount":controllerAmount.text
              }).then((val) {
                logger.d("Income added");
              }).onError((error,stackTrace) {
                logger.d("add income error = $error");
                return DialogBox(context, error.toString());
              });
              Navigator.pop(context);
            }
          },
        )
      ],
    ));
  }

    void expensesStream() async{
      await for(var snapshot in userCollection.doc(_auth.currentUser!.uid).collection("expenses").snapshots()){

        expensesAmount = [];
        expensesName = [];

        for (var expense in snapshot.docs) {
          expensesName.add(expense.data()['name']);
          expensesAmount.add(expense.data()['amount']);
          notifyListeners();
        }
      }
  }

      void incomesStream() async{
      await for(var snapshot in userCollection.doc(_auth.currentUser!.uid).collection("incomes").snapshots()){

        incomesAmount = [];
        incomesName = [];

        for (var income in snapshot.docs) {
          incomesName.add(income.data()['name']);
          incomesAmount.add(income.data()['amount']);
          notifyListeners();
        }
      }
  }

  Future<void> reset() async {
    await userCollection.doc(_auth.currentUser!.uid).collection("expenses") .get()
      .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });

          await userCollection.doc(_auth.currentUser!.uid).collection("incomes") .get()
      .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });
  }
} 
