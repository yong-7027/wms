import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../utils/constants/colors.dart';
import '../../controllers/media_viewer_controller.dart';

class MediaViewerScreen extends StatelessWidget {
  const MediaViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final mediaItems = args['mediaItems'] as List<dynamic>; // 改为 dynamic
    final initialIndex = args['initialIndex'] as int? ?? 0;
    final isLocalFiles = args['isLocalFiles'] as bool? ?? true; // 默认为本地文件

    final controller = Get.put(MediaViewerController(
      items: mediaItems,
      initialIndex: initialIndex,
      isLocalFiles: isLocalFiles,
    ));

    return WillPopScope(
      onWillPop: () async {
        controller.onScreenClose();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => controller.onScreenClose(),
          ),
          title: Obx(() => Text(
            '${controller.currentIndex.value + 1} of ${controller.mediaItems.length}',
            style: const TextStyle(color: Colors.white),
          )),
          actions: [
            // 只在本地文件且还有文件时显示删除按钮
            Obx(() => controller.isLocalFiles && controller.mediaItems.isNotEmpty
                ? IconButton(
              icon: const Icon(Iconsax.trash_bold, color: Colors.white),
              onPressed: () {
                _showDeleteConfirmation(context, controller);
              },
            )
                : const SizedBox.shrink()),
          ],
        ),
        body: Obx(() {
          if (controller.mediaItems.isEmpty) {
            return const Center(
              child: Text(
                'No media files',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return PageView.builder(
            controller: controller.pageController,
            itemCount: controller.mediaItems.length,
            onPageChanged: controller.onPageChanged,
            itemBuilder: (context, index) {
              final mediaItem = controller.mediaItems[index];
              final isVideo = controller.isVideoFile(mediaItem);
              final mediaPath = controller.getMediaPath(mediaItem);
              final isLocal = controller.isLocalFile(mediaItem);

              return Center(
                child: isVideo
                    ? VideoViewerWidget(
                  mediaPath: mediaPath,
                  isLocalFile: isLocal,
                )
                    : ImageViewerWidget(
                  mediaPath: mediaPath,
                  isLocalFile: isLocal,
                ),
              );
            },
          );
        }),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, MediaViewerController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Media'),
        content: const Text('Are you sure you want to delete this media file?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.deleteCurrentMedia();
            },
            child: const Text('Delete', style: TextStyle(color: TColors.error)),
          ),
        ],
      ),
    );
  }
}

class ImageViewerWidget extends StatelessWidget {
  const ImageViewerWidget({
    super.key,
    required this.mediaPath,
    required this.isLocalFile,
  });

  final String mediaPath;
  final bool isLocalFile;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 3.0,
      child: isLocalFile
          ? Image.file(
        File(mediaPath),
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      )
          : CachedNetworkImage(
        imageUrl: mediaPath,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Icon(
            Icons.error,
            color: Colors.white,
            size: 48,
          ),
        ),
      ),
    );
  }
}

class VideoViewerWidget extends StatefulWidget {
  const VideoViewerWidget({
    super.key,
    required this.mediaPath,
    required this.isLocalFile,
  });

  final String mediaPath;
  final bool isLocalFile;

  @override
  State<VideoViewerWidget> createState() => _VideoViewerWidgetState();
}

class _VideoViewerWidgetState extends State<VideoViewerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    try {
      if (widget.isLocalFile) {
        _controller = VideoPlayerController.file(File(widget.mediaPath));
      } else {
        _controller = VideoPlayerController.network(widget.mediaPath);
      }

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  void _togglePlayPause() {
    if (_controller?.value.isPlaying ?? false) {
      _controller?.pause();
    } else {
      _controller?.play();
    }
    setState(() {});
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
          if (_showControls)
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  iconSize: 64,
                  icon: Icon(
                    (_controller?.value.isPlaying ?? false)
                        ? Iconsax.pause_circle_bold
                        : Iconsax.play_circle_bold,
                    color: Colors.white,
                  ),
                  onPressed: _togglePlayPause,
                ),
              ),
            ),
          if (_showControls)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: TColors.primary,
                    bufferedColor: Colors.grey,
                    backgroundColor: Colors.white30,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}