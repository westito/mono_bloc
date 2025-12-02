// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Todo {

/// Unique identifier for the todo
 String get id;/// Title or main description
 String get title;/// Whether the todo has been completed
 bool get completed;/// Priority level for sorting and filtering
 TodoPriority get priority;/// Tags for categorization and search
 List<String> get tags;/// Optional detailed description
 String? get description;/// Source system this todo came from (MyTodo, DoItNow, etc.)
 String? get source;/// Optional due date for deadline tracking
 DateTime? get dueDate;/// When the todo was created
 DateTime? get createdAt;/// When the todo was marked complete
 DateTime? get completedAt;
/// Create a copy of Todo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodoCopyWith<Todo> get copyWith => _$TodoCopyWithImpl<Todo>(this as Todo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Todo&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.priority, priority) || other.priority == priority)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.description, description) || other.description == description)&&(identical(other.source, source) || other.source == source)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,completed,priority,const DeepCollectionEquality().hash(tags),description,source,dueDate,createdAt,completedAt);

@override
String toString() {
  return 'Todo(id: $id, title: $title, completed: $completed, priority: $priority, tags: $tags, description: $description, source: $source, dueDate: $dueDate, createdAt: $createdAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $TodoCopyWith<$Res>  {
  factory $TodoCopyWith(Todo value, $Res Function(Todo) _then) = _$TodoCopyWithImpl;
@useResult
$Res call({
 String id, String title, bool completed, TodoPriority priority, List<String> tags, String? description, String? source, DateTime? dueDate, DateTime? createdAt, DateTime? completedAt
});




}
/// @nodoc
class _$TodoCopyWithImpl<$Res>
    implements $TodoCopyWith<$Res> {
  _$TodoCopyWithImpl(this._self, this._then);

  final Todo _self;
  final $Res Function(Todo) _then;

/// Create a copy of Todo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? completed = null,Object? priority = null,Object? tags = null,Object? description = freezed,Object? source = freezed,Object? dueDate = freezed,Object? createdAt = freezed,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TodoPriority,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Todo].
extension TodoPatterns on Todo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Todo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Todo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Todo value)  $default,){
final _that = this;
switch (_that) {
case _Todo():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Todo value)?  $default,){
final _that = this;
switch (_that) {
case _Todo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  bool completed,  TodoPriority priority,  List<String> tags,  String? description,  String? source,  DateTime? dueDate,  DateTime? createdAt,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Todo() when $default != null:
return $default(_that.id,_that.title,_that.completed,_that.priority,_that.tags,_that.description,_that.source,_that.dueDate,_that.createdAt,_that.completedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  bool completed,  TodoPriority priority,  List<String> tags,  String? description,  String? source,  DateTime? dueDate,  DateTime? createdAt,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _Todo():
return $default(_that.id,_that.title,_that.completed,_that.priority,_that.tags,_that.description,_that.source,_that.dueDate,_that.createdAt,_that.completedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  bool completed,  TodoPriority priority,  List<String> tags,  String? description,  String? source,  DateTime? dueDate,  DateTime? createdAt,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _Todo() when $default != null:
return $default(_that.id,_that.title,_that.completed,_that.priority,_that.tags,_that.description,_that.source,_that.dueDate,_that.createdAt,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Todo implements Todo {
  const _Todo({required this.id, required this.title, this.completed = false, this.priority = TodoPriority.medium, final  List<String> tags = const [], this.description, this.source, this.dueDate, this.createdAt, this.completedAt}): _tags = tags;
  

/// Unique identifier for the todo
@override final  String id;
/// Title or main description
@override final  String title;
/// Whether the todo has been completed
@override@JsonKey() final  bool completed;
/// Priority level for sorting and filtering
@override@JsonKey() final  TodoPriority priority;
/// Tags for categorization and search
 final  List<String> _tags;
/// Tags for categorization and search
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

/// Optional detailed description
@override final  String? description;
/// Source system this todo came from (MyTodo, DoItNow, etc.)
@override final  String? source;
/// Optional due date for deadline tracking
@override final  DateTime? dueDate;
/// When the todo was created
@override final  DateTime? createdAt;
/// When the todo was marked complete
@override final  DateTime? completedAt;

/// Create a copy of Todo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodoCopyWith<_Todo> get copyWith => __$TodoCopyWithImpl<_Todo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Todo&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.priority, priority) || other.priority == priority)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.description, description) || other.description == description)&&(identical(other.source, source) || other.source == source)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,completed,priority,const DeepCollectionEquality().hash(_tags),description,source,dueDate,createdAt,completedAt);

@override
String toString() {
  return 'Todo(id: $id, title: $title, completed: $completed, priority: $priority, tags: $tags, description: $description, source: $source, dueDate: $dueDate, createdAt: $createdAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$TodoCopyWith<$Res> implements $TodoCopyWith<$Res> {
  factory _$TodoCopyWith(_Todo value, $Res Function(_Todo) _then) = __$TodoCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, bool completed, TodoPriority priority, List<String> tags, String? description, String? source, DateTime? dueDate, DateTime? createdAt, DateTime? completedAt
});




}
/// @nodoc
class __$TodoCopyWithImpl<$Res>
    implements _$TodoCopyWith<$Res> {
  __$TodoCopyWithImpl(this._self, this._then);

  final _Todo _self;
  final $Res Function(_Todo) _then;

/// Create a copy of Todo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? completed = null,Object? priority = null,Object? tags = null,Object? description = freezed,Object? source = freezed,Object? dueDate = freezed,Object? createdAt = freezed,Object? completedAt = freezed,}) {
  return _then(_Todo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TodoPriority,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$TodoState {

/// All todos from all sources
 List<Todo> get todos;/// Count of todos per source for display
 Map<String, int> get sourceCount;/// Loading state for async operations
 bool get isLoading;/// Sources that have completed loading
 List<String> get loadedSources;/// Sources still being fetched
 List<String> get pendingSources;/// Current active filter
 TodoFilter get activeFilter;/// Current search query if searching
 String? get searchQuery;/// Error message from failed operations
 String? get errorMessage;
/// Create a copy of TodoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodoStateCopyWith<TodoState> get copyWith => _$TodoStateCopyWithImpl<TodoState>(this as TodoState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodoState&&const DeepCollectionEquality().equals(other.todos, todos)&&const DeepCollectionEquality().equals(other.sourceCount, sourceCount)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.loadedSources, loadedSources)&&const DeepCollectionEquality().equals(other.pendingSources, pendingSources)&&(identical(other.activeFilter, activeFilter) || other.activeFilter == activeFilter)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(todos),const DeepCollectionEquality().hash(sourceCount),isLoading,const DeepCollectionEquality().hash(loadedSources),const DeepCollectionEquality().hash(pendingSources),activeFilter,searchQuery,errorMessage);

@override
String toString() {
  return 'TodoState(todos: $todos, sourceCount: $sourceCount, isLoading: $isLoading, loadedSources: $loadedSources, pendingSources: $pendingSources, activeFilter: $activeFilter, searchQuery: $searchQuery, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $TodoStateCopyWith<$Res>  {
  factory $TodoStateCopyWith(TodoState value, $Res Function(TodoState) _then) = _$TodoStateCopyWithImpl;
@useResult
$Res call({
 List<Todo> todos, Map<String, int> sourceCount, bool isLoading, List<String> loadedSources, List<String> pendingSources, TodoFilter activeFilter, String? searchQuery, String? errorMessage
});




}
/// @nodoc
class _$TodoStateCopyWithImpl<$Res>
    implements $TodoStateCopyWith<$Res> {
  _$TodoStateCopyWithImpl(this._self, this._then);

  final TodoState _self;
  final $Res Function(TodoState) _then;

/// Create a copy of TodoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? todos = null,Object? sourceCount = null,Object? isLoading = null,Object? loadedSources = null,Object? pendingSources = null,Object? activeFilter = null,Object? searchQuery = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
todos: null == todos ? _self.todos : todos // ignore: cast_nullable_to_non_nullable
as List<Todo>,sourceCount: null == sourceCount ? _self.sourceCount : sourceCount // ignore: cast_nullable_to_non_nullable
as Map<String, int>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,loadedSources: null == loadedSources ? _self.loadedSources : loadedSources // ignore: cast_nullable_to_non_nullable
as List<String>,pendingSources: null == pendingSources ? _self.pendingSources : pendingSources // ignore: cast_nullable_to_non_nullable
as List<String>,activeFilter: null == activeFilter ? _self.activeFilter : activeFilter // ignore: cast_nullable_to_non_nullable
as TodoFilter,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TodoState].
extension TodoStatePatterns on TodoState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodoState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodoState value)  $default,){
final _that = this;
switch (_that) {
case _TodoState():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodoState value)?  $default,){
final _that = this;
switch (_that) {
case _TodoState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Todo> todos,  Map<String, int> sourceCount,  bool isLoading,  List<String> loadedSources,  List<String> pendingSources,  TodoFilter activeFilter,  String? searchQuery,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodoState() when $default != null:
return $default(_that.todos,_that.sourceCount,_that.isLoading,_that.loadedSources,_that.pendingSources,_that.activeFilter,_that.searchQuery,_that.errorMessage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Todo> todos,  Map<String, int> sourceCount,  bool isLoading,  List<String> loadedSources,  List<String> pendingSources,  TodoFilter activeFilter,  String? searchQuery,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _TodoState():
return $default(_that.todos,_that.sourceCount,_that.isLoading,_that.loadedSources,_that.pendingSources,_that.activeFilter,_that.searchQuery,_that.errorMessage);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Todo> todos,  Map<String, int> sourceCount,  bool isLoading,  List<String> loadedSources,  List<String> pendingSources,  TodoFilter activeFilter,  String? searchQuery,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _TodoState() when $default != null:
return $default(_that.todos,_that.sourceCount,_that.isLoading,_that.loadedSources,_that.pendingSources,_that.activeFilter,_that.searchQuery,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _TodoState implements TodoState {
  const _TodoState({final  List<Todo> todos = const [], final  Map<String, int> sourceCount = const {}, this.isLoading = false, final  List<String> loadedSources = const [], final  List<String> pendingSources = const [], this.activeFilter = TodoFilter.all, this.searchQuery, this.errorMessage}): _todos = todos,_sourceCount = sourceCount,_loadedSources = loadedSources,_pendingSources = pendingSources;
  

/// All todos from all sources
 final  List<Todo> _todos;
/// All todos from all sources
@override@JsonKey() List<Todo> get todos {
  if (_todos is EqualUnmodifiableListView) return _todos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_todos);
}

/// Count of todos per source for display
 final  Map<String, int> _sourceCount;
/// Count of todos per source for display
@override@JsonKey() Map<String, int> get sourceCount {
  if (_sourceCount is EqualUnmodifiableMapView) return _sourceCount;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sourceCount);
}

/// Loading state for async operations
@override@JsonKey() final  bool isLoading;
/// Sources that have completed loading
 final  List<String> _loadedSources;
/// Sources that have completed loading
@override@JsonKey() List<String> get loadedSources {
  if (_loadedSources is EqualUnmodifiableListView) return _loadedSources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_loadedSources);
}

/// Sources still being fetched
 final  List<String> _pendingSources;
/// Sources still being fetched
@override@JsonKey() List<String> get pendingSources {
  if (_pendingSources is EqualUnmodifiableListView) return _pendingSources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pendingSources);
}

/// Current active filter
@override@JsonKey() final  TodoFilter activeFilter;
/// Current search query if searching
@override final  String? searchQuery;
/// Error message from failed operations
@override final  String? errorMessage;

/// Create a copy of TodoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodoStateCopyWith<_TodoState> get copyWith => __$TodoStateCopyWithImpl<_TodoState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodoState&&const DeepCollectionEquality().equals(other._todos, _todos)&&const DeepCollectionEquality().equals(other._sourceCount, _sourceCount)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other._loadedSources, _loadedSources)&&const DeepCollectionEquality().equals(other._pendingSources, _pendingSources)&&(identical(other.activeFilter, activeFilter) || other.activeFilter == activeFilter)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_todos),const DeepCollectionEquality().hash(_sourceCount),isLoading,const DeepCollectionEquality().hash(_loadedSources),const DeepCollectionEquality().hash(_pendingSources),activeFilter,searchQuery,errorMessage);

@override
String toString() {
  return 'TodoState(todos: $todos, sourceCount: $sourceCount, isLoading: $isLoading, loadedSources: $loadedSources, pendingSources: $pendingSources, activeFilter: $activeFilter, searchQuery: $searchQuery, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$TodoStateCopyWith<$Res> implements $TodoStateCopyWith<$Res> {
  factory _$TodoStateCopyWith(_TodoState value, $Res Function(_TodoState) _then) = __$TodoStateCopyWithImpl;
@override @useResult
$Res call({
 List<Todo> todos, Map<String, int> sourceCount, bool isLoading, List<String> loadedSources, List<String> pendingSources, TodoFilter activeFilter, String? searchQuery, String? errorMessage
});




}
/// @nodoc
class __$TodoStateCopyWithImpl<$Res>
    implements _$TodoStateCopyWith<$Res> {
  __$TodoStateCopyWithImpl(this._self, this._then);

  final _TodoState _self;
  final $Res Function(_TodoState) _then;

/// Create a copy of TodoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? todos = null,Object? sourceCount = null,Object? isLoading = null,Object? loadedSources = null,Object? pendingSources = null,Object? activeFilter = null,Object? searchQuery = freezed,Object? errorMessage = freezed,}) {
  return _then(_TodoState(
todos: null == todos ? _self._todos : todos // ignore: cast_nullable_to_non_nullable
as List<Todo>,sourceCount: null == sourceCount ? _self._sourceCount : sourceCount // ignore: cast_nullable_to_non_nullable
as Map<String, int>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,loadedSources: null == loadedSources ? _self._loadedSources : loadedSources // ignore: cast_nullable_to_non_nullable
as List<String>,pendingSources: null == pendingSources ? _self._pendingSources : pendingSources // ignore: cast_nullable_to_non_nullable
as List<String>,activeFilter: null == activeFilter ? _self.activeFilter : activeFilter // ignore: cast_nullable_to_non_nullable
as TodoFilter,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
