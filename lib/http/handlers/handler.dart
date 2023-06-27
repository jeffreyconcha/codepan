abstract class InitHandler {
  final bool allowEmpty;

  const InitHandler([
    this.allowEmpty = true,
  ]);

  List<Map<String, dynamic>> init(
    Map<String, dynamic> body,
  );
}
