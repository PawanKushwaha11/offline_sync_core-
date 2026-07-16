import 'package:flutter/material.dart';
import 'package:offline_sync_core/offline_sync_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline_sync_core with Hive and logging enabled
  await OfflineSyncCore.initialize(
    storage: HiveStorage(),
    config: const OfflineSyncConfig(
      enableLogging: true,
      maxRetries: 3,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'offline_sync_core',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        colorScheme: const ColorScheme.dark().copyWith(
          primary: const Color(0xFF7C3AED),
          secondary: const Color(0xFF10B981),
          surface: const Color(0xFF1A1A2E),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  String _cacheStatus = 'No data loaded';
  bool _isLoading = false;
  bool _fromCache = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Showcase Smart Caching & TTL
  Future<void> _loadUser() async {
    setState(() => _isLoading = true);

    try {
      final start = DateTime.now();
      final user = await OfflineSyncCore.get<Map>(
        key: 'user_profile',
        ttl: const Duration(seconds: 15),
        fetch: () async {
          await Future.delayed(const Duration(seconds: 2));
          return {
            'name': 'Pawan Kushwaha',
            'email': 'pawan@example.com',
            'role': 'Flutter Developer',
            'fetchedAt': DateTime.now().toIso8601String(),
          };
        },
      );
      final elapsed = DateTime.now().difference(start).inMilliseconds;

      setState(() {
        _fromCache = elapsed < 500;
        if (user != null) {
          _cacheStatus = '👤 Name: ${user['name']}\n'
              '📧 Email: ${user['email']}\n'
              '💼 Role: ${user['role']}\n'
              '🕒 Loaded At: ${user['fetchedAt'].toString().substring(11, 19)}';
        } else {
          _cacheStatus = 'No profile data found';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _cacheStatus = 'Error loading data: $e';
        _isLoading = false;
      });
    }
  }

  // Showcase Offline Sync & Immediate Local Cache Update
  Future<void> _updateProfileOffline() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please enter a new profile name!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 1. Manually update the local cache immediately (Optimistic Cache Update)
    final updatedProfile = {
      'name': newName,
      'email': '${newName.toLowerCase().replaceAll(' ', '')}@example.com',
      'role': 'Flutter Developer (Updated)',
      'fetchedAt': DateTime.now().toIso8601String(),
    };

    await OfflineSyncCore.put(
      key: 'user_profile',
      data: updatedProfile,
      ttl: const Duration(seconds: 15),
    );

    // 2. Queue the mutation task to sync with server in background
    final task = SyncTask(
      url: 'https://jsonplaceholder.typicode.com/users/1',
      method: 'PUT',
      body: updatedProfile,
    );
    await OfflineSyncCore.enqueue(task);

    // 3. Immediately refresh UI with new local cache (instant update, no 2s delay)
    await _loadUser();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📝 Local cache updated to "$newName" & Sync Task queued!'),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    
    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          '⚡ Offline Sync Core',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report, color: Color(0xFF7C3AED)),
            onPressed: () {
              // Open Visual Inspector Screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InspectorScreen(
                    controller: InspectorController(
                      storage: HiveStorage(),
                      syncManager: OfflineSyncCore.syncManager,
                    ),
                  ),
                ),
              );
            },
            tooltip: 'Open Inspector',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Smart Cache Card
            Card(
              color: const Color(0xFF1A1A2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: Colors.white10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            '🗄️ Smart Cache (TTL: 15s)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF7C3AED),
                            ),
                          )
                        else if (_cacheStatus != 'No data loaded')
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: Chip(
                              key: ValueKey(_fromCache),
                              avatar: Icon(
                                _fromCache
                                    ? Icons.flash_on
                                    : Icons.cloud_download,
                                size: 14,
                                color: _fromCache
                                    ? Colors.amber
                                    : Colors.blueAccent,
                              ),
                              label: Text(
                                _fromCache ? '⚡ CACHE' : '🌐 NETWORK',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _fromCache
                                      ? Colors.amber
                                      : Colors.blueAccent,
                                ),
                              ),
                              backgroundColor: _fromCache
                                  ? Colors.amber.withValues(alpha: 0.12)
                                  : Colors.blueAccent.withValues(alpha: 0.12),
                              side: BorderSide(
                                color: _fromCache
                                    ? Colors.amber
                                    : Colors.blueAccent,
                              ),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _cacheStatus,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _loadUser,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Fetch / Refresh Cache'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Queue Operations Card
            Card(
              color: const Color(0xFF1A1A2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: Colors.white10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📤 Update Profile Offline & Sync',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Type a name, turn off the internet, and save. The local UI updates instantly while the sync is queued.',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Enter New Profile Name (e.g. Shivam)',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF10B981)),
                        ),
                        labelStyle: TextStyle(color: Colors.white54),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: _updateProfileOffline,
                      icon: const Icon(Icons.sync_alt),
                      label: const Text('Update Profile & Queue Sync'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Visual Debugger Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InspectorScreen(
                      controller: InspectorController(
                        storage: HiveStorage(),
                        syncManager: OfflineSyncCore.syncManager,
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.troubleshoot),
              label: const Text('Open Visual Sync Inspector'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E1B4B),
                foregroundColor: const Color(0xFFC084FC),
                side: const BorderSide(color: Color(0xFF6B21A8)),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
