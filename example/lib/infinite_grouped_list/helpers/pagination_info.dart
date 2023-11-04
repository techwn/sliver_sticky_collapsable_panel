class PaginationInfo {
  final int offset;
  final int page;

  PaginationInfo({required this.offset, required this.page});
}

/// The sort order of the items inside the groups.
enum SortOrder { ascending, descending }
