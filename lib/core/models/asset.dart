class Asset {
  String id;
  String path;
  int size;

  String? fullPath;

  DateTime? createdAt;
  DateTime? updatedAt;

  Asset({
    required this.id,
    required this.path,
    required this.size,
    this.fullPath,
    this.createdAt,
    this.updatedAt,
  });

  static Asset fromJSON(dynamic data) {
    return Asset(
      id: data['id'],
      path: data['path'],
      size: data['size'],
      fullPath: data['fullPath'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'size': size,
      'fullPath': fullPath,
      'createdAt': createdAt?.toString(),
      'updatedAt': updatedAt?.toString(),
    };
  }
}
