import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:codepan/extensions/context.dart';
import 'package:codepan/extensions/string.dart';
import 'package:codepan/resources/strings.dart';
import 'package:codepan/widgets/states/lifecycle_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class PermissionState<T extends StatefulWidget>
    extends LifecycleState<T> {
  bool _isGranted = false;
  bool _hasDialog = false;

  List<Permission> get permissions;

  void onPermissionsGranted();

  /// Return [bool] value of true when prompting a dialog to the user.<br/>
  /// [onDialogDetach] - Callback function to notify the permission
  /// handler that the dialog has been detached.
  bool onShowPermissionDisclosure(
    Permission permission,
    String title,
    String message,
    VoidCallback onDetach,
    VoidCallback onContinue,
  );

  @override
  void initState() {
    super.initState();
    if (permissions.isNotEmpty) {
      _checkPermissions();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  @mustCallSuper
  void onResume() {
    super.onResume();
    if (permissions.isNotEmpty) {
      _checkPermissions();
    }
  }

  Future<void> goToSettings() {
    return AppSettings.openAppSettings();
  }

  void _checkPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      for (final permission in permissions) {
        _isGranted = await permission.isGranted;
        String? name = _getPermissionName(permission.value);
        debugPrint('Permission($name).isGranted: $_isGranted');
        if (!_isGranted) {
          if (!_hasDialog) {
            _hasDialog = onShowPermissionDisclosure(
              permission,
              PermissionInfo.title,
              PermissionInfo.message.complete('\"$name\"'),
              () => _hasDialog = false,
              () async {
                if (await permission.shouldShowRequestRationale) {
                  goToSettings();
                } else {
                  final status = await permission.request();
                  _isGranted = status.isGranted;
                  if (!_isGranted && status.isPermanentlyDenied) {
                    goToSettings();
                  }
                }
              },
            );
          }
          break;
        }
      }
      if (_isGranted) {
        if (_hasDialog) {
          _hasDialog = false;
          context.pop();
        }
        onPermissionsGranted();
      }
    } else {
      onPermissionsGranted();
      _isGranted = true;
    }
  }

  String? _getPermissionName(int value) {
    String? name;
    switch (value) {
      case PermissionValue.camera:
        name = PermissionName.camera;
        break;
      case PermissionValue.storage:
        name = PermissionName.storage;
        break;
      case PermissionValue.calendar:
        name = PermissionName.calendar;
        break;
      case PermissionValue.contacts:
        name = PermissionName.contacts;
        break;
      case PermissionValue.mediaLibrary:
        name = PermissionName.mediaLibrary;
        break;
      case PermissionValue.microphone:
        name = PermissionName.microphone;
        break;
      case PermissionValue.photos:
        name = PermissionName.photos;
        break;
      case PermissionValue.reminders:
        name = PermissionName.reminders;
        break;
      case PermissionValue.sensors:
        name = PermissionName.sensors;
        break;
      case PermissionValue.sms:
        name = PermissionName.sms;
        break;
      case PermissionValue.speech:
        name = PermissionName.speech;
        break;
      case PermissionValue.notification:
        name = PermissionName.notification;
        break;
      default:
        switch (value) {
          case PermissionValue.locationAlways:
            name = PermissionName.locationAlways;
            break;
          case PermissionValue.locationWhenInUse:
            name = PermissionName.locationWhenInUse;
            break;
          case PermissionValue.location:
            name = PermissionName.location;
            break;
          case PermissionValue.phone:
            name = PermissionName.phone;
            break;
          default:
            break;
        }
        break;
    }
    return name;
  }
}
