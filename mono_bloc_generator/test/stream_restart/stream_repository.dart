class StreamRepository {
  Stream<String> fetchItems(String prefix) {
    return Stream.periodic(
      const Duration(seconds: 1),
      (count) => '$prefix-$count',
    ).take(4);
  }
}
