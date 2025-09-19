import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

class MediaLightbox extends StatefulWidget {
  const MediaLightbox({
    super.key,
    required this.mediaFilenames,
    this.initialIndex = 0,
  });

  final List<String> mediaFilenames;
  final int initialIndex;

  @override
  State<MediaLightbox> createState() => _MediaLightboxState();
}

class _MediaLightboxState extends State<MediaLightbox> {
  late PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          // Main image viewer
          PageView.builder(
            controller: _pageController,
            itemCount: widget.mediaFilenames.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: _buildMediaImage(widget.mediaFilenames[index]),
                ),
              );
            },
          ),

          // Close button
          Positioned(
            top: MediaQuery
                .of(context)
                .padding
                .top + 10,
            right: 10,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // Image counter
          if (widget.mediaFilenames.length > 1)
            Positioned(
              top: MediaQuery
                  .of(context)
                  .padding
                  .top + 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${currentIndex + 1} / ${widget.mediaFilenames.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

          // Navigation arrows
          if (widget.mediaFilenames.length > 1) ...[
            // Previous button
            if (currentIndex > 0)
              Positioned(
                left: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),

            // Next button
            if (currentIndex < widget.mediaFilenames.length - 1)
              Positioned(
                right: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
          ],

          // Thumbnail strip at bottom
          if (widget.mediaFilenames.length > 1)
            Positioned(
              bottom: MediaQuery
                  .of(context)
                  .padding
                  .bottom + 20,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.mediaFilenames.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == currentIndex;
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors
                                .transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: _buildMediaImage(widget.mediaFilenames[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      // Network image
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.contain,
        placeholder: (context, url) =>
        const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
        errorWidget: (context, url, error) =>
        const Center(
          child: Icon(
            Icons.error,
            color: Colors.white,
            size: 48,
          ),
        ),
      );
    } else {
      // Local file
      return Image.file(
        File(imagePath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
        const Center(
          child: Icon(
            Icons.error,
            color: Colors.white,
            size: 48,
          ),
        ),
      );
    }
  }
}