class VideoHelper {
  VideoHelper._();

  // 检查是否为视频文件
  static bool isVideoFile(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.mp4') ||
        lowerUrl.contains('.mov') ||
        lowerUrl.contains('.avi') ||
        lowerUrl.contains('.mkv') ||
        lowerUrl.contains('.wmv') ||
        lowerUrl.contains('.flv') ||
        lowerUrl.contains('.3gp') ||
        lowerUrl.contains('video');
  }
}
