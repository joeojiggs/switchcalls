enum FileType { image, file, contacts, location }

class FileUtils {
  static String fileTypeToString(FileType type) {
    switch (type) {
      case FileType.image:
        return 'image';
      case FileType.file:
        return 'file';
      case FileType.contacts:
        return 'contacts';
      case FileType.location:
        return 'location';
      default:
        return 'image';
    }
  }
  static FileType stringToFileType(String value) {
    switch (value) {
      case 'image':
        return FileType.image;
      case 'file':
        return FileType.file;
      case 'contacts':
        return FileType.contacts;
      case 'location':
        return FileType.location;
      default:
        return FileType.image;
    }
  }
}
