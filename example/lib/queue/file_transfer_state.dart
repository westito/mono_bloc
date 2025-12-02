import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_transfer_state.freezed.dart';

/// File type for filtering
enum FileType { document, image, video, audio, other }

/// Sort order
enum SortOrder { nameAsc, nameDesc, sizeAsc, sizeDesc, dateAsc, dateDesc }

/// Represents a file being transferred
@freezed
sealed class FileItem with _$FileItem {
  const factory FileItem({
    required String id,
    required String name,
    required int size,
    @Default(0) int bytesTransferred,
    @Default(FileType.other) FileType type,
    DateTime? uploadDate,
    @Default(false) bool isPaused,
  }) = _FileItem;
}

/// Extension methods for FileItem
extension FileItemExtensions on FileItem {
  double get progress => size > 0 ? bytesTransferred / size : 0.0;
  bool get isComplete => bytesTransferred >= size;
}

/// State for file transfer manager
@freezed
sealed class FileTransferState with _$FileTransferState {
  const factory FileTransferState.idle({
    @Default([]) List<FileItem> files,
    SortOrder? sortOrder,
    FileType? filterType,
  }) = FileTransferIdle;

  const factory FileTransferState.uploading({
    required FileItem file,
    @Default([]) List<FileItem> files,
    String? operation,
  }) = FileTransferUploading;

  const factory FileTransferState.downloading({
    required List<FileItem> activeDownloads,
    @Default([]) List<FileItem> files,
  }) = FileTransferDownloading;

  const factory FileTransferState.searching({
    required String query,
    @Default([]) List<FileItem> results,
  }) = FileTransferSearching;

  const factory FileTransferState.refreshing({
    @Default([]) List<FileItem> files,
    String? operation,
  }) = FileTransferRefreshing;

  const factory FileTransferState.deleting({
    required List<String> fileIds,
    @Default([]) List<FileItem> files,
  }) = FileTransferDeleting;

  const factory FileTransferState.filtering({
    required FileType type,
    @Default([]) List<FileItem> results,
  }) = FileTransferFiltering;

  const factory FileTransferState.sorting({
    required SortOrder order,
    @Default([]) List<FileItem> files,
  }) = FileTransferSorting;

  const factory FileTransferState.error({
    required String message,
    @Default([]) List<FileItem> files,
  }) = FileTransferError;
}
