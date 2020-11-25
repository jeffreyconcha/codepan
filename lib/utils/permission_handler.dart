import 'package:app_settings/app_settings.dart';
import 'package:codepan/resources/strings.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class StateWithPermission<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  bool _hasPermanentlyDenied = false;
  bool _isGranted = false;

  List<Permission> get permissions;

  void onPermissionResult(bool isGranted);

  void onPermanentlyDenied(
    Permission permission,
    String title,
    String message,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions(request: true);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  @mustCallSuper
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_isGranted) {
          _checkPermissions(request: true);
        } else {
          if (_hasPermanentlyDenied) {
            _checkPermissions(request: false);
          }
        }
        break;
      default:
        break;
    }
  }

  Future<void> goToSettings() {
    return AppSettings.openAppSettings();
  }

  void _checkPermissions({@required bool request}) async {
    _hasPermanentlyDenied = false;
    bool hasDenied = false;
    for (final permission in permissions) {
      final isGranted = request
          ? await permission.request().isGranted
          : await permission.isGranted;
      if (!isGranted) {
        if (await permission.isPermanentlyDenied) {
          String message;
          switch (permission) {
            case Permission.camera:
              message = PermissionInfo.camera;
              break;
            default:
              switch (permission) {
                case Permission.locationAlways:
                  message = PermissionInfo.location;
                  break;
                default:
                  break;
              }
              break;
          }
          onPermanentlyDenied(
            permission,
            PermissionInfo.title,
            message,
          );
          _hasPermanentlyDenied = true;
          break;
        } else {
          hasDenied = true;
        }
      }
    }
    if (!_hasPermanentlyDenied) {
      onPermissionResult(!hasDenied);
    }
  }
}
