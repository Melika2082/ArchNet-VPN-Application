import 'package:flutter/services.dart';

enum VpnStatus {
  connecting,
  connect,
  disconnect,
}

class VpnManager {
  static const _platform = MethodChannel('flutter_v2ray');
  static const _vpnStatusEventChannel = EventChannel('flutter_v2ray_event');

  VpnStatus _vpnStatus = VpnStatus.disconnect;
  VpnStatus get vpnStatus => _vpnStatus;

  EventChannel get vpnStatusEventChannel => _vpnStatusEventChannel;

  VpnManager() {
    _vpnStatusEventChannel.receiveBroadcastStream().listen(
      (event) {
        switch (event) {
          case 'connecting':
            _vpnStatus = VpnStatus.connecting;
            break;
          case 'connect':
            _vpnStatus = VpnStatus.connect;
            break;
          case 'disconnect':
            _vpnStatus = VpnStatus.disconnect;
            break;
        }
      },
    );
  }

  Future<void> startV2Ray(String config) async {
    await _platform.invokeMethod('start', config);
  }

  Future<void> stopV2Ray() async {
    await _platform.invokeMethod('stop');
  }

  Future<void> getServerPing() async {
    // Implement your method here
  }

  Future<void> disconnect() async {
    // Implement your method here
  }

  Future<void> connect(
      String config, String remark, String port, String domain) async {
    // Implement your method here
  }
}
