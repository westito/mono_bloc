import 'item_model.dart';

class ItemDataStore {
  ItemDataStore() {
    _initializeSampleData();
  }

  final Map<ItemSource, List<Item>> _storage = {
    ItemSource.source1: [],
    ItemSource.source2: [],
    ItemSource.source3: [],
    ItemSource.source4: [],
  };

  var _nextId = 100;

  List<Item> getItems(ItemSource source) {
    return List.unmodifiable(_storage[source] ?? []);
  }

  List<Item> getAllItems() {
    final allItems = <Item>[];
    for (final source in ItemSource.values) {
      final items = _storage[source]!.map((item) {
        return item.copyWith(source: source.displayName);
      }).toList();
      allItems.addAll(items);
    }
    return allItems;
  }

  Item addItem(ItemSource source, Item item) {
    final newItem = item.copyWith(
      id: item.id.isEmpty ? 'item_${source.name}_${_nextId++}' : item.id,
      source: source.displayName,
    );

    _storage[source] = [..._storage[source]!, newItem];
    return newItem;
  }

  Item updateItem(ItemSource source, Item item) {
    final items = _storage[source]!;
    final index = items.indexWhere((t) => t.id == item.id);

    if (index == -1) {
      throw Exception('Item not found in ${source.displayName}');
    }

    final updated = List<Item>.from(items);
    updated[index] = item;
    _storage[source] = updated;

    return item;
  }

  void deleteItem(ItemSource source, String itemId) {
    _storage[source] = _storage[source]!.where((t) => t.id != itemId).toList();
  }

  List<Item> searchInSource(ItemSource source, String query) {
    final items = _storage[source] ?? [];
    return items.where((item) {
      final titleMatch = item.title.toLowerCase().contains(query.toLowerCase());
      final descMatch =
          item.description?.toLowerCase().contains(query.toLowerCase()) ??
          false;
      final tagMatch = item.tags.any(
        (tag) => tag.toLowerCase().contains(query.toLowerCase()),
      );
      return titleMatch || descMatch || tagMatch;
    }).toList();
  }

  Map<ItemSource, int> getItemCountsBySource() {
    return _storage.map((key, value) => MapEntry(key, value.length));
  }

  void clearAll() {
    for (final source in ItemSource.values) {
      _storage[source] = [];
    }
  }

  void _initializeSampleData() {
    _storage[ItemSource.source1] = [
      const Item(id: 'item_1', title: 'Item One', tags: ['tag1', 'tag2']),
      const Item(
        id: 'item_2',
        title: 'Item Two',
        priority: ItemPriority.high,
        tags: ['tag3'],
      ),
      const Item(
        id: 'item_3',
        title: 'Item Three',
        description: 'Description',
        tags: ['tag4'],
      ),
    ];

    _storage[ItemSource.source2] = [
      const Item(
        id: 'item_4',
        title: 'Item Four',
        priority: ItemPriority.urgent,
        tags: ['tag5'],
      ),
      const Item(
        id: 'item_5',
        title: 'Item Five',
        priority: ItemPriority.high,
        tags: ['tag6'],
        completed: true,
      ),
      const Item(
        id: 'item_6',
        title: 'Item Six',
        description: 'Description',
        priority: ItemPriority.high,
        tags: ['tag7'],
      ),
      const Item(
        id: 'item_7',
        title: 'Item Seven',
        priority: ItemPriority.low,
        tags: ['tag8'],
      ),
    ];

    _storage[ItemSource.source3] = [
      const Item(
        id: 'item_8',
        title: 'Item Eight',
        priority: ItemPriority.low,
        tags: ['tag9'],
      ),
      const Item(id: 'item_9', title: 'Item Nine', tags: ['tag10']),
      const Item(
        id: 'item_10',
        title: 'Item Ten',
        priority: ItemPriority.urgent,
        tags: ['tag11'],
      ),
      const Item(id: 'item_11', title: 'Item Eleven', tags: ['tag12']),
      const Item(
        id: 'item_12',
        title: 'Item Twelve',
        priority: ItemPriority.low,
        tags: ['tag13'],
        completed: true,
      ),
    ];

    _storage[ItemSource.source4] = [
      const Item(
        id: 'item_13',
        title: 'Item Thirteen',
        priority: ItemPriority.low,
        tags: ['tag14'],
        completed: true,
      ),
      const Item(id: 'item_14', title: 'Item Fourteen', tags: ['tag15']),
      const Item(
        id: 'item_15',
        title: 'Item Fifteen',
        description: 'Description',
        tags: ['tag16'],
      ),
    ];
  }
}

class ItemRepository {
  ItemRepository({this.networkDelayMs = 800, this.shouldThrowError = false})
    : _dataStore = ItemDataStore();

  final int networkDelayMs;
  final bool shouldThrowError;
  final ItemDataStore _dataStore;

  AllItemsResponse _buildAllItemsResponse() {
    final allItems = _dataStore.getAllItems();
    final counts = _dataStore.getItemCountsBySource();
    final sourceCount = counts.map(
      (key, value) => MapEntry(key.displayName, value),
    );

    return AllItemsResponse(items: allItems, sourceCount: sourceCount);
  }

  Future<AllItemsResponse> fetchAllItems() async {
    await Future<void>.delayed(Duration(milliseconds: networkDelayMs));

    if (shouldThrowError) {
      throw Exception('Network error fetching items');
    }

    return _buildAllItemsResponse();
  }

  Future<void> addItem(ItemSource source, Item item) async {
    await Future<void>.delayed(Duration(milliseconds: networkDelayMs));

    if (shouldThrowError) {
      throw Exception('Network error adding item');
    }

    _dataStore.addItem(source, item);
  }

  Future<void> updateItem(ItemSource source, Item item) async {
    await Future<void>.delayed(Duration(milliseconds: networkDelayMs));

    if (shouldThrowError) {
      throw Exception('Network error updating item');
    }

    _dataStore.updateItem(source, item);
  }

  Future<void> deleteItem(ItemSource source, String itemId) async {
    await Future<void>.delayed(Duration(milliseconds: networkDelayMs));

    if (shouldThrowError) {
      throw Exception('Network error deleting item');
    }

    _dataStore.deleteItem(source, itemId);
  }

  Future<List<Item>> searchInSource(ItemSource source, String query) async {
    await Future<void>.delayed(Duration(milliseconds: networkDelayMs));

    if (shouldThrowError) {
      throw Exception('Network error searching in ${source.displayName}');
    }

    final results = _dataStore.searchInSource(source, query);
    return results.map((item) {
      return item.copyWith(source: source.displayName);
    }).toList();
  }

  Map<ItemSource, int> getItemCountsBySource() {
    return _dataStore.getItemCountsBySource();
  }
}
