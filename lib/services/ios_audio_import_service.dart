import 'dart:io';

import 'package:file_picker/file_picker.dart' as fp;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class IosAudioImportService {
  static const Set<String> supportedExtensions = {
    'mp3',
    'm4a',
    'aac',
    'wav',
    'flac',
    'ogg',
    'opus',
  };

  /// Opens the iOS Files picker and copies selected audio files into
  /// Flute's private application directory.
  static Future<List<File>> importAudioFiles() async {
    if (!Platform.isIOS) {
      return const [];
    }

    final fp.FilePickerResult? result =
    await fp.FilePicker.pickFiles(
  type: fp.FileType.custom,
      allowedExtensions: supportedExtensions.toList(),
      allowMultiple: true,
      withData: false,
    );

    if (result == null || result.files.isEmpty) {
      return const [];
    }

    final documentsDirectory =
        await getApplicationDocumentsDirectory();

    final musicDirectory = Directory(
      path.join(documentsDirectory.path, 'Imported Music'),
    );

    if (!await musicDirectory.exists()) {
      await musicDirectory.create(recursive: true);
    }

    final importedFiles = <File>[];

    for (final selectedFile in result.files) {
      final sourcePath = selectedFile.path;

      if (sourcePath == null || sourcePath.isEmpty) {
        continue;
      }

      final sourceFile = File(sourcePath);

      if (!await sourceFile.exists()) {
        continue;
      }

      final extension = path
          .extension(selectedFile.name)
          .replaceFirst('.', '')
          .toLowerCase();

      if (!supportedExtensions.contains(extension)) {
        continue;
      }

      final destinationPath = await _uniqueDestinationPath(
        directory: musicDirectory,
        fileName: selectedFile.name,
      );

      final copiedFile = await sourceFile.copy(destinationPath);
      importedFiles.add(copiedFile);
    }

    return importedFiles;
  }

  static Future<List<File>> getImportedAudioFiles() async {
    if (!Platform.isIOS) {
      return const [];
    }

    final documentsDirectory =
        await getApplicationDocumentsDirectory();

    final musicDirectory = Directory(
      path.join(documentsDirectory.path, 'Imported Music'),
    );

    if (!await musicDirectory.exists()) {
      return const [];
    }

    final files = <File>[];

    await for (final entity in musicDirectory.list()) {
      if (entity is! File) {
        continue;
      }

      final extension = path
          .extension(entity.path)
          .replaceFirst('.', '')
          .toLowerCase();

      if (supportedExtensions.contains(extension)) {
        files.add(entity);
      }
    }

    files.sort(
      (first, second) => path
          .basename(first.path)
          .toLowerCase()
          .compareTo(path.basename(second.path).toLowerCase()),
    );

    return files;
  }

  static Future<void> deleteImportedFile(String filePath) async {
    if (!Platform.isIOS) {
      return;
    }

    final documentsDirectory =
        await getApplicationDocumentsDirectory();

    final musicDirectory = Directory(
      path.join(documentsDirectory.path, 'Imported Music'),
    );

    final normalizedMusicPath =
        path.normalize(musicDirectory.absolute.path);
    final normalizedFilePath =
        path.normalize(File(filePath).absolute.path);

    // Only allow deletion of files owned by Flute.
    if (!path.isWithin(normalizedMusicPath, normalizedFilePath)) {
      throw const FileSystemException(
        'Cannot delete files outside Flute storage.',
      );
    }

    final file = File(normalizedFilePath);

    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<String> _uniqueDestinationPath({
    required Directory directory,
    required String fileName,
  }) async {
    final safeFileName = path.basename(fileName);
    final baseName = path.basenameWithoutExtension(safeFileName);
    final extension = path.extension(safeFileName);

    var destinationPath = path.join(directory.path, safeFileName);
    var duplicateNumber = 1;

    while (await File(destinationPath).exists()) {
      destinationPath = path.join(
        directory.path,
        '$baseName ($duplicateNumber)$extension',
      );

      duplicateNumber++;
    }

    return destinationPath;
  }
}
