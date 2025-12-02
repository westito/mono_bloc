enum ItemPriority { low, medium, high, urgent }

enum ItemSource { source1, source2, source3, source4 }

extension ItemSourceExtension on ItemSource {
  String get displayName {
    switch (this) {
      case ItemSource.source1:
        return 'Source1';
      case ItemSource.source2:
        return 'Source2';
      case ItemSource.source3:
        return 'Source3';
      case ItemSource.source4:
        return 'Source4';
    }
  }
}

class Item {
  const Item({
    required this.id,
    required this.title,
    this.completed = false,
    this.priority = ItemPriority.medium,
    this.tags = const [],
    this.description,
    this.source,
  });

  final String id;
  final String title;
  final bool completed;
  final ItemPriority priority;
  final List<String> tags;
  final String? description;
  final String? source;

  Item copyWith({
    String? id,
    String? title,
    bool? completed,
    ItemPriority? priority,
    List<String>? tags,
    String? description,
    String? source,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      source: source ?? this.source,
    );
  }
}

class AllItemsResponse {
  const AllItemsResponse({required this.items, required this.sourceCount});

  final List<Item> items;
  final Map<String, int> sourceCount;
}

class ItemSourceResult {
  const ItemSourceResult({
    required this.source,
    required this.items,
    this.error,
  });

  final ItemSource source;
  final List<Item> items;
  final String? error;

  bool get hasError => error != null;
  bool get isEmpty => items.isEmpty && !hasError;
}
