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

  String format([
    int decimalDigits = 2,
    bool alwaysWithDecimal = false,
  ]) {
    if (this % 1 == 0 && !alwaysWithDecimal) {
      final nf = NumberFormat("#,###", 'en_US');
      return nf.format(this);
    } else {
      final nf = NumberFormat.simpleCurrency(
        decimalDigits: decimalDigits,
        name: '',
      );
      return nf.format(this);
    }
  }
}
