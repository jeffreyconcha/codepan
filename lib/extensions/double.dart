import 'package:codepan/extensions/string.dart';
import 'package:intl/intl.dart';

extension DoubleUtils on double {
  String toMoneyFormat() {
    final nf = NumberFormat.simpleCurrency(
      decimalDigits: 2,
      name: '',
    );
    return nf.format(this);
  }

  String toCompact([int decimalDigits = 0]) {
    final nf = NumberFormat.simpleCurrency(
      decimalDigits: decimalDigits,
      name: '',
    );
    final formatted = NumberFormat.compact().format(this);
    final symbol =
        formatted.contains(RegExp(r'[A-Za-z]')) ? formatted.last : '';
    final value = double.parse(formatted.replaceAll(symbol, ''));
    return '${nf.format(value)}$symbol';
  }

  String format({String? format}) {
    if (this % 1 == 0) {
      return this.toStringAsFixed(0);
    } else {
      if (format != null) {
        final nf = NumberFormat(format, 'en_US');
        return nf.format(this);
      } else {
        return this.toMoneyFormat();
      }
    }
  }
}
