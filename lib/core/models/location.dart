class Location {
  String id;
  String name;
  int? auctionsCount;

  Location({
    required this.id,
    required this.name,
    this.auctionsCount,
  });

  static Location fromJSON(dynamic data) {
    return Location(
      id: data["id"],
      name: data["name"],
      auctionsCount: data['auctionsCount'] != null
          ? int.parse(data['auctionsCount'].toString())
          : 0,
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'name': name,
      'auctionsCount': auctionsCount,
    };
  }
}
