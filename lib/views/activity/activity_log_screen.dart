import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/campus_provider.dart';
import '../../theme/app_colors.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final campus = Provider.of<CampusProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Real-Time Activity Audit',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: campus.activityLogs.isEmpty
          ? const Center(child: Text('No activity logged yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: campus.activityLogs.length,
              itemBuilder: (ctx, idx) {
                final item = campus.activityLogs[idx];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF0F0F0)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: _getActionColor(item.actionType).withOpacity(0.15),
                        child: Icon(_getActionIcon(item.actionType), color: _getActionColor(item.actionType), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(
                                  DateFormat('hh:mm a').format(item.timestamp),
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(item.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Color _getActionColor(String action) {
    switch (action.toLowerCase()) {
      case 'add':
      case 'book':
      case 'register':
        return AppColors.primary;
      case 'edit':
        return Colors.orange;
      case 'delete':
      case 'cancel':
        return Colors.red;
      default:
        return AppColors.info;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action.toLowerCase()) {
      case 'add':
        return Icons.add_circle_outline;
      case 'edit':
        return Icons.edit_outlined;
      case 'delete':
        return Icons.delete_outline;
      case 'book':
        return Icons.bookmark_add_outlined;
      case 'register':
        return Icons.how_to_reg_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }
}
