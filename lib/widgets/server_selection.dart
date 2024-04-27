import 'package:flutter/material.dart';

class ServerSelection extends ChangeNotifier {
  int? _selectedItem;
  String? _selectedServerType;

  int? get selectedItem => _selectedItem;
  String? get selectedServerType => _selectedServerType;

  void selectServer(int index, String type) {
    _selectedItem = index;
    _selectedServerType = type;
    notifyListeners();
  }
}
