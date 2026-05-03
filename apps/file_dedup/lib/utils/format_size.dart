/// File size formatting utility
library;

/// Format file size in human-readable format
String formatSize(int sizeBytes) {
  if (sizeBytes == 0) return '0 B';
  if (sizeBytes < 1024) return '$sizeBytes B';
  if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
  if (sizeBytes < 1024 * 1024 * 1024) {
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}
