enum SearchHistoryItemType { search, account, auction }

class SearchHistoryItem {
  String id;
  String accountId;
  SearchHistoryItemType type;
  String searchKey;
  String? entityId;
  String? data;

  DateTime? createdAt;
  DateTime? updatedAt;

  SearchHistoryItem({
    required this.id,
    required this.accountId,
    required this.type,
    required this.searchKey,
    this.data,
    this.entityId,
    this.createdAt,
    this.updatedAt,
  });

  static SearchHistoryItem fromJSON(dynamic data) {
    var searchType = data['type'] == 'search'
        ? SearchHistoryItemType.search
        : data['type'] == 'auction'
            ? SearchHistoryItemType.auction
            : SearchHistoryItemType.account;

    return SearchHistoryItem(
      id: data['id'],
      accountId: data['accountId'],
      searchKey: data['searchKey'],
      type: searchType,
      data: data['data'],
      entityId: data['entityId'],
      createdAt:
          data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
      updatedAt:
          data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
    );
  }
}
