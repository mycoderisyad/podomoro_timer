class FocusSessionRecord {
  final String displayName;
  final String? customCategoryName;
  final int durationSeconds;
  final DateTime completedAt;

  const FocusSessionRecord({
    required this.displayName,
    required this.durationSeconds,
    required this.completedAt,
    this.customCategoryName,
  });

  int get durationMinutes => durationSeconds ~/ 60;

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'customCategoryName': customCategoryName,
      'durationSeconds': durationSeconds,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory FocusSessionRecord.fromJson(Map<String, dynamic> json) {
    return FocusSessionRecord(
      displayName: json['displayName'] as String? ?? '',
      customCategoryName: json['customCategoryName'] as String?,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      completedAt:
          DateTime.tryParse(json['completedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
