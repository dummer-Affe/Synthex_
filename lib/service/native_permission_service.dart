import 'package:permission_handler/permission_handler.dart';

class NativePermissionService {
  Future<PermissionStatus> microphoneStatus() {
    return Permission.microphone.status;
  }

  Future<PermissionStatus> requestMicrophonePermission() {
    return Permission.microphone.request();
  }

  Future<bool> openSettings() {
    return openAppSettings();
  }
}
