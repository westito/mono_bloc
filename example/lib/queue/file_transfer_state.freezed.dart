// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_transfer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FileItem {

 String get id; String get name; int get size; int get bytesTransferred; FileType get type; DateTime? get uploadDate; bool get isPaused;
/// Create a copy of FileItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileItemCopyWith<FileItem> get copyWith => _$FileItemCopyWithImpl<FileItem>(this as FileItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.size, size) || other.size == size)&&(identical(other.bytesTransferred, bytesTransferred) || other.bytesTransferred == bytesTransferred)&&(identical(other.type, type) || other.type == type)&&(identical(other.uploadDate, uploadDate) || other.uploadDate == uploadDate)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,size,bytesTransferred,type,uploadDate,isPaused);

@override
String toString() {
  return 'FileItem(id: $id, name: $name, size: $size, bytesTransferred: $bytesTransferred, type: $type, uploadDate: $uploadDate, isPaused: $isPaused)';
}


}

/// @nodoc
abstract mixin class $FileItemCopyWith<$Res>  {
  factory $FileItemCopyWith(FileItem value, $Res Function(FileItem) _then) = _$FileItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, int size, int bytesTransferred, FileType type, DateTime? uploadDate, bool isPaused
});




}
/// @nodoc
class _$FileItemCopyWithImpl<$Res>
    implements $FileItemCopyWith<$Res> {
  _$FileItemCopyWithImpl(this._self, this._then);

  final FileItem _self;
  final $Res Function(FileItem) _then;

/// Create a copy of FileItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? size = null,Object? bytesTransferred = null,Object? type = null,Object? uploadDate = freezed,Object? isPaused = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,bytesTransferred: null == bytesTransferred ? _self.bytesTransferred : bytesTransferred // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FileType,uploadDate: freezed == uploadDate ? _self.uploadDate : uploadDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FileItem].
extension FileItemPatterns on FileItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FileItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FileItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FileItem value)  $default,){
final _that = this;
switch (_that) {
case _FileItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FileItem value)?  $default,){
final _that = this;
switch (_that) {
case _FileItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int size,  int bytesTransferred,  FileType type,  DateTime? uploadDate,  bool isPaused)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FileItem() when $default != null:
return $default(_that.id,_that.name,_that.size,_that.bytesTransferred,_that.type,_that.uploadDate,_that.isPaused);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int size,  int bytesTransferred,  FileType type,  DateTime? uploadDate,  bool isPaused)  $default,) {final _that = this;
switch (_that) {
case _FileItem():
return $default(_that.id,_that.name,_that.size,_that.bytesTransferred,_that.type,_that.uploadDate,_that.isPaused);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int size,  int bytesTransferred,  FileType type,  DateTime? uploadDate,  bool isPaused)?  $default,) {final _that = this;
switch (_that) {
case _FileItem() when $default != null:
return $default(_that.id,_that.name,_that.size,_that.bytesTransferred,_that.type,_that.uploadDate,_that.isPaused);case _:
  return null;

}
}

}

/// @nodoc


class _FileItem implements FileItem {
  const _FileItem({required this.id, required this.name, required this.size, this.bytesTransferred = 0, this.type = FileType.other, this.uploadDate, this.isPaused = false});
  

@override final  String id;
@override final  String name;
@override final  int size;
@override@JsonKey() final  int bytesTransferred;
@override@JsonKey() final  FileType type;
@override final  DateTime? uploadDate;
@override@JsonKey() final  bool isPaused;

/// Create a copy of FileItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FileItemCopyWith<_FileItem> get copyWith => __$FileItemCopyWithImpl<_FileItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FileItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.size, size) || other.size == size)&&(identical(other.bytesTransferred, bytesTransferred) || other.bytesTransferred == bytesTransferred)&&(identical(other.type, type) || other.type == type)&&(identical(other.uploadDate, uploadDate) || other.uploadDate == uploadDate)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,size,bytesTransferred,type,uploadDate,isPaused);

@override
String toString() {
  return 'FileItem(id: $id, name: $name, size: $size, bytesTransferred: $bytesTransferred, type: $type, uploadDate: $uploadDate, isPaused: $isPaused)';
}


}

