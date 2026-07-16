import 'package:flutter/material.dart';
import '../sync/sync_task.dart';
import '../sync/sync_status.dart';
import 'inspector_controller.dart';

class InspectorScreen extends StatefulWidget {
  final InspectorController controller;

  const InspectorScreen({super.key, required this.controller});

  @override
  State<InspectorScreen> createState() => _InspectorScreenState();
}

class _InspectorScreenState extends State<InspectorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SyncTask> _queueTasks = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final tasks = await widget.controller.getSyncQueue();
    setState(() {
      _queueTasks = tasks;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.pending:
        return Colors.orange;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.success:
        return Colors.green;
      case SyncStatus.failed:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        title: const Text(
          '🔍 Sync Inspector',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF7C3AED),
          labelColor: const Color(0xFF7C3AED),
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(icon: Icon(Icons.sync), text: 'Sync Queue'),
            Tab(icon: Icon(Icons.wifi), text: 'Network'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSyncQueueTab(),
                _buildNetworkTab(),
              ],
            ),
      bottomNavigationBar: _buildActionBar(),
    );
  }

  Widget _buildSyncQueueTab() {
    if (_queueTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                color: Colors.greenAccent, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Sync queue is empty',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _queueTasks.length,
      itemBuilder: (context, index) {
        final task = _queueTasks[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _methodColor(task.method),
              radius: 20,
              child: Text(
                task.method.substring(0, task.method.length.clamp(0, 3)),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              task.url,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'Retries: ${task.retryCount}  •  ${_formatDate(task.createdAt)}',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
            trailing: Chip(
              label: Text(
                task.status.name.toUpperCase(),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              backgroundColor: _statusColor(task.status),
              padding: EdgeInsets.zero,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNetworkTab() {
    return StreamBuilder<bool>(
      stream: widget.controller.networkStream,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.red.withValues(alpha: 0.15),
                  border: Border.all(
                    color: isOnline ? Colors.greenAccent : Colors.redAccent,
                    width: 3,
                  ),
                ),
                child: Icon(
                  isOnline ? Icons.wifi : Icons.wifi_off,
                  size: 56,
                  color: isOnline ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  color: isOnline ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isOnline
                    ? 'Device is connected to internet'
                    : 'No internet connection detected',
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 32),
              StreamBuilder<SyncStatus>(
                stream: widget.controller.syncStream,
                builder: (context, statusSnapshot) {
                  final status =
                      statusSnapshot.data ?? SyncStatus.pending;
                  return Chip(
                    avatar: Icon(Icons.sync,
                        size: 16, color: _statusColor(status)),
                    label: Text(
                      'Sync: ${status.name.toUpperCase()}',
                      style: TextStyle(
                          color: _statusColor(status), fontSize: 12),
                    ),
                    backgroundColor: _statusColor(status).withValues(alpha: 0.15),
                    side: BorderSide(color: _statusColor(status)),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionBar() {
    return Container(
      color: const Color(0xFF1A1A2E),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                await widget.controller.clearCache();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cache cleared')),
                  );
                }
              },
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              label: const Text('Clear Cache',
                  style: TextStyle(color: Colors.redAccent)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                await widget.controller.forceSync();
                await _loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sync triggered')),
                  );
                }
              },
              icon: const Icon(Icons.sync),
              label: const Text('Force Sync'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _methodColor(String method) {
    switch (method.toUpperCase()) {
      case 'POST':
        return Colors.green.shade700;
      case 'PUT':
        return Colors.blue.shade700;
      case 'PATCH':
        return Colors.orange.shade700;
      case 'DELETE':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
