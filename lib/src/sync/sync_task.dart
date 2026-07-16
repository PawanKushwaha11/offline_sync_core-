import 'package:uuid/uuid.dart';
import 'sync_status.dart';

class SyncTask {
  final String id;
  final String url;
  final String method;
  final Map<String, String> headers;
  final Map<String, dynamic>? body;
  final int retryCount;
  final DateTime createdAt;
  final SyncStatus status;

  SyncTask({
    String? id,
    required this.url,
    required this.method,
    this.headers = const {},
    this.body,
    this.retryCount = 0,
    DateTime? createdAt,
    this.status = SyncStatus.pending,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'method': method,
        'headers': headers,
        'body': body,
        'retryCount': retryCount,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
      };

  factory SyncTask.fromJson(Map<String, dynamic> json) => SyncTask(
        id: json['id'] as String,
        url: json['url'] as String,
        method: json['method'] as String,
        headers: Map<String, String>.from(json['headers'] as Map),
        body: json['body'] != null
            ? Map<String, dynamic>.from(json['body'] as Map)
            : null,
        retryCount: json['retryCount'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        status: SyncStatus.values.byName(json['status'] as String),
      );

  SyncTask copyWith({
    String? url,
    String? method,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    int? retryCount,
    SyncStatus? status,
  }) =>
      SyncTask(
        id: id,
        url: url ?? this.url,
        method: method ?? this.method,
        headers: headers ?? this.headers,
        body: body ?? this.body,
        retryCount: retryCount ?? this.retryCount,
        createdAt: createdAt,
        status: status ?? this.status,
      );
}
