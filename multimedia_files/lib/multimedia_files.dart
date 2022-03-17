library multimedia_files;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'enums/enums.dart';

class ExtendedMethodsMultimedia {
  static Future<Color> dominantColorFromUrl({
    required String path,
    required UrlType urlType,
  }) async {
    try {
      switch (urlType) {
        case UrlType.video:
          final pathFile = (await VideoThumbnail.thumbnailFile(
            video: path,
            thumbnailPath: (await getTemporaryDirectory()).path,
            imageFormat: path.contains('.jpg') || path.contains('.JPG')
                ? ImageFormat.JPEG
                : path.contains('.png') || path.contains('.PNG')
                    ? ImageFormat.PNG
                    : ImageFormat.JPEG,
            maxHeight: 64,
            quality: 100,
          ));
          pathFile == null ? throw Exception('thumbnail image error') : null;

          return dominantColorFromImageProvider(
            imageProvider: AssetImage(pathFile),
          );

        case UrlType.image:
          return await dominantColorFromImageProvider(
              imageProvider: NetworkImage(path));

        default:
          return Colors.white;
      }
    } catch (e) {
      if (kDebugMode) {
        print('backgroundColorFromUrl => $e');
      }
      return Colors.white;
    }
  }

  static Future<Image?> thumbnailFromVideoUrl({
    required String videoUrl,
  }) async {
    try {
      final pathFile = (await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 64,
        quality: 100,
      ));
      pathFile == null ? throw Exception('thumbnail image error') : null;
      return Image.asset(pathFile);
    } catch (e) {
      if (kDebugMode) {
        print('thumbnailFromVideoUrl => $e');
      }
      return null;
    }
  }

  static Future<Color> dominantColorFromImageProvider(
      {required ImageProvider imageProvider}) async {
    return (await PaletteGenerator.fromImageProvider(imageProvider))
            .dominantColor
            ?.color ??
        Colors.white;
  }
}
