class Errors {
  static const String failedToPlayVideo = 'Failed to play video.';
  static const String failedToPlayAudio = 'Failed to play audio';
}

class PermissionInfo {
  static const String title = 'Permission Denied';
  static const String message =
      'Please allow this app to access the \$type. Go to settings and enable the required permission.';
}

class PermissionName {
  static const String camera = 'Camera';
  static const String location = 'Location';
  static const String locationAlways = 'Location Always';
  static const String locationWhenInUse = 'Location When in Use';
  static const String storage = 'Storage';
  static const String calendar = 'Calendar';
  static const String contacts = 'Contacts';
  static const String mediaLibrary = 'Media Library';
  static const String microphone = 'Microphone';
  static const String phone = 'Phone';
  static const String photos = 'Photos';
  static const String reminders = 'Reminders';
  static const String sensors = 'Sensors';
  static const String sms = 'SMS';
  static const String speech = 'Speech';
  static const String notification = 'Notification';
}

class PermissionValue {
  static const int calendar = 0;
  static const int camera = 1;
  static const int contacts = 2;
  static const int location = 3;
  static const int locationAlways = 4;
  static const int locationWhenInUse = 5;
  static const int mediaLibrary = 6;
  static const int microphone = 7;
  static const int phone = 8;
  static const int photos = 9;
  static const int photosAddOnly = 10;
  static const int reminders = 11;
  static const int sensors = 12;
  static const int sms = 13;
  static const int speech = 14;
  static const int storage = 15;
  static const int ignoreBatteryOptimizations = 16;
  static const int notification = 17;
  static const int accessMediaLocation = 18;
  static const int activityRecognition = 19;
  static const int unknown = 20;
  static const int bluetooth = 21;
  static const int manageExternalStorage = 22;
}

class Exceptions {
  static const invalidArgument = 'Invalid argument';
}