/// @nodoc
abstract mixin class _$FileItemCopyWith<$Res> implements $FileItemCopyWith<$Res> {
  factory _$FileItemCopyWith(_FileItem value, $Res Function(_FileItem) _then) = __$FileItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int size, int bytesTransferred, FileType type, DateTime? uploadDate, bool isPaused
});




}
/// @nodoc
class __$FileItemCopyWithImpl<$Res>
    implements _$FileItemCopyWith<$Res> {
  __$FileItemCopyWithImpl(this._self, this._then);

  final _FileItem _self;
  final $Res Function(_FileItem) _then;

/// Create a copy of FileItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? size = null,Object? bytesTransferred = null,Object? type = null,Object? uploadDate = freezed,Object? isPaused = null,}) {
  return _then(_FileItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,bytesTransferred: null == bytesTransferred ? _self.bytesTransferred : bytesTransferred // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FileType,uploadDate: freezed == uploadDate ? _self.uploadDate : uploadDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$FileTransferState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileTransferState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FileTransferState()';
}


}

/// @nodoc
class $FileTransferStateCopyWith<$Res>  {
$FileTransferStateCopyWith(FileTransferState _, $Res Function(FileTransferState) __);
}


/// Adds pattern-matching-related methods to [FileTransferState].
extension FileTransferStatePatterns on FileTransferState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FileTransferIdle value)?  idle,TResult Function( FileTransferUploading value)?  uploading,TResult Function( FileTransferDownloading value)?  downloading,TResult Function( FileTransferSearching value)?  searching,TResult Function( FileTransferRefreshing value)?  refreshing,TResult Function( FileTransferDeleting value)?  deleting,TResult Function( FileTransferFiltering value)?  filtering,TResult Function( FileTransferSorting value)?  sorting,TResult Function( FileTransferError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FileTransferIdle() when idle != null:
return idle(_that);case FileTransferUploading() when uploading != null:
return uploading(_that);case FileTransferDownloading() when downloading != null:
return downloading(_that);case FileTransferSearching() when searching != null:
return searching(_that);case FileTransferRefreshing() when refreshing != null:
return refreshing(_that);case FileTransferDeleting() when deleting != null:
return deleting(_that);case FileTransferFiltering() when filtering != null:
return filtering(_that);case FileTransferSorting() when sorting != null:
return sorting(_that);case FileTransferError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FileTransferIdle value)  idle,required TResult Function( FileTransferUploading value)  uploading,required TResult Function( FileTransferDownloading value)  downloading,required TResult Function( FileTransferSearching value)  searching,required TResult Function( FileTransferRefreshing value)  refreshing,required TResult Function( FileTransferDeleting value)  deleting,required TResult Function( FileTransferFiltering value)  filtering,required TResult Function( FileTransferSorting value)  sorting,required TResult Function( FileTransferError value)  error,}){
final _that = this;
switch (_that) {
case FileTransferIdle():
return idle(_that);case FileTransferUploading():
return uploading(_that);case FileTransferDownloading():
return downloading(_that);case FileTransferSearching():
return searching(_that);case FileTransferRefreshing():
return refreshing(_that);case FileTransferDeleting():
return deleting(_that);case FileTransferFiltering():
return filtering(_that);case FileTransferSorting():
return sorting(_that);case FileTransferError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FileTransferIdle value)?  idle,TResult? Function( FileTransferUploading value)?  uploading,TResult? Function( FileTransferDownloading value)?  downloading,TResult? Function( FileTransferSearching value)?  searching,TResult? Function( FileTransferRefreshing value)?  refreshing,TResult? Function( FileTransferDeleting value)?  deleting,TResult? Function( FileTransferFiltering value)?  filtering,TResult? Function( FileTransferSorting value)?  sorting,TResult? Function( FileTransferError value)?  error,}){
final _that = this;
switch (_that) {
case FileTransferIdle() when idle != null:
return idle(_that);case FileTransferUploading() when uploading != null:
return uploading(_that);case FileTransferDownloading() when downloading != null:
return downloading(_that);case FileTransferSearching() when searching != null:
return searching(_that);case FileTransferRefreshing() when refreshing != null:
return refreshing(_that);case FileTransferDeleting() when deleting != null:
return deleting(_that);case FileTransferFiltering() when filtering != null:
return filtering(_that);case FileTransferSorting() when sorting != null:
return sorting(_that);case FileTransferError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<FileItem> files,  SortOrder? sortOrder,  FileType? filterType)?  idle,TResult Function( FileItem file,  List<FileItem> files,  String? operation)?  uploading,TResult Function( List<FileItem> activeDownloads,  List<FileItem> files)?  downloading,TResult Function( String query,  List<FileItem> results)?  searching,TResult Function( List<FileItem> files,  String? operation)?  refreshing,TResult Function( List<String> fileIds,  List<FileItem> files)?  deleting,TResult Function( FileType type,  List<FileItem> results)?  filtering,TResult Function( SortOrder order,  List<FileItem> files)?  sorting,TResult Function( String message,  List<FileItem> files)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FileTransferIdle() when idle != null:
return idle(_that.files,_that.sortOrder,_that.filterType);case FileTransferUploading() when uploading != null:
return uploading(_that.file,_that.files,_that.operation);case FileTransferDownloading() when downloading != null:
return downloading(_that.activeDownloads,_that.files);case FileTransferSearching() when searching != null:
return searching(_that.query,_that.results);case FileTransferRefreshing() when refreshing != null:
return refreshing(_that.files,_that.operation);case FileTransferDeleting() when deleting != null:
return deleting(_that.fileIds,_that.files);case FileTransferFiltering() when filtering != null:
return filtering(_that.type,_that.results);case FileTransferSorting() when sorting != null:
return sorting(_that.order,_that.files);case FileTransferError() when error != null:
return error(_that.message,_that.files);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<FileItem> files,  SortOrder? sortOrder,  FileType? filterType)  idle,required TResult Function( FileItem file,  List<FileItem> files,  String? operation)  uploading,required TResult Function( List<FileItem> activeDownloads,  List<FileItem> files)  downloading,required TResult Function( String query,  List<FileItem> results)  searching,required TResult Function( List<FileItem> files,  String? operation)  refreshing,required TResult Function( List<String> fileIds,  List<FileItem> files)  deleting,required TResult Function( FileType type,  List<FileItem> results)  filtering,required TResult Function( SortOrder order,  List<FileItem> files)  sorting,required TResult Function( String message,  List<FileItem> files)  error,}) {final _that = this;
switch (_that) {
case FileTransferIdle():
return idle(_that.files,_that.sortOrder,_that.filterType);case FileTransferUploading():
return uploading(_that.file,_that.files,_that.operation);case FileTransferDownloading():
return downloading(_that.activeDownloads,_that.files);case FileTransferSearching():
return searching(_that.query,_that.results);case FileTransferRefreshing():
return refreshing(_that.files,_that.operation);case FileTransferDeleting():
return deleting(_that.fileIds,_that.files);case FileTransferFiltering():
return filtering(_that.type,_that.results);case FileTransferSorting():
return sorting(_that.order,_that.files);case FileTransferError():
return error(_that.message,_that.files);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<FileItem> files,  SortOrder? sortOrder,  FileType? filterType)?  idle,TResult? Function( FileItem file,  List<FileItem> files,  String? operation)?  uploading,TResult? Function( List<FileItem> activeDownloads,  List<FileItem> files)?  downloading,TResult? Function( String query,  List<FileItem> results)?  searching,TResult? Function( List<FileItem> files,  String? operation)?  refreshing,TResult? Function( List<String> fileIds,  List<FileItem> files)?  deleting,TResult? Function( FileType type,  List<FileItem> results)?  filtering,TResult? Function( SortOrder order,  List<FileItem> files)?  sorting,TResult? Function( String message,  List<FileItem> files)?  error,}) {final _that = this;
switch (_that) {
case FileTransferIdle() when idle != null:
return idle(_that.files,_that.sortOrder,_that.filterType);case FileTransferUploading() when uploading != null:
return uploading(_that.file,_that.files,_that.operation);case FileTransferDownloading() when downloading != null:
return downloading(_that.activeDownloads,_that.files);case FileTransferSearching() when searching != null:
return searching(_that.query,_that.results);case FileTransferRefreshing() when refreshing != null:
return refreshing(_that.files,_that.operation);case FileTransferDeleting() when deleting != null:
return deleting(_that.fileIds,_that.files);case FileTransferFiltering() when filtering != null:
return filtering(_that.type,_that.results);case FileTransferSorting() when sorting != null:
return sorting(_that.order,_that.files);case FileTransferError() when error != null:
return error(_that.message,_that.files);case _:
  return null;

}
}

}

