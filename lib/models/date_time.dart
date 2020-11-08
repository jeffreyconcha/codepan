class DateTimeData {
  final String date;
  final String time;

  const DateTimeData({
    this.date,
    this.time,
  });

  Map<String, String> toMap() {
    return {
      'date': date,
      'time': time,
    };
  }
}
