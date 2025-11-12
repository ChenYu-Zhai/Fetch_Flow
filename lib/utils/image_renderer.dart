// lib/utils/image_renderer.dart

import 'dart:async';
import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:featch_flow/providers/cache_manager_provider.dart';
import 'package:featch_flow/providers/media_loading_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageRenderer extends ConsumerStatefulWidget {
  final String imageUrl;
  final Alignment alignment;
  final BoxFit fit;

  const ImageRenderer({
    super.key,
    required this.imageUrl,
    this.alignment = Alignment.center,
    this.fit = BoxFit.contain,
  });

  @override
  ConsumerState<ImageRenderer> createState() => _ImageRendererState();
}

class _ImageRendererState extends ConsumerState<ImageRenderer> {
  late final Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();
    _loadingFuture = _loadImage();
  }

  Future<void> _loadImage() async {
    final completer = Completer<void>();
    
    // ✅ 替代方案: 使用一个布尔标志来跟踪是否是主动取消
    bool wasCancelledByNotifier = false;

    Future.microtask(() {
      if (!mounted) {
        completer.completeError('Widget unmounted');
        return;
      }

      final loader = ref.read(mediaLoaderProvider.notifier);
      final cacheManager = ref.read(customCacheManagerProvider);

      loader.addRequest(
        MediaLoadRequest(
          imageUrl: widget.imageUrl,
          onLoad: () {
            final loadFuture = cacheManager.getSingleFile(widget.imageUrl);

            loadFuture.then((_) {
              if (!completer.isCompleted) {
                completer.complete();
              }
            }).catchError((error) {
              // ✅ 替代方案: 检查布尔标志，而不是异常类型
              // 如果不是我们主动取消的，并且 completer 还未完成，就视为真实错误
              if (!wasCancelledByNotifier && !completer.isCompleted) {
                completer.completeError(error);
              }
            });
            
            return CancelableOperation.fromFuture(loadFuture);
          },
          onCancel: () {
            // 当 Notifier 取消任务时，设置标志位
            wasCancelledByNotifier = true;
            if (!completer.isCompleted) {
              completer.completeError('Cancelled by Notifier');
            }
          },
        ),
      );
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final isAlreadyLoaded = ref.watch(
      mediaLoaderProvider.select(
        (state) => state.loadedUrls.contains(widget.imageUrl),
      ),
    );

    if (isAlreadyLoaded) {
      return _buildImage();
    }

    return FutureBuilder<void>(
      future: _loadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          return _buildImage();
        } else if (snapshot.hasError) {
          // 为了调试，可以打印出错误类型
          // debugPrint("FutureBuilder Error: ${snapshot.error}");
          final error = snapshot.error.toString();
          // 如果错误是 "Cancelled by Notifier"，我们可以显示一个不同的UI，或者什么都不显示
          if (error.contains('Cancelled by Notifier')) {
             return const SizedBox.shrink(); // 或者一个非常低调的占位符
          }
          return Container(
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image, size: 16),
          );
        } else {
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.0),
            ),
          );
        }
      },
    );
  }

  Widget _buildImage() {
    final cacheManager = ref.read(customCacheManagerProvider);
    return CachedNetworkImage(
      cacheManager: cacheManager,
      imageUrl: widget.imageUrl,
      fit: widget.fit,
      alignment: widget.alignment,
      fadeInDuration: const Duration(milliseconds: 20),
      fadeOutDuration: const Duration(milliseconds: 20),
      placeholder: (context, url) => const SizedBox.shrink(),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade300,
        child: const Icon(Icons.broken_image, size: 16),
      ),
    );
  }
}