/// @nodoc


class FileTransferIdle implements FileTransferState {
  const FileTransferIdle({final  List<FileItem> files = const [], this.sortOrder, this.filterType}): _files = files;
  

 final  List<FileItem> _files;
@JsonKey() List<FileItem> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}

 final  SortOrder? sortOrder;
 final  FileType? filterType;

/// Create a copy of FileTransferState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileTransferIdleCopyWith<FileTransferIdle> get copyWith => _$FileTransferIdleCopyWithImpl<FileTransferIdle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileTransferIdle&&const DeepCollectionEquality().equals(other._files, _files)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.filterType, filterType) || other.filterType == filterType));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_files),sortOrder,filterType);

@override
String toString() {
  return 'FileTransferState.idle(files: $files, sortOrder: $sortOrder, filterType: $filterType)';
}


}

/// @nodoc
abstract mixin class $FileTransferIdleCopyWith<$Res> implements $FileTransferStateCopyWith<$Res> {
  factory $FileTransferIdleCopyWith(FileTransferIdle value, $Res Function(FileTransferIdle) _then) = _$FileTransferIdleCopyWithImpl;
@useResult
$Res call({
 List<FileItem> files, SortOrder? sortOrder, FileType? filterType
});




}
/// @nodoc
class _$FileTransferIdleCopyWithImpl<$Res>
    implements $FileTransferIdleCopyWith<$Res> {
  _$FileTransferIdleCopyWithImpl(this._self, this._then);

  final FileTransferIdle _self;
  final $Res Function(FileTransferIdle) _then;

/// Create a copy of FileTransferState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? files = null,Object? sortOrder = freezed,Object? filterType = freezed,}) {
  return _then(FileTransferIdle(
files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<FileItem>,sortOrder: freezed == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as SortOrder?,filterType: freezed == filterType ? _self.filterType : filterType // ignore: cast_nullable_to_non_nullable
as FileType?,
  ));
}


}

