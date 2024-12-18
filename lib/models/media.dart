enum MediaType {
  dvd("DVD"),
  bluray("Blu-ray"),
  digital("Digital"),
  ;

  @override
  String toString() => displayName;

  final String displayName;

  const MediaType(this.displayName);

  static MediaType from(String displayName) {
    return MediaType.values.firstWhere(
      (type) => type.displayName == displayName,
      orElse: () => throw ArgumentError('Invalid MediaType: $displayName'),
    );
  }
}

class Media {
  final int id;
  final MediaType type;
  final String title;
  final DateTime releasedAt;
  final DateTime addedAt;

  const Media({
    required this.id,
    required this.type,
    required this.title,
    required this.releasedAt,
    required this.addedAt,
  });

  // DB投入用にtoMapを追加
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'type': type.toString(),
      'title': title,
      'released_at': releasedAt.toUtc().toIso8601String(),
      'added_at': addedAt.toUtc().toIso8601String(),
    };
  }

  // 情報確認用にtoStringも実装
  @override
  String toString() {
    return 'Media{id: $id, type: $type, title: $title, releasedAt: $releasedAt, addedAt: $addedAt}';
  }
}
