import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:infinite_image_gallery/features/gallery/data/models/pixabay_image.dart';

enum DownloadStatus { initial, downloading, success, error }

class DownloadState {
  final DownloadStatus status;
  final double progress;
  final String? errorMessage;
  final String? savedFilePath;

  const DownloadState({
    this.status = DownloadStatus.initial,
    this.progress = 0.0,
    this.errorMessage,
    this.savedFilePath,
  });

  DownloadState copyWith({
    DownloadStatus? status,
    double? progress,
    String? errorMessage,
    String? savedFilePath,
  }) {
    return DownloadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage,
      savedFilePath: savedFilePath ?? this.savedFilePath,
    );
  }
}

final downloadNotifierProvider =
    NotifierProvider<DownloadNotifier, DownloadState>(DownloadNotifier.new);

class DownloadNotifier extends Notifier<DownloadState> {
  CancelToken? _cancelToken;

  @override
  DownloadState build() {
    return const DownloadState();
  }

  Future<void> downloadAndSaveImage(PixabayImage image) async {
    if (state.status == DownloadStatus.downloading) return;

    state = const DownloadState(
      status: DownloadStatus.downloading,
      progress: 0.05,
    );

    _cancelToken = CancelToken();

    try {
      // 1. Request Gallery Access Permission via Gal
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final requested = await Gal.requestAccess();
        if (!requested) {
          state = state.copyWith(
            status: DownloadStatus.error,
            errorMessage: 'Storage permission denied. Please enable photo access in settings.',
          );
          return;
        }
      }

      // 2. Prepare temporary file path
      final tempDir = await getTemporaryDirectory();
      final fileName = 'pixabay_${image.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savePath = '${tempDir.path}/$fileName';

      // 3. Download high-res image with progress tracking
      final dio = Dio();
      final downloadUrl = image.largeImageURL.isNotEmpty ? image.largeImageURL : image.webformatURL;

      await dio.download(
        downloadUrl,
        savePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = (received / total).clamp(0.05, 0.95);
            state = state.copyWith(progress: progress);
          }
        },
      );

      // 4. Save downloaded file directly to device Photo Gallery using Gal
      await Gal.putImage(savePath);

      state = state.copyWith(
        status: DownloadStatus.success,
        progress: 1.0,
        savedFilePath: savePath,
      );

      // Clean up temporary file
      final tempFile = File(savePath);
      if (await tempFile.exists()) {
        await tempFile.delete().catchError((_) => tempFile);
      }
    } on GalException catch (e) {
      state = state.copyWith(
        status: DownloadStatus.error,
        errorMessage: 'Failed to save to gallery: ${e.type.message}',
      );
    } catch (e) {
      state = state.copyWith(
        status: DownloadStatus.error,
        errorMessage: 'Download failed: $e',
      );
    }
  }

  void cancelDownload() {
    _cancelToken?.cancel('Cancelled by user');
    state = const DownloadState(status: DownloadStatus.initial);
  }

  void reset() {
    state = const DownloadState(status: DownloadStatus.initial);
  }
}
