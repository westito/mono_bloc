import 'package:mono_bloc_example/queue/file_transfer_state.dart';
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';

part 'file_transfer_bloc.g.dart';

// Queue identifiers for different operation types
const uploadQueue = 'upload';
const refreshQueue = 'refresh';
const searchQueue = 'search';
const downloadQueue = 'download';
const deleteQueue = 'delete';

/// FileTransferBloc demonstrates real-world queue usage with multiple events per queue:
///
/// Upload Queue (Sequential) - Process one at a time to avoid bandwidth issues:
/// - uploadFile: Upload new file
/// - resumeUpload: Resume paused upload
/// - cancelUpload: Cancel ongoing upload
///
/// Download Queue (Concurrent) - Multiple simultaneous downloads:
/// - downloadFile: Download single file
/// - downloadMultiple: Download multiple files at once
/// - pauseDownload: Pause active download
///
/// Refresh Queue (Droppable) - Ignore new requests while processing:
/// - refreshFiles: Reload file list
/// - syncWithCloud: Sync with cloud storage
///
/// Search Queue (Restartable) - Cancel previous and start new:
/// - searchFiles: Search by filename
/// - filterByType: Filter by file type
/// - sortFiles: Sort files by criteria
///
/// Delete Queue (Sequential) - Process deletions one by one:
/// - deleteFile: Delete single file
/// - deleteMultiple: Delete multiple files
/// - emptyTrash: Clear all deleted files
@MonoBloc()
class FileTransferBloc extends _$FileTransferBloc<FileTransferState> {
  static final _queuesConfig = <String, EventTransformer<dynamic>>{
    uploadQueue: MonoEventTransformer.sequential,
    refreshQueue: MonoEventTransformer.droppable,
    searchQueue: MonoEventTransformer.restartable,
    downloadQueue: MonoEventTransformer.concurrent,
    deleteQueue: MonoEventTransformer.sequential,
  };

  FileTransferBloc()
    : super(const FileTransferState.idle(), queues: _queuesConfig);

  // ============================================================================
  // UPLOAD QUEUE (Sequential) - Process one upload at a time
  // ============================================================================

  /// Sequential upload: Process one file at a time to avoid bandwidth saturation
  @MonoEvent.queue(uploadQueue)
  Future<FileTransferState> _onUploadFile(
    _Emitter emit,
    String fileName,
    int fileSize,
    FileType type,
  ) async {
    final file = FileItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: fileName,
      size: fileSize,
      type: type,
      uploadDate: DateTime.now(),
    );

    emit(
      FileTransferState.uploading(
        file: file,
        files: _currentFiles,
        operation: 'Uploading',
      ),
    );

    // Simulate upload progress
    for (var i = 0; i <= 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final updatedFile = file.copyWith(
        bytesTransferred: (fileSize * i / 10).round(),
      );
      emit(
        FileTransferState.uploading(
          file: updatedFile,
          files: _currentFiles,
          operation: 'Uploading',
        ),
      );
    }

