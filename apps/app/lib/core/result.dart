class PageResult<T> {
  final List<T> data;
  final bool hasMore;
  final int nextPage;
  final Map<String, dynamic>? meta;
  final bool fromFallback;

  const PageResult({
    required this.data,
    required this.hasMore,
    required this.nextPage,
    this.meta,
    this.fromFallback = false,
  });

  PageResult<T> copyWith({
    List<T>? data,
    bool? hasMore,
    int? nextPage,
    Map<String, dynamic>? meta,
    bool? fromFallback,
  }) {
    return PageResult(
      data: data ?? this.data,
      hasMore: hasMore ?? this.hasMore,
      nextPage: nextPage ?? this.nextPage,
      meta: meta ?? this.meta,
      fromFallback: fromFallback ?? this.fromFallback,
    );
  }
}
