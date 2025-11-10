import 'package:budget_app_starting/mobile/expense_view_mobile.dart';
import 'package:budget_app_starting/mobile/login_view_mobile.dart';
import 'package:budget_app_starting/web/expense_view_web.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'view_model.dart';
import 'web/login_view_web.dart';

class ResponsiveHandler extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final _authState = ref.watch(authStateProvider);

    return _authState.when(data: (data) {
      if(data!=null) {
        return LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return ExpenseViewWeb();
        } else
          return ExpenseViewMobile();
      });
      }
      return LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return LoginViewWeb();
        } else
          return LoginViewMobile();
      });
    }, error: (error,trace) {
      return LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return LoginViewWeb();
        } else
          return LoginViewMobile();
      });
    }, loading: ()=>
        LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return LoginViewWeb();
        } else
          return LoginViewMobile();
      })
      );

  }
}
