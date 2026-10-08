import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(num amount) {
    if (amount <= 0) return 'Unpaid';
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatSalaryRange(num min, num max) {
    if (min <= 0 && max <= 0) {
      return 'Unpaid / Sukarela';
    }
    if (min > 0 && max > 0) {
      return '${formatCurrency(min)} - ${formatCurrency(max)}';
    }
    if (min > 0) {
      return 'Mulai ${formatCurrency(min)}';
    }
    return 'Hingga ${formatCurrency(max)}';
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()} bulan lalu';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} hari lalu';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }
}
