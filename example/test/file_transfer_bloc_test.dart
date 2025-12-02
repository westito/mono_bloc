import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mono_bloc_example/queue/file_transfer_bloc.dart';
import 'package:mono_bloc_example/queue/file_transfer_state.dart';

void main() {
  group('FileTransferBloc', () {
    late FileTransferBloc bloc;

    setUp(() {
      bloc = FileTransferBloc();
    });

    tearDown(() async {
      await bloc.close();
    });

    test('initial state is idle with empty files', () {
      expect(bloc.state, equals(const FileTransferState.idle()));
    });

    group('Sequential Upload Queue', () {
      blocTest<FileTransferBloc, FileTransferState>(
        'uploadFile processes one file at a time',
        build: () => bloc,
        act: (bloc) => bloc.uploadFile('document.pdf', 1000, FileType.document),
        expect: () => [
          isA<FileTransferUploading>(),
          isA<FileTransferUploading>(),
          isA<FileTransferUploading>(),
          isA<FileTransferUploading>(),
          isA<FileTransferUploading>(),
          isA<FileTransferUploading>(),
          isA<FileTransferUploading>(),
          isA<FileTransferUploading>(),
          isA<FileTransferUploading>(),
          isA<FileTransferUploading>(),
          isA<FileTransferUploading>(),
          isA<FileTransferIdle>(),
        ],
        wait: const Duration(seconds: 2),
        verify: (bloc) {
          bloc.state.when(
            idle: (files, _, _) {
              expect(files.length, equals(1));
              expect(files.first.name, equals('document.pdf'));
              expect(files.first.isComplete, isTrue);
            },
            uploading: (_, _, _) => fail('Should be idle after upload'),
            downloading: (_, _) => fail('Should be idle after upload'),
            searching: (_, _) => fail('Should be idle after upload'),
            refreshing: (_, _) => fail('Should be idle after upload'),
            deleting: (_, _) => fail('Should be idle after upload'),
            filtering: (_, _) => fail('Should be idle after upload'),
            sorting: (_, _) => fail('Should be idle after upload'),
            error: (_, _) => fail('Should be idle after upload'),
          );
        },
      );

      blocTest<FileTransferBloc, FileTransferState>(
        'multiple uploads process sequentially',
        build: () => bloc,
        act: (bloc) {
          bloc.uploadFile('file1.txt', 500, FileType.document);
          bloc.uploadFile('file2.txt', 500, FileType.document);
        },
        skip: 23,
        expect: () => [isA<FileTransferIdle>()],
        wait: const Duration(seconds: 3),
        verify: (bloc) {
          bloc.state.when(
            idle: (files, _, _) {
              expect(files.length, equals(2));
              expect(files[0].name, equals('file1.txt'));
              expect(files[1].name, equals('file2.txt'));
            },
            uploading: (_, _, _) => fail('Should be idle after all uploads'),
            downloading: (_, _) => fail('Should be idle after all uploads'),
            searching: (_, _) => fail('Should be idle after all uploads'),
            refreshing: (_, _) => fail('Should be idle after all uploads'),
            deleting: (_, _) => fail('Should be idle after all uploads'),
            filtering: (_, _) => fail('Should be idle after all uploads'),
            sorting: (_, _) => fail('Should be idle after all uploads'),
            error: (_, _) => fail('Should be idle after all uploads'),
          );
        },
      );

      blocTest<FileTransferBloc, FileTransferState>(
        'resumeUpload continues from where it left off',
        build: () => bloc,
        seed: () => const FileTransferState.idle(
          files: [
            FileItem(
              id: '1',
              name: 'paused.pdf',
              size: 1000,
              bytesTransferred: 500,
              isPaused: true,
            ),
          ],
        ),
        act: (bloc) => bloc.resumeUpload('1'),
        expect: () => [
          isA<FileTransferUploading>(),
          isA<FileTransferUploading>(),
          isA<FileTransferUploading>(),
          isA<FileTransferUploading>(),
          isA<FileTransferUploading>(),
          isA<FileTransferUploading>(),
          isA<FileTransferUploading>(),
          isA<FileTransferUploading>(),
          isA<FileTransferUploading>(),
          isA<FileTransferUploading>(),
          isA<FileTransferUploading>(),
          isA<FileTransferIdle>(),
        ],
        wait: const Duration(seconds: 2),
        verify: (bloc) {
          bloc.state.when(
            idle: (files, _, _) {
              expect(files.length, equals(1));
              expect(files.first.isComplete, isTrue);
              expect(files.first.isPaused, isFalse);
            },
            uploading: (_, _, _) => fail('Should be idle after resume'),
            downloading: (_, _) => fail('Should be idle after resume'),
            searching: (_, _) => fail('Should be idle after resume'),
            refreshing: (_, _) => fail('Should be idle after resume'),
            deleting: (_, _) => fail('Should be idle after resume'),
            filtering: (_, _) => fail('Should be idle after resume'),
            sorting: (_, _) => fail('Should be idle after resume'),
            error: (_, _) => fail('Should be idle after resume'),
          );
        },
      );

      blocTest<FileTransferBloc, FileTransferState>(
        'resumeUpload returns error for non-existent file',
        build: () => bloc,
        act: (bloc) => bloc.resumeUpload('non-existent'),
        expect: () => [isA<FileTransferError>()],
        verify: (bloc) {
          bloc.state.when(
            idle: (_, _, _) => fail('Should be error state'),
            uploading: (_, _, _) => fail('Should be error state'),
            downloading: (_, _) => fail('Should be error state'),
            searching: (_, _) => fail('Should be error state'),
            refreshing: (_, _) => fail('Should be error state'),
            deleting: (_, _) => fail('Should be error state'),
            filtering: (_, _) => fail('Should be error state'),
            sorting: (_, _) => fail('Should be error state'),
            error: (message, _) {
              expect(message, contains('Cannot resume'));
            },
          );
        },
      );

      blocTest<FileTransferBloc, FileTransferState>(
        'cancelUpload removes file from list',
        build: () => bloc,
        seed: () => const FileTransferState.idle(
          files: [
            FileItem(id: '1', name: 'to-cancel.pdf', size: 1000),
            FileItem(id: '2', name: 'keep.pdf', size: 2000),
          ],
        ),
        act: (bloc) => bloc.cancelUpload('1'),
        expect: () => [isA<FileTransferUploading>(), isA<FileTransferIdle>()],
        wait: const Duration(milliseconds: 500),
        verify: (bloc) {
          bloc.state.when(
            idle: (files, _, _) {
              expect(files.length, equals(1));
              expect(files.first.id, equals('2'));
            },
            uploading: (_, _, _) => fail('Should be idle after cancel'),
            downloading: (_, _) => fail('Should be idle after cancel'),
            searching: (_, _) => fail('Should be idle after cancel'),
            refreshing: (_, _) => fail('Should be idle after cancel'),
            deleting: (_, _) => fail('Should be idle after cancel'),
            filtering: (_, _) => fail('Should be idle after cancel'),
            sorting: (_, _) => fail('Should be idle after cancel'),
            error: (_, _) => fail('Should be idle after cancel'),
          );
        },
      );
    });

    group('Droppable Refresh Queue', () {
      blocTest<FileTransferBloc, FileTransferState>(
        'refreshFiles updates file list',
        build: () => bloc,
        act: (bloc) => bloc.refreshFiles(),
        expect: () => [isA<FileTransferRefreshing>(), isA<FileTransferIdle>()],
        wait: const Duration(seconds: 3),
      );

      blocTest<FileTransferBloc, FileTransferState>(
        'multiple refresh calls drop subsequent requests',
        build: () => bloc,
        act: (bloc) async {
          // Add a file first
          bloc.addFile(const FileItem(id: '1', name: 'test.txt', size: 100));
          await Future<void>.delayed(const Duration(milliseconds: 50));

          // Trigger multiple refreshes rapidly
          bloc.refreshFiles();
          await Future<void>.delayed(const Duration(milliseconds: 100));
          bloc.refreshFiles(); // Should be dropped
          await Future<void>.delayed(const Duration(milliseconds: 100));
          bloc.refreshFiles(); // Should be dropped
        },
        expect: () => [
          isA<FileTransferIdle>(), // addFile
          isA<FileTransferRefreshing>(), // First refresh starts
          isA<FileTransferIdle>(), // First refresh completes
          // No additional refresh states - subsequent calls were dropped
        ],
        wait: const Duration(seconds: 3),
      );

      blocTest<FileTransferBloc, FileTransferState>(
        'syncWithCloud syncs and adds new files',
        build: () => bloc,
        seed: () => const FileTransferState.idle(
          files: [FileItem(id: '1', name: 'existing.pdf', size: 1000)],
        ),
        act: (bloc) => bloc.syncWithCloud(),
        expect: () => [isA<FileTransferRefreshing>(), isA<FileTransferIdle>()],
        wait: const Duration(seconds: 2),
        verify: (bloc) {
          bloc.state.when(
            idle: (files, _, _) {
              expect(files.length, greaterThan(1));
              expect(files.any((f) => f.name == 'synced_file.pdf'), isTrue);
            },
            uploading: (_, _, _) => fail('Should be idle after sync'),
            downloading: (_, _) => fail('Should be idle after sync'),
            searching: (_, _) => fail('Should be idle after sync'),
            refreshing: (_, _) => fail('Should be idle after sync'),
            deleting: (_, _) => fail('Should be idle after sync'),
            filtering: (_, _) => fail('Should be idle after sync'),
            sorting: (_, _) => fail('Should be idle after sync'),
            error: (_, _) => fail('Should be idle after sync'),
          );
        },
      );

      blocTest<FileTransferBloc, FileTransferState>(
        'multiple syncWithCloud calls drop subsequent requests',
        build: () => bloc,
        act: (bloc) async {
          bloc.syncWithCloud();
          await Future<void>.delayed(const Duration(milliseconds: 100));
          bloc.syncWithCloud(); // Should be dropped
          bloc.syncWithCloud(); // Should be dropped
        },
        expect: () => [
          isA<FileTransferRefreshing>(),
          isA<FileTransferIdle>(),
          // No additional states - subsequent calls were dropped
        ],
        wait: const Duration(seconds: 2),
      );
    });

    group('Restartable Search Queue', () {
      blocTest<FileTransferBloc, FileTransferState>(
        'searchFiles filters files by query',
        build: () => bloc,
        seed: () => const FileTransferState.idle(
          files: [
            FileItem(id: '1', name: 'document.pdf', size: 100),
            FileItem(id: '2', name: 'image.png', size: 200),
            FileItem(id: '3', name: 'video.mp4', size: 300),
          ],
        ),
        act: (bloc) => bloc.searchFiles('doc'),
        expect: () => [isA<FileTransferSearching>()],
        wait: const Duration(seconds: 1),
        verify: (bloc) {
          bloc.state.when(
            idle: (_, _, _) => fail('Should be searching'),
            uploading: (_, _, _) => fail('Should be searching'),
            downloading: (_, _) => fail('Should be searching'),
            searching: (query, results) {
              expect(query, equals('doc'));
              expect(results.length, equals(1));
              expect(results.first.name, equals('document.pdf'));
            },
            refreshing: (_, _) => fail('Should be searching'),
            deleting: (_, _) => fail('Should be searching'),
            filtering: (_, _) => fail('Should be searching'),
            sorting: (_, _) => fail('Should be searching'),
            error: (_, _) => fail('Should be searching'),
          );
        },
      );

      blocTest<FileTransferBloc, FileTransferState>(
        'rapid searches restart previous search',
        build: () => bloc,
        seed: () => const FileTransferState.idle(
          files: [
            FileItem(id: '1', name: 'apple.txt', size: 100),
            FileItem(id: '2', name: 'apricot.txt', size: 200),
            FileItem(id: '3', name: 'banana.txt', size: 300),
          ],
        ),
        act: (bloc) async {
          bloc.searchFiles('app');
          await Future<void>.delayed(const Duration(milliseconds: 50));
          bloc.searchFiles('appl');
          await Future<void>.delayed(const Duration(milliseconds: 50));
          bloc.searchFiles('apple');
        },
        expect: () => [
          isA<FileTransferSearching>(), // Only the final search completes
        ],
        wait: const Duration(seconds: 1),
        verify: (bloc) {
          bloc.state.when(
            idle: (_, _, _) => fail('Should be searching'),
            uploading: (_, _, _) => fail('Should be searching'),
            downloading: (_, _) => fail('Should be searching'),
            searching: (query, results) {
              expect(query, equals('apple'));
              expect(results.length, equals(1));
              expect(results.first.name, equals('apple.txt'));
            },
            refreshing: (_, _) => fail('Should be searching'),
            deleting: (_, _) => fail('Should be searching'),
            filtering: (_, _) => fail('Should be searching'),
            sorting: (_, _) => fail('Should be searching'),
            error: (_, _) => fail('Should be searching'),
          );
        },
      );

      blocTest<FileTransferBloc, FileTransferState>(
        'filterByType filters by file type',
        build: () => bloc,
        seed: () => const FileTransferState.idle(
          files: [
            FileItem(
              id: '1',
              name: 'doc.pdf',
              size: 100,
              type: FileType.document,
            ),
            FileItem(id: '2', name: 'pic.png', size: 200, type: FileType.image),
            FileItem(id: '3', name: 'vid.mp4', size: 300, type: FileType.video),
            FileItem(
              id: '4',
              name: 'doc2.pdf',
              size: 150,
              type: FileType.document,
            ),
          ],
        ),
        act: (bloc) => bloc.filterByType(FileType.document),
        expect: () => [isA<FileTransferFiltering>()],
        wait: const Duration(milliseconds: 500),
        verify: (bloc) {
          bloc.state.when(
            idle: (_, _, _) => fail('Should be filtering'),
            uploading: (_, _, _) => fail('Should be filtering'),
            downloading: (_, _) => fail('Should be filtering'),
            searching: (_, _) => fail('Should be filtering'),
            refreshing: (_, _) => fail('Should be filtering'),
            deleting: (_, _) => fail('Should be filtering'),
            filtering: (type, results) {
              expect(type, equals(FileType.document));
              expect(results.length, equals(2));
              expect(results.every((f) => f.type == FileType.document), isTrue);
            },
            sorting: (_, _) => fail('Should be filtering'),
            error: (_, _) => fail('Should be filtering'),
          );
        },
      );

      blocTest<FileTransferBloc, FileTransferState>(
        'filterByType restarts on new filter',
        build: () => bloc,
        seed: () => const FileTransferState.idle(
          files: [
            FileItem(
              id: '1',
              name: 'doc.pdf',
              size: 100,
              type: FileType.document,
            ),
            FileItem(id: '2', name: 'pic.png', size: 200, type: FileType.image),
          ],
        ),
        act: (bloc) async {
          bloc.filterByType(FileType.document);
          await Future<void>.delayed(const Duration(milliseconds: 50));
          bloc.filterByType(FileType.image); // Restarts previous filter
        },
        expect: () => [
          isA<FileTransferFiltering>(), // Only the final filter completes
        ],
        wait: const Duration(milliseconds: 500),
        verify: (bloc) {
          bloc.state.when(
            idle: (_, _, _) => fail('Should be filtering'),
            uploading: (_, _, _) => fail('Should be filtering'),
            downloading: (_, _) => fail('Should be filtering'),
            searching: (_, _) => fail('Should be filtering'),
            refreshing: (_, _) => fail('Should be filtering'),
            deleting: (_, _) => fail('Should be filtering'),
            filtering: (type, results) {
              expect(type, equals(FileType.image));
              expect(results.length, equals(1));
            },
            sorting: (_, _) => fail('Should be filtering'),
            error: (_, _) => fail('Should be filtering'),
          );
        },
      );

      blocTest<FileTransferBloc, FileTransferState>(
        'sortFiles sorts by name ascending',
        build: () => bloc,
        seed: () => const FileTransferState.idle(
          files: [
            FileItem(id: '1', name: 'zebra.txt', size: 100),
            FileItem(id: '2', name: 'apple.txt', size: 200),
            FileItem(id: '3', name: 'banana.txt', size: 300),
          ],
        ),
        act: (bloc) => bloc.sortFiles(SortOrder.nameAsc),
        expect: () => [isA<FileTransferSorting>()],
        wait: const Duration(milliseconds: 300),
        verify: (bloc) {
          bloc.state.when(
            idle: (_, _, _) => fail('Should be sorting'),
            uploading: (_, _, _) => fail('Should be sorting'),
            downloading: (_, _) => fail('Should be sorting'),
            searching: (_, _) => fail('Should be sorting'),
            refreshing: (_, _) => fail('Should be sorting'),
            deleting: (_, _) => fail('Should be sorting'),
            filtering: (_, _) => fail('Should be sorting'),
            sorting: (order, files) {
              expect(order, equals(SortOrder.nameAsc));
              expect(files[0].name, equals('apple.txt'));
              expect(files[1].name, equals('banana.txt'));
              expect(files[2].name, equals('zebra.txt'));
            },
            error: (_, _) => fail('Should be sorting'),
          );
        },
      );

      blocTest<FileTransferBloc, FileTransferState>(
        'sortFiles sorts by size descending',
        build: () => bloc,
        seed: () => const FileTransferState.idle(
          files: [
            FileItem(id: '1', name: 'small.txt', size: 100),
            FileItem(id: '2', name: 'large.txt', size: 300),
            FileItem(id: '3', name: 'medium.txt', size: 200),
          ],
        ),
        act: (bloc) => bloc.sortFiles(SortOrder.sizeDesc),
        expect: () => [isA<FileTransferSorting>()],
        wait: const Duration(milliseconds: 300),
        verify: (bloc) {
          bloc.state.when(
            idle: (_, _, _) => fail('Should be sorting'),
            uploading: (_, _, _) => fail('Should be sorting'),
            downloading: (_, _) => fail('Should be sorting'),
            searching: (_, _) => fail('Should be sorting'),
            refreshing: (_, _) => fail('Should be sorting'),
            deleting: (_, _) => fail('Should be sorting'),
            filtering: (_, _) => fail('Should be sorting'),
            sorting: (order, files) {
              expect(order, equals(SortOrder.sizeDesc));
              expect(files[0].size, equals(300));
              expect(files[1].size, equals(200));
              expect(files[2].size, equals(100));
            },
            error: (_, _) => fail('Should be sorting'),
          );
        },
      );

      blocTest<FileTransferBloc, FileTransferState>(
        'sortFiles restarts on new sort',
        build: () => bloc,
        seed: () => const FileTransferState.idle(
          files: [
            FileItem(id: '1', name: 'b.txt', size: 200),
            FileItem(id: '2', name: 'a.txt', size: 100),
          ],
        ),
        act: (bloc) async {
          bloc.sortFiles(SortOrder.nameAsc);
          await Future<void>.delayed(const Duration(milliseconds: 50));
          bloc.sortFiles(SortOrder.sizeDesc); // Restarts previous sort
        },
        expect: () => [
          isA<FileTransferSorting>(), // Only the final sort completes
        ],
        wait: const Duration(milliseconds: 300),
        verify: (bloc) {
          bloc.state.when(
            idle: (_, _, _) => fail('Should be sorting'),
            uploading: (_, _, _) => fail('Should be sorting'),
            downloading: (_, _) => fail('Should be sorting'),
            searching: (_, _) => fail('Should be sorting'),
            refreshing: (_, _) => fail('Should be sorting'),
            deleting: (_, _) => fail('Should be sorting'),
            filtering: (_, _) => fail('Should be sorting'),
            sorting: (order, files) {
              expect(order, equals(SortOrder.sizeDesc));
            },
            error: (_, _) => fail('Should be sorting'),
          );
        },
      );
    });

    group('Concurrent Download Queue', () {
      blocTest<FileTransferBloc, FileTransferState>(
        'downloadFile processes single file',
        build: () => bloc,
        seed: () => const FileTransferState.idle(
          files: [FileItem(id: '1', name: 'file.zip', size: 1000)],
        ),
        act: (bloc) => bloc.downloadFile('1'),
        expect: () => [
          isA<FileTransferDownloading>(),
          isA<FileTransferDownloading>(),
          isA<FileTransferDownloading>(),
          isA<FileTransferDownloading>(),
          isA<FileTransferDownloading>(),
          isA<FileTransferDownloading>(),
          isA<FileTransferIdle>(),
        ],
        wait: const Duration(seconds: 2),
      );

      blocTest<FileTransferBloc, FileTransferState>(
        'downloadFile returns error for unknown file',
        build: () => bloc,
        seed: () => const FileTransferState.idle(),
        act: (bloc) => bloc.downloadFile('unknown'),
        expect: () => [isA<FileTransferError>()],
        verify: (bloc) {
          bloc.state.when(
            idle: (_, _, _) => fail('Should be error state'),
            uploading: (_, _, _) => fail('Should be error state'),
            downloading: (_, _) => fail('Should be error state'),
            searching: (_, _) => fail('Should be error state'),
            refreshing: (_, _) => fail('Should be error state'),
            deleting: (_, _) => fail('Should be error state'),
            filtering: (_, _) => fail('Should be error state'),
            sorting: (_, _) => fail('Should be error state'),
            error: (message, _) {
              expect(message, equals('File not found'));
            },
          );
        },
      );

      blocTest<FileTransferBloc, FileTransferState>(
        'downloadMultiple downloads multiple files',
        build: () => bloc,
        seed: () => const FileTransferState.idle(
          files: [
            FileItem(id: '1', name: 'file1.pdf', size: 1000),
            FileItem(id: '2', name: 'file2.pdf', size: 2000),
            FileItem(id: '3', name: 'file3.pdf', size: 3000),
          ],
        ),
        act: (bloc) => bloc.downloadMultiple(['1', '2']),
        expect: () => [
          isA<FileTransferDownloading>(),
          isA<FileTransferDownloading>(),
          isA<FileTransferDownloading>(),
          isA<FileTransferDownloading>(),
          isA<FileTransferDownloading>(),
          isA<FileTransferDownloading>(),
          isA<FileTransferIdle>(),
        ],
        wait: const Duration(seconds: 2),
        verify: (bloc) {
          bloc.state.when(
            idle: (files, _, _) {
              expect(files.length, equals(3));
            },
            uploading: (_, _, _) => fail('Should be idle after downloads'),
            downloading: (_, _) => fail('Should be idle after downloads'),
            searching: (_, _) => fail('Should be idle after downloads'),
            refreshing: (_, _) => fail('Should be idle after downloads'),
            deleting: (_, _) => fail('Should be idle after downloads'),
            filtering: (_, _) => fail('Should be idle after downloads'),
            sorting: (_, _) => fail('Should be idle after downloads'),
            error: (_, _) => fail('Should be idle after downloads'),
          );
        },
      );

      blocTest<FileTransferBloc, FileTransferState>(
        'downloadMultiple returns error for empty list',
        build: () => bloc,
        seed: () => const FileTransferState.idle(),
        act: (bloc) => bloc.downloadMultiple(['1', '2']),
        expect: () => [isA<FileTransferError>()],
        verify: (bloc) {
          bloc.state.when(
            idle: (_, _, _) => fail('Should be error state'),
            uploading: (_, _, _) => fail('Should be error state'),
            downloading: (_, _) => fail('Should be error state'),
            searching: (_, _) => fail('Should be error state'),
            refreshing: (_, _) => fail('Should be error state'),
            deleting: (_, _) => fail('Should be error state'),
            filtering: (_, _) => fail('Should be error state'),
            sorting: (_, _) => fail('Should be error state'),
            error: (message, _) {
              expect(message, equals('No files found to download'));
            },
          );
        },
      );

      blocTest<FileTransferBloc, FileTransferState>(
        'pauseDownload marks file as paused',
        build: () => bloc,
        seed: () => const FileTransferState.idle(
          files: [FileItem(id: '1', name: 'downloading.pdf', size: 1000)],
        ),
        act: (bloc) => bloc.pauseDownload('1'),
        wait: const Duration(milliseconds: 200),
        expect: () => [isA<FileTransferIdle>()],
        verify: (bloc) {
          bloc.state.when(
            idle: (files, _, _) {
              expect(files.first.isPaused, isTrue);
            },
            uploading: (_, _, _) => fail('Should be idle'),
            downloading: (_, _) => fail('Should be idle'),
            searching: (_, _) => fail('Should be idle'),
            refreshing: (_, _) => fail('Should be idle'),
            deleting: (_, _) => fail('Should be idle'),
            filtering: (_, _) => fail('Should be idle'),
            sorting: (_, _) => fail('Should be idle'),
            error: (_, _) => fail('Should be idle'),
          );
        },
      );
    });

    group('Utility Events', () {
      blocTest<FileTransferBloc, FileTransferState>(
        'clearSearch returns to idle state',
        build: () => bloc,
        seed: () => const FileTransferState.searching(query: 'test'),
        act: (bloc) => bloc.clearSearch(),
        expect: () => [isA<FileTransferIdle>()],
      );

      blocTest<FileTransferBloc, FileTransferState>(
        'addFile adds file to list',
        build: () => bloc,
        act: (bloc) =>
            bloc.addFile(const FileItem(id: '1', name: 'new.txt', size: 500)),
        expect: () => [isA<FileTransferIdle>()],
        verify: (bloc) {
          bloc.state.when(
            idle: (files, _, _) {
              expect(files.length, equals(1));
              expect(files.first.name, equals('new.txt'));
            },
            uploading: (_, _, _) => fail('Should be idle'),
            downloading: (_, _) => fail('Should be idle'),
            searching: (_, _) => fail('Should be idle'),
            refreshing: (_, _) => fail('Should be idle'),
            deleting: (_, _) => fail('Should be idle'),
            filtering: (_, _) => fail('Should be idle'),
            sorting: (_, _) => fail('Should be idle'),
            error: (_, _) => fail('Should be idle'),
          );
        },
      );

      blocTest<FileTransferBloc, FileTransferState>(
        'clearFiles removes all files',
        build: () => bloc,
        seed: () => const FileTransferState.idle(
          files: [
            FileItem(id: '1', name: 'file1.txt', size: 100),
            FileItem(id: '2', name: 'file2.txt', size: 200),
          ],
        ),
        act: (bloc) => bloc.clearFiles(),
        expect: () => [isA<FileTransferIdle>()],
        verify: (bloc) {
          bloc.state.when(
            idle: (files, _, _) => expect(files, isEmpty),
            uploading: (_, _, _) => fail('Should be idle'),
            downloading: (_, _) => fail('Should be idle'),
            searching: (_, _) => fail('Should be idle'),
            refreshing: (_, _) => fail('Should be idle'),
            deleting: (_, _) => fail('Should be idle'),
            filtering: (_, _) => fail('Should be idle'),
            sorting: (_, _) => fail('Should be idle'),
            error: (_, _) => fail('Should be idle'),
          );
        },
      );
    });

    group('Delete Queue (Sequential)', () {
      blocTest<FileTransferBloc, FileTransferState>(
        'deleteFile removes single file',
        build: () => bloc,
        seed: () => const FileTransferState.idle(
          files: [
            FileItem(id: '1', name: 'to-delete.pdf', size: 1000),
            FileItem(id: '2', name: 'keep.pdf', size: 2000),
          ],
        ),
        act: (bloc) => bloc.deleteFile('1'),
        expect: () => [isA<FileTransferDeleting>(), isA<FileTransferIdle>()],
        wait: const Duration(milliseconds: 700),
        verify: (bloc) {
          bloc.state.when(
            idle: (files, _, _) {
              expect(files.length, equals(1));
              expect(files.first.id, equals('2'));
            },
            uploading: (_, _, _) => fail('Should be idle after delete'),
            downloading: (_, _) => fail('Should be idle after delete'),
            searching: (_, _) => fail('Should be idle after delete'),
            refreshing: (_, _) => fail('Should be idle after delete'),
            deleting: (_, _) => fail('Should be idle after delete'),
            filtering: (_, _) => fail('Should be idle after delete'),
            sorting: (_, _) => fail('Should be idle after delete'),
            error: (_, _) => fail('Should be idle after delete'),
          );
        },
      );

      blocTest<FileTransferBloc, FileTransferState>(
        'deleteMultiple removes multiple files',
        build: () => bloc,
        seed: () => const FileTransferState.idle(
          files: [
            FileItem(id: '1', name: 'delete1.pdf', size: 1000),
            FileItem(id: '2', name: 'delete2.pdf', size: 2000),
            FileItem(id: '3', name: 'keep.pdf', size: 3000),
          ],
        ),
        act: (bloc) => bloc.deleteMultiple(['1', '2']),
        expect: () => [isA<FileTransferDeleting>(), isA<FileTransferIdle>()],
        wait: const Duration(milliseconds: 800),
        verify: (bloc) {
          bloc.state.when(
            idle: (files, _, _) {
              expect(files.length, equals(1));
              expect(files.first.id, equals('3'));
            },
            uploading: (_, _, _) => fail('Should be idle after delete'),
            downloading: (_, _) => fail('Should be idle after delete'),
            searching: (_, _) => fail('Should be idle after delete'),
            refreshing: (_, _) => fail('Should be idle after delete'),
            deleting: (_, _) => fail('Should be idle after delete'),
            filtering: (_, _) => fail('Should be idle after delete'),
            sorting: (_, _) => fail('Should be idle after delete'),
            error: (_, _) => fail('Should be idle after delete'),
          );
        },
      );

      blocTest<FileTransferBloc, FileTransferState>(
        'emptyTrash removes all files',
        build: () => bloc,
        seed: () => const FileTransferState.idle(
          files: [
            FileItem(id: '1', name: 'file1.pdf', size: 1000),
            FileItem(id: '2', name: 'file2.pdf', size: 2000),
            FileItem(id: '3', name: 'file3.pdf', size: 3000),
          ],
        ),
        act: (bloc) => bloc.emptyTrash(),
        expect: () => [isA<FileTransferDeleting>(), isA<FileTransferIdle>()],
        wait: const Duration(seconds: 2),
        verify: (bloc) {
          bloc.state.when(
            idle: (files, _, _) {
              expect(files, isEmpty);
            },
            uploading: (_, _, _) => fail('Should be idle after empty trash'),
            downloading: (_, _) => fail('Should be idle after empty trash'),
            searching: (_, _) => fail('Should be idle after empty trash'),
            refreshing: (_, _) => fail('Should be idle after empty trash'),
            deleting: (_, _) => fail('Should be idle after empty trash'),
            filtering: (_, _) => fail('Should be idle after empty trash'),
            sorting: (_, _) => fail('Should be idle after empty trash'),
            error: (_, _) => fail('Should be idle after empty trash'),
          );
        },
      );

      blocTest<FileTransferBloc, FileTransferState>(
        'multiple deletes are processed sequentially',
        build: () => bloc,
        seed: () => const FileTransferState.idle(
          files: [
            FileItem(id: '1', name: 'file1.pdf', size: 1000),
            FileItem(id: '2', name: 'file2.pdf', size: 2000),
            FileItem(id: '3', name: 'file3.pdf', size: 3000),
          ],
        ),
        act: (bloc) {
          bloc.deleteFile('1');
          bloc.deleteFile('2');
          bloc.deleteFile('3');
        },
        skip: 5,
        expect: () => [isA<FileTransferIdle>()],
        wait: const Duration(seconds: 2),
        verify: (bloc) {
          bloc.state.when(
            idle: (files, _, _) {
              expect(files, isEmpty);
            },
            uploading: (_, _, _) => fail('Should be idle after all deletes'),
            downloading: (_, _) => fail('Should be idle after all deletes'),
            searching: (_, _) => fail('Should be idle after all deletes'),
            refreshing: (_, _) => fail('Should be idle after all deletes'),
            deleting: (_, _) => fail('Should be idle after all deletes'),
            filtering: (_, _) => fail('Should be idle after all deletes'),
            sorting: (_, _) => fail('Should be idle after all deletes'),
            error: (_, _) => fail('Should be idle after all deletes'),
          );
        },
      );
    });

    group('FileItem', () {
      test('progress calculates correctly', () {
        const file = FileItem(
          id: '1',
          name: 'test.txt',
          size: 1000,
          bytesTransferred: 500,
        );
        expect(file.progress, equals(0.5));
      });

      test('progress is 0 for 0 size file', () {
        const file = FileItem(id: '1', name: 'test.txt', size: 0);
        expect(file.progress, equals(0.0));
      });

      test('isComplete returns true when fully transferred', () {
        const file = FileItem(
          id: '1',
          name: 'test.txt',
          size: 1000,
          bytesTransferred: 1000,
        );
        expect(file.isComplete, isTrue);
      });

      test('isComplete returns false when partially transferred', () {
        const file = FileItem(
          id: '1',
          name: 'test.txt',
          size: 1000,
          bytesTransferred: 500,
        );
        expect(file.isComplete, isFalse);
      });
    });
  });
}
