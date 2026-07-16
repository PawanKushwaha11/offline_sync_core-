import 'package:flutter/material.dart';
import 'package:offline_sync_core/offline_sync_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('🚀 Initializing offline_sync_core...');

  await OfflineSyncCore.initialize(storage: HiveStorage());

  debugPrint('✅ offline_sync_core initialized');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'offline_sync_core',
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
  String status = 'Loading...';

  bool fromCache = false;

  @override
  void initState() {
    super.initState();

    loadUser();
  }

  Future<void> loadUser() async {
    debugPrint('🌐 Fetching user...');

    final user = await OfflineSyncCore.get<Map>(
      key: 'user_profile',

      ttl: const Duration(seconds: 10),

      fetch: () async {
        debugPrint('📡 API request started');

        await Future.delayed(const Duration(seconds: 2));

        debugPrint('✅ API response received');

        return {'name': 'Amarjeet', 'email': 'amarjeet@example.com'};
      },
    );

    debugPrint('💾 Data loaded successfully');

    setState(() {
      status =
          '''
👤 User Data

Name: ${user?['name']}
Email: ${user?['email']}

------------------------

⚡ Cache TTL: 1 minute

🗄 Storage: Hive

🚧 Offline Sync: Coming Soon

🚧 SQLite Support: Coming Soon

🚧 Queue Manager: Coming Soon

🚧 Inspector: Coming Soon
''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('offline_sync_core Example')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Package Features',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const Card(
              child: ListTile(
                leading: Icon(Icons.storage),
                title: Text('Smart Cache'),
                subtitle: Text('Store API data locally'),
              ),
            ),

            const Card(
              child: ListTile(
                leading: Icon(Icons.timer),
                title: Text('TTL Support'),
                subtitle: Text('Automatic expiration'),
              ),
            ),

            const Card(
              child: ListTile(
                leading: Icon(Icons.save),
                title: Text('Hive Storage'),
                subtitle: Text('Local persistence'),
              ),
            ),

            const Card(
              child: ListTile(
                leading: Icon(Icons.sync),
                title: Text('Offline Sync'),
                subtitle: Text('Coming Soon'),
              ),
            ),

            const SizedBox(height: 24),

            Text(status, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