/// @nodoc


class FileTransferUploading implements FileTransferState {
  const FileTransferUploading({required this.file, final  List<FileItem> files = const [], this.operation}): _files = files;
  

 final  FileItem file;
 final  List<FileItem> _files;
@JsonKey() List<FileItem> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}

 final  String? operation;

/// Create a copy of FileTransferState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileTransferUploadingCopyWith<FileTransferUploading> get copyWith => _$FileTransferUploadingCopyWithImpl<FileTransferUploading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileTransferUploading&&(identical(other.file, file) || other.file == file)&&const DeepCollectionEquality().equals(other._files, _files)&&(identical(other.operation, operation) || other.operation == operation));
}


@override
int get hashCode => Object.hash(runtimeType,file,const DeepCollectionEquality().hash(_files),operation);

@override
String toString() {
  return 'FileTransferState.uploading(file: $file, files: $files, operation: $operation)';
}


}

/// @nodoc
abstract mixin class $FileTransferUploadingCopyWith<$Res> implements $FileTransferStateCopyWith<$Res> {
  factory $FileTransferUploadingCopyWith(FileTransferUploading value, $Res Function(FileTransferUploading) _then) = _$FileTransferUploadingCopyWithImpl;
@useResult
$Res call({
 FileItem file, List<FileItem> files, String? operation
});


$FileItemCopyWith<$Res> get file;

}
/// @nodoc
class _$FileTransferUploadingCopyWithImpl<$Res>
    implements $FileTransferUploadingCopyWith<$Res> {
  _$FileTransferUploadingCopyWithImpl(this._self, this._then);

  final FileTransferUploading _self;
  final $Res Function(FileTransferUploading) _then;

/// Create a copy of FileTransferState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? file = null,Object? files = null,Object? operation = freezed,}) {
  return _then(FileTransferUploading(
file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as FileItem,files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<FileItem>,operation: freezed == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of FileTransferState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileItemCopyWith<$Res> get file {
  
  return $FileItemCopyWith<$Res>(_self.file, (value) {
    return _then(_self.copyWith(file: value));
  });
}
}

/// @nodoc


class FileTransferDownloading implements FileTransferState {
  const FileTransferDownloading({required final  List<FileItem> activeDownloads, final  List<FileItem> files = const []}): _activeDownloads = activeDownloads,_files = files;
  

 final  List<FileItem> _activeDownloads;
 List<FileItem> get activeDownloads {
  if (_activeDownloads is EqualUnmodifiableListView) return _activeDownloads;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activeDownloads);
}

 final  List<FileItem> _files;
@JsonKey() List<FileItem> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}


/// Create a copy of FileTransferState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileTransferDownloadingCopyWith<FileTransferDownloading> get copyWith => _$FileTransferDownloadingCopyWithImpl<FileTransferDownloading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileTransferDownloading&&const DeepCollectionEquality().equals(other._activeDownloads, _activeDownloads)&&const DeepCollectionEquality().equals(other._files, _files));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_activeDownloads),const DeepCollectionEquality().hash(_files));

@override
String toString() {
  return 'FileTransferState.downloading(activeDownloads: $activeDownloads, files: $files)';
}


}

