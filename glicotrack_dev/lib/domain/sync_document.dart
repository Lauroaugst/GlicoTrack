import 'models.dart';

class SyncDocument {
  const SyncDocument({
    required this.id,
    required this.uid,
    required this.kind,
    required this.revision,
    required this.updatedAt,
    required this.payload,
    this.baseRevision,
    this.deleted = false,
    this.pending = false,
  });
  final String id;
  final String uid;
  final String kind;
  final String revision;
  final String? baseRevision;
  final int updatedAt;
  final Map<String, dynamic> payload;
  final bool deleted;
  final bool pending;

  void validate(String expectedUid) {
    if (uid != expectedUid ||
        id.isEmpty ||
        id.contains('/') ||
        !RegExp(r'^\d{16}-[a-f0-9-]{36}$').hasMatch(revision) ||
        updatedAt < 0 ||
        !['record', 'settings', 'profile'].contains(kind) ||
        (kind == 'settings' && id != 'settings') ||
        (kind == 'profile' && id != 'profile') ||
        (kind == 'record' && !RegExp(r'^[a-f0-9-]{36}$').hasMatch(id))) {
      throw const FormatException(
        'Documento inválido ou pertencente a outra conta.',
      );
    }
    switch (kind) {
      case 'record':
        HealthRecord.fromJson(id, uid, payload);
      case 'settings':
        GlucoseSettings.fromJson(payload);
      case 'profile':
        PatientProfile.fromJson(payload);
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'uid': uid,
    'kind': kind,
    'revision': revision,
    'baseRevision': baseRevision,
    'updatedAt': updatedAt,
    'payload': payload,
    'deleted': deleted,
  };
  factory SyncDocument.fromJson(Map<String, dynamic> data) => SyncDocument(
    id: data['id'] as String,
    uid: data['uid'] as String,
    kind: data['kind'] as String,
    revision: data['revision'] as String,
    baseRevision: data['baseRevision'] as String?,
    updatedAt: data['updatedAt'] as int,
    payload: Map<String, dynamic>.from(data['payload'] as Map),
    deleted: data['deleted'] as bool,
  );

  SyncDocument copyWith({
    String? revision,
    String? baseRevision,
    int? updatedAt,
    bool? deleted,
    bool? pending,
  }) => SyncDocument(
    id: id,
    uid: uid,
    kind: kind,
    revision: revision ?? this.revision,
    baseRevision: baseRevision ?? this.baseRevision,
    updatedAt: updatedAt ?? this.updatedAt,
    payload: payload,
    deleted: deleted ?? this.deleted,
    pending: pending ?? this.pending,
  );
}

/// Causally newer writes win. Concurrent deletion wins; otherwise revision order
/// (logical microsecond clock + UUID) decides, independently of arrival order.
SyncDocument resolveConflict(SyncDocument local, SyncDocument remote) {
  if (local.uid != remote.uid ||
      local.id != remote.id ||
      local.kind != remote.kind) {
    throw const FormatException('Conflito entre documentos diferentes.');
  }
  if (local.revision == remote.revision) return remote;
  if (local.baseRevision == remote.revision) return local;
  if (remote.baseRevision == local.revision) return remote;
  if (local.deleted != remote.deleted) return local.deleted ? local : remote;
  return local.revision.compareTo(remote.revision) > 0 ? local : remote;
}

bool isConcurrent(SyncDocument a, SyncDocument b) =>
    a.revision != b.revision &&
    a.baseRevision != b.revision &&
    b.baseRevision != a.revision;
