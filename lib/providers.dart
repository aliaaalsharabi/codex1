import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/modelview/user_vm.dart';
import 'package:codex_firebase/modelview/product_vm.dart';
import 'package:codex_firebase/modelview/adv_job_vm.dart';
import 'package:codex_firebase/modelview/comments_vm.dart';
import 'package:codex_firebase/modelview/software_vm.dart';
import 'package:codex_firebase/modelview/premission_vm.dart';
import 'package:codex_firebase/modelview/DB_AI_vm.dart';
import 'package:codex_firebase/modelview/Report_vm.dart';
import 'package:codex_firebase/modelview/reserve.dart';
import 'package:codex_firebase/modelview/search_vm.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';

class AppProviders {
  static List<ChangeNotifierProvider> get providers => [
    ChangeNotifierProvider<Theme_Vm>(create: (_) => Theme_Vm()),
    ChangeNotifierProvider<User_Vm>(create: (_) => User_Vm()),
    ChangeNotifierProvider<Prodect_Vm>(create: (_) => Prodect_Vm()),
    ChangeNotifierProvider<Advertisement_of_jop_Vm>(create: (_) => Advertisement_of_jop_Vm()),
    ChangeNotifierProvider<Comments_Vm>(create: (_) => Comments_Vm()),
    ChangeNotifierProvider<Software_Vm>(create: (_) => Software_Vm()),
    ChangeNotifierProvider<Permission_Vm>(create: (_) => Permission_Vm()),
    ChangeNotifierProvider<DB_AI_Vm>(create: (_) => DB_AI_Vm()),
    ChangeNotifierProvider<Report_Vm>(create: (_) => Report_Vm()),
    ChangeNotifierProvider<Reserve_Vm>(create: (_) => Reserve_Vm()),
    ChangeNotifierProvider<Search_vm>(create: (_) => Search_vm()),
  ];
}