// ignore_for_file: constant_identifier_names

enum NotificationType {
  NEW_BID_ON_AUCTION,
  AUCTION_UPDATED,
  BID_REMOVED_ON_AUCTION,
  BID_ACCEPTED_ON_AUCTION,
  BID_REJECTED_ON_AUCTION,
  REVIEW_RECEIVED,
  NEW_MESSAGE,
  SYSTEM,
  SOMEONE_ELSE_ADDED_BID_TO_SAME_AUCTION,
  BID_WAS_SEEN,
  NEW_FOLLOWER,
  AUCTION_FROM_FAVOURITES_HAS_BID,
  NEW_AUCTION_FROM_FOLLOWING,
  AUCTION_ADDED_TO_FAVOURITES,
  FAVOURITE_AUCTION_PRICE_CHANGE,
  MY_AUCTION_STARTED,
  AUCTION_FROM_FAVOURITES_STARTED,
}

class mazadiNotification {
  String id;
  Map<String, String> description;
  Map<String, String> title;
  String entityId;
  bool read;
  NotificationType type;

  DateTime? createdAt;
  DateTime? updatedAt;

  mazadiNotification({
    required this.id,
    required this.description,
    required this.entityId,
    required this.title,
    required this.type,
    this.read = false,
    this.createdAt,
    this.updatedAt,
  });

  static mazadiNotification fromJSON(dynamic data) {
    return mazadiNotification(
      id: data['id'],
      description: data['description'] != null
          ? Map<String, String>.from(data['description'])
          : {},
      entityId: data['entityId'] ?? '',
      title:
          data['title'] != null ? Map<String, String>.from(data['title']) : {},
      read: data['read'],
      type: NotificationType.values.firstWhere((element) =>
          element.toString() == 'NotificationType.${data['type']}'),
      createdAt:
          data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
      updatedAt:
          data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
    );
  }
}
