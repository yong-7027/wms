import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/helpers/video_helper.dart';

class MediaViewerController extends GetxController {
  // dynamic type, because maybe used when requesting refund (File type) or when displaying request details (String type)
  final RxList<dynamic> mediaItems;
  final int initialIndex;
  final bool isLocalFiles; // 标记是否是本地文件
  late PageController pageController;
  var currentIndex = 0.obs;

  MediaViewerController({
    required List<dynamic> items,
    required this.initialIndex,
    required this.isLocalFiles,
  }) : mediaItems = items.obs {
    pageController = PageController(initialPage: initialIndex);
    currentIndex.value = initialIndex;
  }

  // 判断是否是视频文件
  bool isVideoFile(dynamic mediaItem) {
    String filePath;

    if (mediaItem is File) {
      filePath = mediaItem.path;
    } else if (mediaItem is String) {
      filePath = mediaItem;
    } else {
      return false;
    }

    return VideoHelper.isVideoFile(filePath);
  }

  // 获取媒体URL（如果是网络URL）或路径（如果是本地文件）
  String getMediaPath(dynamic mediaItem) {
    if (mediaItem is File) {
      return mediaItem.path;
    } else if (mediaItem is String) {
      return mediaItem;
    }
    return '';
  }

  // 检查是否是本地文件
  bool isLocalFile(dynamic mediaItem) {
    return mediaItem is File;
  }

  void deleteCurrentMedia() {
    if (!isLocalFiles) {
      // 如果是网络URL，不允许删除
      return;
    }

    final indexToDelete = currentIndex.value;

    // 从列表中删除当前文件
    mediaItems.removeAt(indexToDelete);

    if (mediaItems.isEmpty) {
      // 如果所有媒体都被删除，返回结果并退出
      Get.back(result: {
        'deleteIndex': indexToDelete,
        'remainingFiles': <File>[]
      });
    } else {
      // 还有剩余文件，更新当前索引但不退出
      int newIndex = currentIndex.value;

      // 如果删除的是最后一个文件，移动到前一个
      if (currentIndex.value >= mediaItems.length) {
        newIndex = mediaItems.length - 1;
      }

      // 更新当前索引
      currentIndex.value = newIndex;

      // 跳转到新的页面
      pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  // 当MediaViewerScreen关闭时，返回最终的文件列表
  void onScreenClose() {
    if (isLocalFiles) {
      Get.back(result: {
        'remainingFiles': mediaItems.whereType<File>().toList(),
      });
    } else {
      Get.back();
    }
  }
}