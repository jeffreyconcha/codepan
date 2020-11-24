import 'package:app_settings/app_settings.dart';
import 'package:codepan/resources/strings.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class StateWithPermission<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  List<Permission> get permissions;

  BuildContext _context;

  BuildContext get ctx => _context ?? context;

  void onGranted(
    BuildContext context,
    Permission permission,
  );

  void onDenied(
    BuildContext context,
    Permission permission,
  );

  void onPermanentlyDenied(
    BuildContext context,
    Permission permission,
    String title,
    String message,
  );

  void onBuild(BuildContext context) {
    this._context = context;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
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
        _checkPermissions();
        break;
      default:
        break;
    }
  }

  Future<void> goToSettings() {
    return AppSettings.openAppSettings();
  }

  void _checkPermissions() async {
    for (final permission in permissions) {
      if (!await permission.isGranted) {
        final status = await permission.request();
        if (status.isGranted) {
          onGranted(ctx, permission);
        } else {
          String message;
          if (status.isPermanentlyDenied) {
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
              ctx,
              permission,
              PermissionInfo.title,
              message,
            );
          } else {
            onDenied(ctx, permission);
          }
        }
      }
    }
  }
}
