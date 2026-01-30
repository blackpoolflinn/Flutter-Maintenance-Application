import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/tasks_provider.dart';
import '../../../core/providers/aircraft_provider.dart';
import '../../../core/providers/sync_provider.dart';

class HeaderDesktop extends StatelessWidget {
  const HeaderDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.dashboard_customize, color: Colors.grey[800]),
            const SizedBox(width: 10),
            Text(
              "Dashboard",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
          ],
        ),
        const SyncStatusAndButton(),
      ],
    );
  }
}

class SyncStatusHeader extends StatelessWidget {
  const SyncStatusHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.dashboard_customize, color: Colors.grey[800]),
            const SizedBox(width: 10),
            Text(
              "Dashboard",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
          ],
        ),
        const SyncStatusAndButton(),
      ],
    );
  }
}

class SyncStatusAndButton extends StatelessWidget {
  const SyncStatusAndButton({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;
    final isSmall = width < 500;

    return Consumer3<TasksProvider, AircraftProvider, SyncProvider>(
      builder: (context, tasksProvider, aircraftProvider, syncProvider, _) {
        final unsyncedTasks = tasksProvider.tasks.where((t) => t.syncedAt == null).length;
        final unsyncedAircraft = aircraftProvider.aircraft.where((a) => a.syncedAt == null).length;
        final unsyncedTotal = unsyncedTasks + unsyncedAircraft;

        Color statusColor;
        String statusText;

        if (syncProvider.lastError != null) {
          statusColor = Colors.red;
          statusText = 'Sync failed';
        } else if (unsyncedTotal > 0) {
          statusColor = Colors.orange;
          statusText = 'Unsynced: $unsyncedTotal';
        } else {
          statusColor = Colors.green;
          statusText = 'All synced';
        }

        if (isSmall) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sync, color: statusColor, size: 12),
                  const SizedBox(width: 4),
                  Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: syncProvider.isSyncing
                      ? null
                      : () async {
                          await syncProvider.syncNow();
                          if (context.mounted) {
                            await context.read<TasksProvider>().loadTasks();
                            await context.read<AircraftProvider>().loadAircraft();
                          }
                        },
                  icon: syncProvider.isSyncing
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        )
                      : const Icon(Icons.cloud_sync, size: 16),
                  label: const Text('Sync', style: TextStyle(fontSize: 11)),
                ),
              ),
            ],
          );
        }

        if (isMobile) {
          return Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sync, color: statusColor, size: 14),
                      const SizedBox(width: 4),
                      Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12)),
                    ],
                  ),
                  if (syncProvider.lastSyncAt != null)
                    Text(
                      'Last sync: ${syncProvider.lastSyncAt!.toLocal().toString().split('.').first}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: syncProvider.isSyncing
                    ? null
                    : () async {
                        await syncProvider.syncNow();
                        if (context.mounted) {
                          await context.read<TasksProvider>().loadTasks();
                          await context.read<AircraftProvider>().loadAircraft();
                        }
                      },
                icon: syncProvider.isSyncing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_sync, size: 18),
                label: const Text('Sync', style: TextStyle(fontSize: 12)),
              ),
            ],
          );
        }

        return Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(Icons.sync, color: statusColor, size: 16),
                    const SizedBox(width: 6),
                    Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
                  ],
                ),
                if (syncProvider.lastSyncAt != null)
                  Text(
                    'Last sync: ${syncProvider.lastSyncAt!.toLocal().toString().split('.').first}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: syncProvider.isSyncing
                  ? null
                  : () async {
                      await syncProvider.syncNow();
                      if (context.mounted) {
                        await context.read<TasksProvider>().loadTasks();
                        await context.read<AircraftProvider>().loadAircraft();
                      }
                    },
              icon: syncProvider.isSyncing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_sync),
              label: const Text('Sync'),
            ),
          ],
        );
      },
    );
  }
}

class MyTasksCard extends StatefulWidget {
  const MyTasksCard({super.key});

  @override
  State<MyTasksCard> createState() => _MyTasksCardState();
}