/// @nodoc
abstract mixin class $FileTransferDownloadingCopyWith<$Res> implements $FileTransferStateCopyWith<$Res> {
  factory $FileTransferDownloadingCopyWith(FileTransferDownloading value, $Res Function(FileTransferDownloading) _then) = _$FileTransferDownloadingCopyWithImpl;
@useResult
$Res call({
 List<FileItem> activeDownloads, List<FileItem> files
});




}
/// @nodoc
class _$FileTransferDownloadingCopyWithImpl<$Res>
    implements $FileTransferDownloadingCopyWith<$Res> {
  _$FileTransferDownloadingCopyWithImpl(this._self, this._then);

  final FileTransferDownloading _self;
  final $Res Function(FileTransferDownloading) _then;

/// Create a copy of FileTransferState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? activeDownloads = null,Object? files = null,}) {
  return _then(FileTransferDownloading(
activeDownloads: null == activeDownloads ? _self._activeDownloads : activeDownloads // ignore: cast_nullable_to_non_nullable
as List<FileItem>,files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<FileItem>,
  ));
}


}

/// @nodoc


class FileTransferSearching implements FileTransferState {
  const FileTransferSearching({required this.query, final  List<FileItem> results = const []}): _results = results;
  

 final  String query;
 final  List<FileItem> _results;
@JsonKey() List<FileItem> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}


/// Create a copy of FileTransferState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileTransferSearchingCopyWith<FileTransferSearching> get copyWith => _$FileTransferSearchingCopyWithImpl<FileTransferSearching>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileTransferSearching&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other._results, _results));
}


@override
int get hashCode => Object.hash(runtimeType,query,const DeepCollectionEquality().hash(_results));

@override
String toString() {
  return 'FileTransferState.searching(query: $query, results: $results)';
}


}

/// @nodoc
abstract mixin class $FileTransferSearchingCopyWith<$Res> implements $FileTransferStateCopyWith<$Res> {
  factory $FileTransferSearchingCopyWith(FileTransferSearching value, $Res Function(FileTransferSearching) _then) = _$FileTransferSearchingCopyWithImpl;
@useResult
$Res call({
 String query, List<FileItem> results
});




}
/// @nodoc
class _$FileTransferSearchingCopyWithImpl<$Res>
    implements $FileTransferSearchingCopyWith<$Res> {
  _$FileTransferSearchingCopyWithImpl(this._self, this._then);

  final FileTransferSearching _self;
  final $Res Function(FileTransferSearching) _then;

/// Create a copy of FileTransferState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? query = null,Object? results = null,}) {
  return _then(FileTransferSearching(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<FileItem>,
  ));
}


}

