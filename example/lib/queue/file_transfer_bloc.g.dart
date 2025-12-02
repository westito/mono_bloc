// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_transfer_bloc.dart';

// **************************************************************************
// MonoBlocGenerator
// **************************************************************************

// ignore_for_file: unused_element, prefer_foreach, library_private_types_in_public_api, always_put_control_body_on_new_line, invalid_use_of_protected_member, avoid_annotating_with_dynamic, avoid_futureor_void

typedef _Emitter = Emitter<FileTransferState>;

abstract class _Event {
  _Event() : trace = StackTrace.current;

  final StackTrace trace;
}

class _$UploadQueueEvent extends _Event {}

class _$DownloadQueueEvent extends _Event {}

class _$RefreshQueueEvent extends _Event {}

class _$SearchQueueEvent extends _Event {}

class _$DeleteQueueEvent extends _Event {}

class _UploadFileEvent extends _$UploadQueueEvent {
  _UploadFileEvent(this.fileName, this.fileSize, this.type);

  final String fileName;

  final int fileSize;

  final FileType type;
}

class _ResumeUploadEvent extends _$UploadQueueEvent {
  _ResumeUploadEvent(this.fileId);

  final String fileId;
}

class _CancelUploadEvent extends _$UploadQueueEvent {
  _CancelUploadEvent(this.fileId);

  final String fileId;
}

class _DownloadFileEvent extends _$DownloadQueueEvent {
  _DownloadFileEvent(this.fileId);

  final String fileId;
}

class _DownloadMultipleEvent extends _$DownloadQueueEvent {
  _DownloadMultipleEvent(this.fileIds);

  final List<String> fileIds;
}

class _PauseDownloadEvent extends _$DownloadQueueEvent {
  _PauseDownloadEvent(this.fileId);

  final String fileId;
}

class _RefreshFilesEvent extends _$RefreshQueueEvent {
  _RefreshFilesEvent();
}

class _SyncWithCloudEvent extends _$RefreshQueueEvent {
  _SyncWithCloudEvent();
}

class _SearchFilesEvent extends _$SearchQueueEvent {
  _SearchFilesEvent(this.query);

  final String query;
}

class _FilterByTypeEvent extends _$SearchQueueEvent {
  _FilterByTypeEvent(this.type);

  final FileType type;
}

class _SortFilesEvent extends _$SearchQueueEvent {
  _SortFilesEvent(this.order);

  final SortOrder order;
}

class _DeleteFileEvent extends _$DeleteQueueEvent {
  _DeleteFileEvent(this.fileId);

  final String fileId;
}

class _DeleteMultipleEvent extends _$DeleteQueueEvent {
  _DeleteMultipleEvent(this.fileIds);

  final List<String> fileIds;
}

class _EmptyTrashEvent extends _$DeleteQueueEvent {
  _EmptyTrashEvent();
}

class _ClearSearchEvent extends _Event {
  _ClearSearchEvent();
}

class _AddFileEvent extends _Event {
  _AddFileEvent(this.file);

  final FileItem file;
}

class _ClearFilesEvent extends _Event {
  _ClearFilesEvent();
}

abstract class _$FileTransferBloc<_> extends Bloc<_Event, FileTransferState> {
  _$FileTransferBloc(
    super.initialState, {
    Map<String, EventTransformer<dynamic>>? queues,
  }) : _queues = queues ?? const {} {
    _$(this)._$init();
  }

  final Map<String, EventTransformer<dynamic>> _queues;

  EventTransformer<E>? _getTransformer<E>(String queueName) {
    final $ = _$(this);
    assert(
      _queues.containsKey(queueName),
      'Queue "$queueName" does not exist. Add it in super constructor queues parameter.',
    );
    final transformer = _queues[queueName];
    if (transformer == null) return null;
    return $._castTransformer<E>(transformer);
  }

  /// [FileTransferBloc._onUploadFile]
  void uploadFile(String fileName, int fileSize, FileType type) {
    add(_UploadFileEvent(fileName, fileSize, type));
  }

  /// [FileTransferBloc._onResumeUpload]
  void resumeUpload(String fileId) {
    add(_ResumeUploadEvent(fileId));
  }

  /// [FileTransferBloc._onCancelUpload]
  void cancelUpload(String fileId) {
    add(_CancelUploadEvent(fileId));
  }

  /// [FileTransferBloc._onDownloadFile]
  void downloadFile(String fileId) {
    add(_DownloadFileEvent(fileId));
  }

  /// [FileTransferBloc._onDownloadMultiple]
  void downloadMultiple(List<String> fileIds) {
    add(_DownloadMultipleEvent(fileIds));
  }

  /// [FileTransferBloc._onPauseDownload]
  void pauseDownload(String fileId) {
    add(_PauseDownloadEvent(fileId));
  }

  /// [FileTransferBloc._onRefreshFiles]
  void refreshFiles() {
    add(_RefreshFilesEvent());
  }

  /// [FileTransferBloc._onSyncWithCloud]
  void syncWithCloud() {
    add(_SyncWithCloudEvent());
  }