class _MyTasksCardState extends State<MyTasksCard> {
  int _page = 0;

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.red;
      case 'inProgress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'inProgress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Consumer<TasksProvider>(
        builder: (context, tasksProvider, _) {
          const pageSize = 5;
          // Sort tasks by status priority, then by creation date (newest first)
          final statusPriority = {
            'inProgress': 0,  // Show in-progress tasks first
            'pending': 1,     // Then pending tasks
            'completed': 2,   // Completed tasks last
          };

          final sortedTasks = [...tasksProvider.tasks]
            ..sort((a, b) {
              final aPriority = statusPriority[a.status] ?? 3;
              final bPriority = statusPriority[b.status] ?? 3;
              final byStatus = aPriority.compareTo(bPriority);
              if (byStatus != 0) return byStatus;
              return b.createdAt.compareTo(a.createdAt);
            });

          final totalTasks = sortedTasks.length;
          final totalPages = totalTasks == 0 ? 1 : ((totalTasks - 1) ~/ pageSize) + 1;
          final currentPage = _page.clamp(0, totalPages - 1);
          final start = currentPage * pageSize;
          final end = (start + pageSize) > totalTasks ? totalTasks : (start + pageSize);
          final tasks = totalTasks == 0 ? <dynamic>[] : sortedTasks.sublist(start, end);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Tasks',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        tooltip: 'Previous',
                        onPressed: totalTasks > pageSize && currentPage > 0
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
                        onPressed: totalTasks > pageSize && currentPage < totalPages - 1
                            ? () {
                                setState(() {
                                  _page = currentPage + 1;
                                });
                              }
                            : null,
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 12),
              if (tasks.isEmpty)
                Text(
                  'No tasks available',
                  style: TextStyle(color: Colors.grey[600]),
                )
              else
                Column(
                  children: tasks.map((task) {
                    final isSynced = task.syncedAt != null;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor(task.status),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _statusLabel(task.status),
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              task.title,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSynced ? Colors.green[100] : Colors.orange[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isSynced ? 'Synced' : 'Not synced',
                              style: TextStyle(
                                color: isSynced ? Colors.green[800] : Colors.orange[800],
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          );
        },
      ),
    );
  }
}

class AircraftOverviewCard extends StatefulWidget {
  const AircraftOverviewCard({super.key});

  @override
  State<AircraftOverviewCard> createState() => _AircraftOverviewCardState();
}

class _AircraftOverviewCardState extends State<AircraftOverviewCard> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Consumer2<TasksProvider, AircraftProvider>(
        builder: (context, tasksProvider, aircraftProvider, _) {
          const pageSize = 5;
          
          // Sort aircraft by maintenance status first, then by creation date
          final statusPriority = {
            'maintenance': 0,
            'active': 1,
            'retired': 2,
          };
          
          final aircraftList = [...aircraftProvider.aircraft]
            ..sort((a, b) {
              final aPriority = statusPriority[a.status] ?? 3;
              final bPriority = statusPriority[b.status] ?? 3;
              final byStatus = aPriority.compareTo(bPriority);
              if (byStatus != 0) return byStatus;
              return b.createdAt.compareTo(a.createdAt);
            });
          
          final totalAircraft = aircraftList.length;
          final totalPages = totalAircraft == 0 ? 1 : ((totalAircraft - 1) ~/ pageSize) + 1;
          final currentPage = _page.clamp(0, totalPages - 1);
          final start = currentPage * pageSize;
          final end = (start + pageSize) > totalAircraft ? totalAircraft : (start + pageSize);
          final displayAircraft = totalAircraft == 0 ? <dynamic>[] : aircraftList.sublist(start, end);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Aircraft Overview',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        tooltip: 'Previous',
                        onPressed: totalAircraft > pageSize && currentPage > 0
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
                        onPressed: totalAircraft > pageSize && currentPage < totalPages - 1
                            ? () {
                                setState(() {
                                  _page = currentPage + 1;
                                });
                              }
                            : null,
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 12),
              if (displayAircraft.isEmpty)
                Text(
                  'No aircraft available',
                  style: TextStyle(color: Colors.grey[600]),
                )
              else
                Column(
                  children: displayAircraft.map((aircraft) {
                    final tasksForAircraft = tasksProvider.tasks
                        .where((task) => task.aircraftId == aircraft.id)
                        .toList();
                    final total = tasksForAircraft.length;
                    final completed = tasksForAircraft.where((t) => t.status == 'completed').length;
                    final progress = total == 0 ? 1.0 : completed / total;
                    final openCount = total - completed;
                    final progressLabel = '${(progress * 100).round()}%';
                    final isSynced = aircraft.syncedAt != null;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.flight, color: Colors.grey),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      aircraft.registrationNumber,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      aircraft.model,
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    progressLabel,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isSynced ? 'Synced' : 'Not synced',
                                    style: TextStyle(
                                      color: isSynced ? Colors.green[700] : Colors.orange[700],
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress >= 0.7 ? Colors.green : Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            total == 0
                                ? 'No tasks assigned'
                                : 'Open: $openCount / Total: $total',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          );
        },
      ),
    );
  }
}