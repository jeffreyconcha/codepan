import 'package:intl/intl.dart';

extension DoubleUtils on double {
  String toMoneyFormat() {
    final nf = NumberFormat('#,###.00', 'en_US');
    return nf.format(this);
  }

  String format({String? format}) {
    if (format != null) {
      final nf = NumberFormat(format, 'en_US');
      return nf.format(this);
    } else {
      if (this % 1 == 0) {
        return this.toStringAsFixed(0);
      } else {
        return this.toMoneyFormat();
      }
    }
  }
}