/// @nodoc


class FileTransferRefreshing implements FileTransferState {
  const FileTransferRefreshing({final  List<FileItem> files = const [], this.operation}): _files = files;
  

 final  List<FileItem> _files;
@JsonKey() List<FileItem> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}

 final  String? operation;

/// Create a copy of FileTransferState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileTransferRefreshingCopyWith<FileTransferRefreshing> get copyWith => _$FileTransferRefreshingCopyWithImpl<FileTransferRefreshing>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileTransferRefreshing&&const DeepCollectionEquality().equals(other._files, _files)&&(identical(other.operation, operation) || other.operation == operation));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_files),operation);

@override
String toString() {
  return 'FileTransferState.refreshing(files: $files, operation: $operation)';
}


}

/// @nodoc
abstract mixin class $FileTransferRefreshingCopyWith<$Res> implements $FileTransferStateCopyWith<$Res> {
  factory $FileTransferRefreshingCopyWith(FileTransferRefreshing value, $Res Function(FileTransferRefreshing) _then) = _$FileTransferRefreshingCopyWithImpl;
@useResult
$Res call({
 List<FileItem> files, String? operation
});




}
/// @nodoc
class _$FileTransferRefreshingCopyWithImpl<$Res>
    implements $FileTransferRefreshingCopyWith<$Res> {
  _$FileTransferRefreshingCopyWithImpl(this._self, this._then);

  final FileTransferRefreshing _self;
  final $Res Function(FileTransferRefreshing) _then;

/// Create a copy of FileTransferState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? files = null,Object? operation = freezed,}) {
  return _then(FileTransferRefreshing(
files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<FileItem>,operation: freezed == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class FileTransferDeleting implements FileTransferState {
  const FileTransferDeleting({required final  List<String> fileIds, final  List<FileItem> files = const []}): _fileIds = fileIds,_files = files;
  

 final  List<String> _fileIds;
 List<String> get fileIds {
  if (_fileIds is EqualUnmodifiableListView) return _fileIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fileIds);
}

 final  List<FileItem> _files;
@JsonKey() List<FileItem> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}


/// Create a copy of FileTransferState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileTransferDeletingCopyWith<FileTransferDeleting> get copyWith => _$FileTransferDeletingCopyWithImpl<FileTransferDeleting>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileTransferDeleting&&const DeepCollectionEquality().equals(other._fileIds, _fileIds)&&const DeepCollectionEquality().equals(other._files, _files));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_fileIds),const DeepCollectionEquality().hash(_files));

@override
String toString() {
  return 'FileTransferState.deleting(fileIds: $fileIds, files: $files)';
}


}

/// @nodoc
abstract mixin class $FileTransferDeletingCopyWith<$Res> implements $FileTransferStateCopyWith<$Res> {
  factory $FileTransferDeletingCopyWith(FileTransferDeleting value, $Res Function(FileTransferDeleting) _then) = _$FileTransferDeletingCopyWithImpl;
@useResult
$Res call({
 List<String> fileIds, List<FileItem> files
});




}
/// @nodoc
class _$FileTransferDeletingCopyWithImpl<$Res>
    implements $FileTransferDeletingCopyWith<$Res> {
  _$FileTransferDeletingCopyWithImpl(this._self, this._then);

  final FileTransferDeleting _self;
  final $Res Function(FileTransferDeleting) _then;

/// Create a copy of FileTransferState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fileIds = null,Object? files = null,}) {
  return _then(FileTransferDeleting(
fileIds: null == fileIds ? _self._fileIds : fileIds // ignore: cast_nullable_to_non_nullable
as List<String>,files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<FileItem>,
  ));
}


}

/// @nodoc


class FileTransferFiltering implements FileTransferState {
  const FileTransferFiltering({required this.type, final  List<FileItem> results = const []}): _results = results;
  

 final  FileType type;
 final  List<FileItem> _results;
@JsonKey() List<FileItem> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}


/// Create a copy of FileTransferState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileTransferFilteringCopyWith<FileTransferFiltering> get copyWith => _$FileTransferFilteringCopyWithImpl<FileTransferFiltering>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileTransferFiltering&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._results, _results));
}


