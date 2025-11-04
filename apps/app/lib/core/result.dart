class PageResult<T> {
  final List<T> data;
  final bool hasMore;
  final int nextPage;
  const PageResult({
    required this.data,
    required this.hasMore,
    required this.nextPage,
  });
}
