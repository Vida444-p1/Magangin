import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'submitted':
        bg = const Color(0xFFFEF9C3);
        fg = const Color(0xFF854D0E);
        label = 'Terkirim';
        icon = Icons.schedule;
        break;
      case 'reviewing':
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1E40AF);
        label = 'Reviewing';
        icon = Icons.visibility;
        break;
      case 'interview':
        bg = const Color(0xFFEDE9FE);
        fg = const Color(0xFF6B21A8);
        label = 'Interview';
        icon = Icons.event_available;
        break;
      case 'accepted':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF166534);
        label = 'Diterima';
        icon = Icons.check_circle;
        break;
      case 'rejected':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        label = 'Ditolak';
        icon = Icons.cancel;
        break;
      case 'withdrawn':
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        label = 'Dibatalkan';
        icon = Icons.undo;
        break;
      case 'published':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF166534);
        label = 'Aktif';
        icon = Icons.check_circle_outline;
        break;
      case 'draft':
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        label = 'Draft';
        icon = Icons.edit_note;
        break;
      case 'closed':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        label = 'Ditutup';
        icon = Icons.lock_outline;
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = AppConstants.secondaryColor;
        label = status;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
