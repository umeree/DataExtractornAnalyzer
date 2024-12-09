import 'package:flutter/cupertino.dart';

class EditTextViewModel with ChangeNotifier {
  bool _readOnly = true;
  bool get readOnly => _readOnly ;

  setReadOnly(bool read) {
    _readOnly = read;
    notifyListeners();
  }
}