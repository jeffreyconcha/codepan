import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:codepan/extensions/context.dart';
import 'package:codepan/extensions/string.dart';
import 'package:codepan/resources/strings.dart';
import 'package:codepan/utils/lifecycle_handler.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class StateWithPermission<T extends StatefulWidget>
    extends StateWithLifecycle<T> {
  bool _isPermanentlyDenied = false;
  bool _isGranted = false;
  bool _hasDialog = false;

  List<Permission> get permissions;

  void onPermissionResult(bool isGranted);

  /// Return [bool] value of true when prompting using a dialog <br/>
  /// [onDialogDetach] - Callback function to notify the permission
  /// handler that the dialog has been detached.
  bool onPermanentlyDenied(
    Permission permission,
    String title,
    String message,
    VoidCallback onDialogDetach,
  );

  @override
  void initState() {
    super.initState();
    _checkPermissions(request: true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  @mustCallSuper
  void onResume() {
    super.onResume();
    if (_isGranted) {
      _checkPermissions(request: true);
    } else {
      if (_isPermanentlyDenied) {
        _checkPermissions(request: false);
      }
    }
  }

  @override
  @mustCallSuper
  void onInactive() {
    super.onInactive();
    if (_hasDialog && _isPermanentlyDenied) {
      context.pop();
    }
  }

  Future<void> goToSettings() {
    return AppSettings.openAppSettings();
  }

  void _checkPermissions({@required bool request}) async {
    _isPermanentlyDenied = false;
    bool hasDenied = false;
    for (final permission in permissions) {
      _isGranted = request
          ? await permission.request().isGranted
          : await permission.isGranted;
      debugPrint('Permission(${permission.value}) isGranted: $_isGranted');
      if (!_isGranted) {
        if (await permission.isPermanentlyDenied || Platform.isIOS) {
          String name;
          switch (permission) {
            case Permission.camera:
              name = PermissionName.camera;
              break;
            case Permission.storage:
              name = PermissionName.storage;
              break;
            case Permission.calendar:
              name = PermissionName.calendar;
              break;
            case Permission.contacts:
              name = PermissionName.contacts;
              break;
            case Permission.mediaLibrary:
              name = PermissionName.mediaLibrary;
              break;
            case Permission.microphone:
              name = PermissionName.microphone;
              break;
            case Permission.photos:
              name = PermissionName.photos;
              break;
            case Permission.reminders:
              name = PermissionName.reminders;
              break;
            case Permission.sensors:
              name = PermissionName.sensors;
              break;
            case Permission.sms:
              name = PermissionName.sms;
              break;
            case Permission.speech:
              name = PermissionName.speech;
              break;
            case Permission.notification:
              name = PermissionName.notification;
              break;
            default:
              switch (permission) {
                case Permission.locationAlways:
                  name = PermissionName.locationAlways;
                  break;
                case Permission.locationWhenInUse:
                  name = PermissionName.locationWhenInUse;
                  break;
                case Permission.location:
                  name = PermissionName.location;
                  break;
                case Permission.phone:
                  name = PermissionName.phone;
                  break;
                default:
                  break;
              }
              break;
          }
          _hasDialog = onPermanentlyDenied(
            permission,
            PermissionInfo.title,
            PermissionInfo.message.complete('\"$name\"'),
            () => _hasDialog = false,
          );
          _isPermanentlyDenied = true;
          break;
        } else {
          hasDenied = true;
        }
      }
    }
    if (!_isPermanentlyDenied) {
      onPermissionResult(!hasDenied);
    }
  }
}