    // Add completed file to list
    final completedFile = file.copyWith(bytesTransferred: fileSize);
    final updatedFiles = [..._currentFiles, completedFile];
    return FileTransferState.idle(files: updatedFiles);
  }

  /// Resume paused upload - also sequential
  @MonoEvent.queue(uploadQueue)
  Future<FileTransferState> _onResumeUpload(
    _Emitter emit,
    String fileId,
  ) async {
    final file = _currentFiles.firstWhere(
      (f) => f.id == fileId,
      orElse: () => const FileItem(id: '', name: 'Unknown', size: 0),
    );

    if (file.id.isEmpty || !file.isPaused) {
      return FileTransferState.error(
        message: 'Cannot resume: file not found or not paused',
        files: _currentFiles,
      );
    }

    emit(
      FileTransferState.uploading(
        file: file.copyWith(isPaused: false),
        files: _currentFiles,
        operation: 'Resuming',
      ),
    );

    // Continue upload from where it left off
    final remainingBytes = file.size - file.bytesTransferred;
    const steps = 10;
    for (var i = 1; i <= steps; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final updatedFile = file.copyWith(
        bytesTransferred:
            file.bytesTransferred + (remainingBytes * i / steps).round(),
        isPaused: false,
      );
      emit(
        FileTransferState.uploading(
          file: updatedFile,
          files: _currentFiles,
          operation: 'Resuming',
        ),
      );
    }

    // Update file in list
    final completedFile = file.copyWith(
      bytesTransferred: file.size,
      isPaused: false,
    );
    final updatedFiles = _currentFiles
        .map((f) => f.id == fileId ? completedFile : f)
        .toList();
    return FileTransferState.idle(files: updatedFiles);
  }

  /// Cancel ongoing upload - sequential to ensure clean cancellation
  @MonoEvent.queue(uploadQueue)
  Future<FileTransferState> _onCancelUpload(
    _Emitter emit,
    String fileId,
  ) async {
    emit(
      FileTransferState.uploading(
        file: FileItem(id: fileId, name: 'Cancelling...', size: 0),
        files: _currentFiles,
        operation: 'Cancelling',
      ),
    );

    // Simulate cleanup
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Remove file from list
    final updatedFiles = _currentFiles.where((f) => f.id != fileId).toList();
    return FileTransferState.idle(files: updatedFiles);
  }

  // ============================================================================
  // DOWNLOAD QUEUE (Concurrent) - Allow multiple simultaneous downloads
  // ============================================================================

  /// Concurrent downloads: Allow multiple files to download simultaneously
  @MonoEvent.queue(downloadQueue)
  Future<FileTransferState> _onDownloadFile(
    _Emitter emit,
    String fileId,
  ) async {
    final file = _currentFiles.firstWhere(
      (f) => f.id == fileId,
      orElse: () => const FileItem(id: '', name: 'Unknown', size: 0),
    );

    if (file.id.isEmpty) {
      return FileTransferState.error(
        message: 'File not found',
        files: _currentFiles,
      );
    }

    // Start download
    final downloadingFile = file.copyWith(bytesTransferred: 0);
    emit(
      FileTransferState.downloading(
        activeDownloads: [downloadingFile],
        files: _currentFiles,
      ),
    );

    // Simulate download progress
    for (var i = 0; i <= 5; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final updatedFile = downloadingFile.copyWith(
        bytesTransferred: (file.size * i / 5).round(),
      );
      emit(
        FileTransferState.downloading(
          activeDownloads: [updatedFile],
          files: _currentFiles,
        ),
      );
    }

    return FileTransferState.idle(files: _currentFiles);
  }

  /// Download multiple files concurrently
  @MonoEvent.queue(downloadQueue)
  Future<FileTransferState> _onDownloadMultiple(
    _Emitter emit,
    List<String> fileIds,
  ) async {
    final filesToDownload = _currentFiles
        .where((f) => fileIds.contains(f.id))
        .map((f) => f.copyWith(bytesTransferred: 0))
        .toList();

    if (filesToDownload.isEmpty) {
      return FileTransferState.error(
        message: 'No files found to download',
        files: _currentFiles,
      );
    }

    // Download all files simultaneously (concurrent behavior)
    const steps = 5;
    for (var i = 0; i <= steps; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final updatedDownloads = filesToDownload
          .map(
            (f) => f.copyWith(bytesTransferred: (f.size * i / steps).round()),
          )
          .toList();

      emit(
        FileTransferState.downloading(
          activeDownloads: updatedDownloads,
          files: _currentFiles,
        ),
      );
    }

    return FileTransferState.idle(files: _currentFiles);
  }

  /// Pause active download
  @MonoEvent.queue(downloadQueue)
  Future<FileTransferState> _onPauseDownload(String fileId) async {
    // Simulate pausing
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final updatedFiles = _currentFiles.map((f) {
      if (f.id == fileId) {
        return f.copyWith(isPaused: true);
      }
      return f;
    }).toList();

    return FileTransferState.idle(files: updatedFiles);
  }

  // ============================================================================
  // REFRESH QUEUE (Droppable) - Ignore new requests while processing
  // ============================================================================

  /// Droppable refresh: Ignore subsequent refresh requests while already refreshing
  @MonoEvent.queue(refreshQueue)
  Future<FileTransferState> _onRefreshFiles(_Emitter emit) async {
    emit(
      FileTransferState.refreshing(
        files: _currentFiles,
        operation: 'Refreshing',
      ),
    );

    // Simulate API call to refresh file list
    await Future<void>.delayed(const Duration(seconds: 2));

    // Simulate getting updated file list
    final refreshedFiles = _currentFiles.map((f) => f.copyWith()).toList();

    return FileTransferState.idle(files: refreshedFiles);
  }

  /// Sync with cloud storage - also droppable
  @MonoEvent.queue(refreshQueue)
  Future<FileTransferState> _onSyncWithCloud(_Emitter emit) async {
    emit(
      FileTransferState.refreshing(
        files: _currentFiles,
        operation: 'Syncing with cloud',
      ),
    );

    // Simulate cloud sync
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    // Simulate adding synced files
    final syncedFiles = [
      ..._currentFiles,
      FileItem(
        id: 'sync_${DateTime.now().millisecondsSinceEpoch}',
        name: 'synced_file.pdf',
        size: 2048000,
        type: FileType.document,
        uploadDate: DateTime.now(),
      ),
    ];

    return FileTransferState.idle(files: syncedFiles);
  }

  // ============================================================================
  // SEARCH QUEUE (Restartable) - Cancel previous and start new
  // ============================================================================

  /// Restartable search: Restart search if triggered again (like user typing)
  @MonoEvent.queue(searchQueue)
  Future<FileTransferState> _onSearchFiles(String query) async {
    // Simulate search delay (debounce effect)
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (query.isEmpty) {
      return FileTransferState.idle(files: _currentFiles);
    }

    // Filter files by query
    final results = _currentFiles
        .where((f) => f.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return FileTransferState.searching(query: query, results: results);
  }

  /// Filter by file type - restartable
  @MonoEvent.queue(searchQueue)
  Future<FileTransferState> _onFilterByType(FileType type) async {
    // Simulate processing
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final results = _currentFiles.where((f) => f.type == type).toList();

    return FileTransferState.filtering(type: type, results: results);
  }

  /// Sort files - restartable so latest sort wins
  @MonoEvent.queue(searchQueue)
  Future<FileTransferState> _onSortFiles(SortOrder order) async {
    // Simulate sorting
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final sortedFiles = [..._currentFiles];

    switch (order) {
      case SortOrder.nameAsc:
        sortedFiles.sort((a, b) => a.name.compareTo(b.name));
      case SortOrder.nameDesc:
        sortedFiles.sort((a, b) => b.name.compareTo(a.name));
      case SortOrder.sizeAsc:
        sortedFiles.sort((a, b) => a.size.compareTo(b.size));
      case SortOrder.sizeDesc:
        sortedFiles.sort((a, b) => b.size.compareTo(a.size));
      case SortOrder.dateAsc:
        sortedFiles.sort((a, b) {
          if (a.uploadDate == null || b.uploadDate == null) return 0;
          return a.uploadDate!.compareTo(b.uploadDate!);
        });
      case SortOrder.dateDesc:
        sortedFiles.sort((a, b) {
          if (a.uploadDate == null || b.uploadDate == null) return 0;
          return b.uploadDate!.compareTo(a.uploadDate!);
        });
    }

    return FileTransferState.sorting(order: order, files: sortedFiles);
  }

  // ============================================================================
  // DELETE QUEUE (Sequential) - Process deletions one at a time
  // ============================================================================

  /// Delete single file - sequential to ensure safe deletion
  @MonoEvent.queue(deleteQueue)
  Future<FileTransferState> _onDeleteFile(_Emitter emit, String fileId) async {
    emit(FileTransferState.deleting(fileIds: [fileId], files: _currentFiles));

    // Simulate deletion process
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final updatedFiles = _currentFiles.where((f) => f.id != fileId).toList();
    return FileTransferState.idle(files: updatedFiles);
  }

  /// Delete multiple files - sequential processing
  @MonoEvent.queue(deleteQueue)
  Future<FileTransferState> _onDeleteMultiple(
    _Emitter emit,
    List<String> fileIds,
  ) async {
    emit(FileTransferState.deleting(fileIds: fileIds, files: _currentFiles));

    // Simulate deleting each file
    for (final _ in fileIds) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }

    final updatedFiles = _currentFiles
        .where((f) => !fileIds.contains(f.id))
        .toList();
    return FileTransferState.idle(files: updatedFiles);
  }

  /// Empty trash - delete all files
  @MonoEvent.queue(deleteQueue)
  Future<FileTransferState> _onEmptyTrash(_Emitter emit) async {
    final allIds = _currentFiles.map((f) => f.id).toList();
    emit(FileTransferState.deleting(fileIds: allIds, files: _currentFiles));

    // Simulate emptying trash
    await Future<void>.delayed(const Duration(seconds: 1));

    return const FileTransferState.idle();
  }

  // ============================================================================
  // UTILITY EVENTS (No queue)
  // ============================================================================

  /// Clear search and return to idle
  @event
  FileTransferState _onClearSearch() {
    return FileTransferState.idle(files: _currentFiles);
  }

  /// Add a file to the list (for testing purposes)
  @event
  FileTransferState _onAddFile(FileItem file) {
    return FileTransferState.idle(files: [..._currentFiles, file]);
  }

  /// Clear all files
  @event
  FileTransferState _onClearFiles() {
    return const FileTransferState.idle();
  }

  /// Helper to get current file list from state
  List<FileItem> get _currentFiles {
    return state.when(
      idle: (files, _, _) => files,
      uploading: (_, files, _) => files,
      downloading: (_, files) => files,
      searching: (_, _) => [],
      refreshing: (files, _) => files,
      deleting: (_, files) => files,
      filtering: (_, _) => [],
      sorting: (_, files) => files,
      error: (_, files) => files,
    );
  }
}
