import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  bool _popupActivated = false;
  bool get popupActivated => _popupActivated;
  set popupActivated(bool value) {
    _popupActivated = value;
  }

  int _popUp2 = 0;
  int get popUp2 => _popUp2;
  set popUp2(int value) {
    _popUp2 = value;
  }

  int _test = 0;
  int get test => _test;
  set test(int value) {
    _test = value;
  }
}
