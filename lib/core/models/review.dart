import 'account.dart';

class Review {
  String id;
  int stars;

  String? description;
  String? auctionId;

  Account? reviewer;
  Account? reviewed;

  DateTime createdAt;
  DateTime? updatedAt;

  Review({
    required this.id,
    required this.stars,
    this.auctionId,
    this.description,
    this.reviewer,
    this.reviewed,
    required this.createdAt,
    this.updatedAt,
  });

  static Review fromJSON(dynamic data) {
    return Review(
      id: data['id'],
      stars: data['stars'],
      auctionId: data['auctionId'] ?? '',
      description: data['description'] ?? '',
      reviewer:
          data['reviewer'] != null ? Account.fromJSON(data['reviewer']) : null,
      reviewed:
          data['reviewed'] != null ? Account.fromJSON(data['reviewed']) : null,
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }
}
