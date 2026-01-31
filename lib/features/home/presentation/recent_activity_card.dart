import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/audit_provider.dart';
import '../../../core/theme/app_colors.dart';

class RecentActivityCard extends StatefulWidget {
  const RecentActivityCard({super.key});

  @override
  State<RecentActivityCard> createState() => _RecentActivityCardState();
}

class _RecentActivityCardState extends State<RecentActivityCard> {
  int _page = 0;
  static const int _itemsPerPage = 3;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AuditProvider>().loadRecentActivity(limit: 50);
    });
  }

  IconData _getIconForAction(String action, String entityType) {
    switch (action) {
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      case 'create':
        return Icons.add_circle_outline;
      case 'update':
        return Icons.edit;
      case 'delete':
        return Icons.delete_outline;
      case 'sync':
        return Icons.sync;
      default:
        return Icons.info_outline;
    }
  }

  Color _getColorForAction(String action) {
    switch (action) {
      case 'login':
        return AppColors.success;
      case 'logout':
        return AppColors.textSecondary;
      case 'create':
        return AppColors.amberAccent;
      case 'update':
        return Colors.blue;
      case 'delete':
        return AppColors.error;
      case 'sync':
        return AppColors.darkBlue;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, HH:mm').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.cardBackground,
      ),
      child: Consumer<AuditProvider>(
        builder: (context, auditProvider, _) {
          final totalItems = auditProvider.recentActivity.length;
          final totalPages = totalItems == 0 ? 1 : ((totalItems - 1) ~/ _itemsPerPage) + 1;
          final currentPage = _page.clamp(0, totalPages - 1);
          final start = currentPage * _itemsPerPage;
          final end = (start + _itemsPerPage) > totalItems ? totalItems : (start + _itemsPerPage);
          final displayItems = totalItems == 0 ? [] : auditProvider.recentActivity.sublist(start, end);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        tooltip: 'Previous',
                        iconSize: 18,
                        onPressed: totalItems > _itemsPerPage && currentPage > 0
                            ? () {
                                setState(() {
                                  _page = currentPage - 1;
                                });
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        tooltip: 'Next',
                        iconSize: 18,
                        onPressed: totalItems > _itemsPerPage && currentPage < totalPages - 1
                            ? () {
                                setState(() {
                                  _page = currentPage + 1;
                                });
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 18),
                        tooltip: 'Refresh',
                        onPressed: () {
                          auditProvider.loadRecentActivity(limit: 50);
                          setState(() {
                            _page = 0;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (auditProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (displayItems.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'No recent activity',
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayItems.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final log = displayItems[index];
                    final icon = _getIconForAction(log.action, log.entityType);
                    final color = _getColorForAction(log.action);
                    final timestamp = _formatTimestamp(log.createdAt);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, size: 16, color: color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  log.details ?? '${log.action} ${log.entityType}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      log.userName,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      ' • $timestamp',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