  /// [FileTransferBloc._onSearchFiles]
  void searchFiles(String query) {
    add(_SearchFilesEvent(query));
  }

  /// [FileTransferBloc._onFilterByType]
  void filterByType(FileType type) {
    add(_FilterByTypeEvent(type));
  }

  /// [FileTransferBloc._onSortFiles]
  void sortFiles(SortOrder order) {
    add(_SortFilesEvent(order));
  }

  /// [FileTransferBloc._onDeleteFile]
  void deleteFile(String fileId) {
    add(_DeleteFileEvent(fileId));
  }

  /// [FileTransferBloc._onDeleteMultiple]
  void deleteMultiple(List<String> fileIds) {
    add(_DeleteMultipleEvent(fileIds));
  }

  /// [FileTransferBloc._onEmptyTrash]
  void emptyTrash() {
    add(_EmptyTrashEvent());
  }

  /// [FileTransferBloc._onClearSearch]
  void clearSearch() {
    add(_ClearSearchEvent());
  }

  /// [FileTransferBloc._onAddFile]
  void addFile(FileItem file) {
    add(_AddFileEvent(file));
  }

  /// [FileTransferBloc._onClearFiles]
  void clearFiles() {
    add(_ClearFilesEvent());
  }

  @override
  @protected
  void add(_Event event) {
    if (isClosed) {
      return;
    }
    super.add(event);
  }

  @override
  @protected
  void on<E extends _Event>(
    EventHandler<E, FileTransferState> handler, {
    EventTransformer<E>? transformer,
  }) {
    super.on<E>(handler, transformer: transformer);
  }
}

extension type _$._(FileTransferBloc bloc) implements FileTransferBloc {
  _$(_$FileTransferBloc<dynamic> base) : bloc = base as FileTransferBloc;

  EventTransformer<E> _castTransformer<E>(
    EventTransformer<dynamic> transformer,
  ) {
    return (events, mapper) => transformer(
      events.cast<dynamic>(),
      (event) => mapper(event as E).cast<dynamic>(),
    ).cast<E>();
  }

  void _$init() {
    bloc.on<_$UploadQueueEvent>((event, emit) async {
      if (event is _UploadFileEvent) {
        try {
          emit(
            await _onUploadFile(
              emit,
              event.fileName,
              event.fileSize,
              event.type,
            ),
          );
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      } else if (event is _ResumeUploadEvent) {
        try {
          emit(await _onResumeUpload(emit, event.fileId));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      } else if (event is _CancelUploadEvent) {
        try {
          emit(await _onCancelUpload(emit, event.fileId));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      }
    }, transformer: bloc._getTransformer<_$UploadQueueEvent>('upload'));
    bloc.on<_$DownloadQueueEvent>((event, emit) async {
      if (event is _DownloadFileEvent) {
        try {
          emit(await _onDownloadFile(emit, event.fileId));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      } else if (event is _DownloadMultipleEvent) {
        try {
          emit(await _onDownloadMultiple(emit, event.fileIds));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      } else if (event is _PauseDownloadEvent) {
        try {
          emit(await _onPauseDownload(event.fileId));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      }
    }, transformer: bloc._getTransformer<_$DownloadQueueEvent>('download'));
    bloc.on<_$RefreshQueueEvent>((event, emit) async {
      if (event is _RefreshFilesEvent) {
        try {
          emit(await _onRefreshFiles(emit));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      } else if (event is _SyncWithCloudEvent) {
        try {
          emit(await _onSyncWithCloud(emit));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      }
    }, transformer: bloc._getTransformer<_$RefreshQueueEvent>('refresh'));
    bloc.on<_$SearchQueueEvent>((event, emit) async {
      if (event is _SearchFilesEvent) {
        try {
          emit(await _onSearchFiles(event.query));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      } else if (event is _FilterByTypeEvent) {
        try {
          emit(await _onFilterByType(event.type));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      } else if (event is _SortFilesEvent) {
        try {
          emit(await _onSortFiles(event.order));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      }
    }, transformer: bloc._getTransformer<_$SearchQueueEvent>('search'));
    bloc.on<_$DeleteQueueEvent>((event, emit) async {
      if (event is _DeleteFileEvent) {
        try {
          emit(await _onDeleteFile(emit, event.fileId));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      } else if (event is _DeleteMultipleEvent) {
        try {
          emit(await _onDeleteMultiple(emit, event.fileIds));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      } else if (event is _EmptyTrashEvent) {
        try {
          emit(await _onEmptyTrash(emit));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      }
    }, transformer: bloc._getTransformer<_$DeleteQueueEvent>('delete'));
    bloc.on<_ClearSearchEvent>((event, emit) {
      try {
        emit(_onClearSearch());
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
    bloc.on<_AddFileEvent>((event, emit) {
      try {
        emit(_onAddFile(event.file));
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
    bloc.on<_ClearFilesEvent>((event, emit) {
      try {
        emit(_onClearFiles());
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
  }

  static StackTrace _$stack(StackTrace origin, StackTrace trace) {
    return MonoStackTrace.filtered(origin, trace, 'file_transfer_bloc.g.dart');
  }
}
