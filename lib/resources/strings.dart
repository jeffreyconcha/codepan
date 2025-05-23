class Strings {
  static const String loading = 'Loading...';
  static const String pullDownToRefresh = 'Pull-down to refresh';
  static const String releaseToRefresh = 'Release to refresh';
  static const String completed = 'Completed';
  static const String refreshing = 'Refreshing...';
  static const String noAvailableItems = 'No available items.';
  static const String today = 'Today';
  static const String yesterday = 'Yesterday';
  static const String thisWeek = 'This week';
  static const String thisMonth = 'This month';
  static const String lastWeek = 'Last week';
  static const String lastMonth = 'Last month';
  static const String last7Days = 'Last 7 days';
  static const String last30Days = 'Last 30 days';
  static const String last3Months = 'Last 3 months';
  static const String last6Months = 'Last 6 months';
  static const String thisYear = 'This year';
  static const String fromTheBeginning = 'From the beginning';
  static const String custom = 'Custom';
}

class Errors {
  static const String failedToPlayVideo = 'Please try to play the video again.';
  static const String failedToPlayAudio = 'Please try to play the audio again.';
  static const String failedToRefresh = 'Failed to refresh.';
  static const String unableToConnectToServer =
      'Unable to connect to server. Please check your network connection and try again.';
  static const String requestTimedOut =
      'Your request has timed out. Please check your network connection and try again.';
  static const String somethingWentWrong =
      'Something went wrong. Please try again later.';
}

class PermissionInfo {
  static const String title = 'Permission Request';
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
