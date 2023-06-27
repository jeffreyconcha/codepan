abstract class InitHandler {
  final bool allowEmpty;

  const InitHandler(this.allowEmpty);

  List<Map<String, dynamic>> init(
    Map<String, dynamic> body,
  );
}
