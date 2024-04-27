import 'package:archnet/vpnService/vpn_manager.dart';
import 'package:flutter/cupertino.dart';

class VpnStatusProvider extends ChangeNotifier {
  final VpnManager _vpnManager = VpnManager();

  VpnStatus get vpnStatus => _vpnManager.vpnStatus;

  VpnStatusProvider() {
    _vpnManager.vpnStatusEventChannel.receiveBroadcastStream().listen(
      (event) {
        notifyListeners();
      },
    );
  }
}

class User {
  final String email;
  final String password;

  User({required this.email, required this.password});
}

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}
