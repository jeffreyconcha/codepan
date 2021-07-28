import 'package:intl/intl.dart';

extension DoubleUtils on double {
  String toMoneyFormat() {
    final nf = NumberFormat('#,###.00', 'en_US');
    return nf.format(this);
  }

  String format(String format) {
    final nf = NumberFormat(format, 'en_US');
    return nf.format(this);
  }
}
