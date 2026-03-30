class MusicTrack {
  final String id;
  final String title;
  final String assetPath;
  final String description;
  final String? filePath;
  final bool isUserAdded;

  const MusicTrack({
    required this.id,
    required this.title,
    this.assetPath = '',
    this.description = '',
    this.filePath,
    this.isUserAdded = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'assetPath': assetPath,
      'description': description,
      'filePath': filePath,
      'isUserAdded': isUserAdded,
    };
  }

  factory MusicTrack.fromJson(Map<String, dynamic> json) {
    return MusicTrack(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      assetPath: json['assetPath'] ?? '',
      description: json['description'] ?? '',
      filePath: json['filePath'],
      isUserAdded: json['isUserAdded'] ?? false,
    );
  }

  String get sourcePath => filePath ?? assetPath;
  bool get isLocalFile => filePath != null && filePath!.isNotEmpty;
}