@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_results));

@override
String toString() {
  return 'FileTransferState.filtering(type: $type, results: $results)';
}


}

/// @nodoc
abstract mixin class $FileTransferFilteringCopyWith<$Res> implements $FileTransferStateCopyWith<$Res> {
  factory $FileTransferFilteringCopyWith(FileTransferFiltering value, $Res Function(FileTransferFiltering) _then) = _$FileTransferFilteringCopyWithImpl;
@useResult
$Res call({
 FileType type, List<FileItem> results
});




}
/// @nodoc
class _$FileTransferFilteringCopyWithImpl<$Res>
    implements $FileTransferFilteringCopyWith<$Res> {
  _$FileTransferFilteringCopyWithImpl(this._self, this._then);

  final FileTransferFiltering _self;
  final $Res Function(FileTransferFiltering) _then;

/// Create a copy of FileTransferState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? type = null,Object? results = null,}) {
  return _then(FileTransferFiltering(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FileType,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<FileItem>,
  ));
}


}

/// @nodoc


class FileTransferSorting implements FileTransferState {
  const FileTransferSorting({required this.order, final  List<FileItem> files = const []}): _files = files;
  

 final  SortOrder order;
 final  List<FileItem> _files;
@JsonKey() List<FileItem> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}


/// Create a copy of FileTransferState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileTransferSortingCopyWith<FileTransferSorting> get copyWith => _$FileTransferSortingCopyWithImpl<FileTransferSorting>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileTransferSorting&&(identical(other.order, order) || other.order == order)&&const DeepCollectionEquality().equals(other._files, _files));
}


@override
int get hashCode => Object.hash(runtimeType,order,const DeepCollectionEquality().hash(_files));

@override
String toString() {
  return 'FileTransferState.sorting(order: $order, files: $files)';
}


}

/// @nodoc
abstract mixin class $FileTransferSortingCopyWith<$Res> implements $FileTransferStateCopyWith<$Res> {
  factory $FileTransferSortingCopyWith(FileTransferSorting value, $Res Function(FileTransferSorting) _then) = _$FileTransferSortingCopyWithImpl;
@useResult
$Res call({
 SortOrder order, List<FileItem> files
});




}
/// @nodoc
class _$FileTransferSortingCopyWithImpl<$Res>
    implements $FileTransferSortingCopyWith<$Res> {
  _$FileTransferSortingCopyWithImpl(this._self, this._then);

  final FileTransferSorting _self;
  final $Res Function(FileTransferSorting) _then;

/// Create a copy of FileTransferState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? order = null,Object? files = null,}) {
  return _then(FileTransferSorting(
order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as SortOrder,files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<FileItem>,
  ));
}


}

/// @nodoc


class FileTransferError implements FileTransferState {
  const FileTransferError({required this.message, final  List<FileItem> files = const []}): _files = files;
  

 final  String message;
 final  List<FileItem> _files;
@JsonKey() List<FileItem> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}


/// Create a copy of FileTransferState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileTransferErrorCopyWith<FileTransferError> get copyWith => _$FileTransferErrorCopyWithImpl<FileTransferError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileTransferError&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other._files, _files));
}


@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(_files));

@override
String toString() {
  return 'FileTransferState.error(message: $message, files: $files)';
}


}

/// @nodoc
abstract mixin class $FileTransferErrorCopyWith<$Res> implements $FileTransferStateCopyWith<$Res> {
  factory $FileTransferErrorCopyWith(FileTransferError value, $Res Function(FileTransferError) _then) = _$FileTransferErrorCopyWithImpl;
@useResult
$Res call({
 String message, List<FileItem> files
});




}
/// @nodoc
class _$FileTransferErrorCopyWithImpl<$Res>
    implements $FileTransferErrorCopyWith<$Res> {
  _$FileTransferErrorCopyWithImpl(this._self, this._then);

  final FileTransferError _self;
  final $Res Function(FileTransferError) _then;

/// Create a copy of FileTransferState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? files = null,}) {
  return _then(FileTransferError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<FileItem>,
  ));
}


}

// dart format on
